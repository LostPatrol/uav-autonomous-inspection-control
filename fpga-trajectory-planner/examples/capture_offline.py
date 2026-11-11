#!/usr/bin/env python3
"""Publish a reproducible synthetic obstacle cloud and save actual ROS planning output."""
from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import time

import numpy as np
import rclpy
from rclpy.node import Node
from rclpy.qos import qos_profile_sensor_data
from nav_msgs.msg import Odometry
from path_planning.msg import PlanResult
from path_planning.srv import PlanMotion, SetGoal
from sensor_msgs.msg import PointCloud2
from sensor_msgs_py import point_cloud2
from std_msgs.msg import Header, String

# Fixed world geometry and identity make every generated evidence file traceable.
TARGET_ID = 'copyright-offline-wall-01'
START = (0.0, 0.0, 1.0)
GOAL = (4.0, 0.0, 1.0)


class Capture(Node):
    """Supply synthetic sensors and receive the production planner's DDS messages."""

    def __init__(self):
        """Create only local publishers, result subscriptions and the goal client."""
        super().__init__('offline_material_capture')
        self.result = None
        self.status = {}
        self.events = []
        self.cloud = [(float(x), float(y), float(z))
                      for x in np.linspace(1.7, 2.1, 5)
                      for y in np.linspace(-0.45, 0.45, 10)
                      for z in np.linspace(0.2, 1.8, 17)]
        self.odom_pub = self.create_publisher(Odometry, '/avoidance/odom', qos_profile_sensor_data)
        self.cloud_pub = self.create_publisher(PointCloud2, '/fpga_material/cloud', qos_profile_sensor_data)
        self.create_subscription(PlanResult, '/fpga_avoidance/plan_result', self.receive, 20)
        self.create_subscription(String, '/fpga_avoidance/status', self.receive_status, 10)
        self.client = self.create_client(SetGoal, '/fpga_avoidance/set_goal')
        self.query_client = self.create_client(PlanMotion, '/fpga_avoidance/plan_motion')
        self.create_timer(0.04, self.publish_inputs)

    def publish_inputs(self):
        """Publish odometry and the same wall cloud in the odom world frame."""
        header = Header(frame_id='odom', stamp=self.get_clock().now().to_msg())
        odom = Odometry()
        odom.header = header
        odom.child_frame_id = 'base_link'
        odom.pose.pose.position.x, odom.pose.pose.position.y, odom.pose.pose.position.z = START
        odom.pose.pose.orientation.w = 1.0
        self.odom_pub.publish(odom)
        self.cloud_pub.publish(point_cloud2.create_cloud_xyz32(header, self.cloud))

    def receive(self, result):
        """Retain real result transitions and the first complete target trajectory."""
        if result.target_id == TARGET_ID:
            self.events.append(dict(status=int(result.status), detail=result.detail,
                                    planning_ms=float(result.planning_ms), sequence=int(result.sequence)))
            if result.status == PlanResult.REACH_END and self.result is None:
                self.result = result

    def receive_status(self, message):
        """Keep the node's reported solver source and hardware participation."""
        self.status = json.loads(message.data)

    def spin_until(self, condition, timeout, label):
        """Advance local callbacks until a requested observable event occurs."""
        deadline = time.monotonic() + timeout
        while not condition() and time.monotonic() < deadline:
            rclpy.spin_once(self, timeout_sec=0.02)
        if not condition():
            raise RuntimeError(f'{label} timed out: status={self.status}; events={self.events[-4:]}')

    def goal(self, active):
        """Set or cancel the named persistent target through the real service."""
        self.spin_until(self.client.service_is_ready, 10.0, 'goal service')
        request = SetGoal.Request()
        request.header.frame_id = 'odom'
        request.target_id, request.active = TARGET_ID, active
        request.goal.x, request.goal.y, request.goal.z = GOAL
        future = self.client.call_async(request)
        self.spin_until(future.done, 5.0, 'goal response')
        response = future.result()
        if not response.accepted:
            raise RuntimeError(f'goal rejected: {response}')
        return response

    def save(self, output):
        """Save received coefficients and evaluate their p/v/a values without fitting."""
        result = self.result
        geometry_checks = {}
        for label, mode in [('straight_line', PlanMotion.Request.CHECK_LINE),
                            ('returned_curve', PlanMotion.Request.VALIDATE_TRAJECTORY)]:
            request = PlanMotion.Request()
            request.header = Header(frame_id='odom', stamp=self.get_clock().now().to_msg())
            request.mode = mode
            request.start.x, request.start.y, request.start.z = START
            request.goal.x, request.goal.y, request.goal.z = GOAL
            request.segments = list(result.segments)
            future = self.query_client.call_async(request)
            self.spin_until(future.done, 5.0, label)
            response = future.result().result
            geometry_checks[label] = dict(status=int(response.status), detail=response.detail)
        assert geometry_checks['straight_line']['status'] == PlanResult.NO_PATH, geometry_checks
        assert geometry_checks['returned_curve']['status'] == PlanResult.REACH_END, geometry_checks
        segments = [dict(duration=float(s.duration), x=list(s.x), y=list(s.y), z=list(s.z))
                    for s in result.segments]
        detail = json.loads(result.detail)
        assert detail['source'].startswith('mock:'), detail
        assert self.status.get('mock') is True, self.status
        assert self.status.get('hardware_transactions') == 0, self.status
        rows, offset = [], 0.0
        for index, segment in enumerate(segments):
            duration = segment['duration']
            coefficients = np.array([segment[axis] for axis in ('x', 'y', 'z')])
            for t in np.linspace(0.0, duration, max(2, int(np.ceil(duration / 0.02)) + 1)):
                if index and t == 0.0:
                    continue
                p = coefficients @ np.array([1.0, t, t*t, t*t*t])
                v = coefficients @ np.array([0.0, 1.0, 2*t, 3*t*t])
                a = coefficients @ np.array([0.0, 0.0, 2.0, 6*t])
                rows.append([offset + t, *p, *v, *a])
            offset += duration
        output.mkdir(parents=True, exist_ok=True)
        with (output / 'trajectory.csv').open('w', newline='') as stream:
            writer = csv.writer(stream)
            writer.writerow(['t_s', 'x_m', 'y_m', 'z_m', 'vx_mps', 'vy_mps', 'vz_mps',
                             'ax_mps2', 'ay_mps2', 'az_mps2'])
            writer.writerows(rows)
        sample = np.asarray(rows)
        evidence = dict(software='无人机CPU与FPGA协同轨迹规划软件 V1.0', mode='offline software MOCK',
                        input='synthetic fixed wall cloud, stationary odometry', frame='odom',
                        start=START, goal=GOAL, cloud=self.cloud, target_id=TARGET_ID,
                        planner_session=result.planner_session, goal_revision=int(result.goal_revision),
                        status=int(result.status), detail=detail, node_status=self.status,
                        segments=segments, events=self.events, geometry_checks=geometry_checks,
                        duration_s=offset, sampled_max_speed_mps=float(np.linalg.norm(sample[:,4:7],axis=1).max()),
                        sampled_max_acceleration_mps2=float(np.linalg.norm(sample[:,7:10],axis=1).max()),
                        sampled_start_xyz=sample[0,1:4].tolist(), sampled_end_xyz=sample[-1,1:4].tolist(),
                        hardware_tested=False, aircraft_tested=False)
        (output / 'evidence.json').write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + '\n')
        print(json.dumps({key:evidence[key] for key in ('mode','duration_s','sampled_max_speed_mps',
              'sampled_max_acceleration_mps2','detail','node_status')}, ensure_ascii=False, indent=2))


def main():
    """Capture an isolated offline run, then cancel only this example's target."""
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    rclpy.init()
    node = Capture()
    try:
        node.spin_until(lambda: node.status.get('ready') is True, 15.0, 'MOCK and input readiness')
        node.goal(True)
        node.spin_until(lambda: node.result is not None, 30.0, 'complete obstacle route')
        node.spin_until(lambda: str(node.status.get('source', '')).startswith('mock:'), 5.0, 'source heartbeat')
        node.save(args.output)
        node.goal(False)
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()

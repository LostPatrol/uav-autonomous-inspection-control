#!/usr/bin/env python3
"""Run an isolated synthetic obstacle scene and save actual ROS planner results."""

import argparse
from collections import Counter
import csv
import json
import os
from pathlib import Path
import signal
import subprocess
import time

import numpy as np
import rclpy
from rclpy.qos import qos_profile_sensor_data
from ament_index_python.packages import get_package_prefix, get_package_share_directory
from geometry_msgs.msg import PoseStamped
from nav_msgs.msg import Odometry
from path_planning.msg import PlanResult
from sensor_msgs.msg import PointCloud2
from sensor_msgs_py.point_cloud2 import create_cloud_xyz32
from std_msgs.msg import Header


def save_csv(path, header, rows):
    """Write inspectable numeric data without rounding away the solver output."""
    with path.open('w', newline='', encoding='utf-8') as stream:
        writer = csv.writer(stream)
        writer.writerow(header)
        writer.writerows(rows)


def main():
    """Feed a fixed world scene, submit a goal and retain returned curves and identities."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=15.)
    args = parser.parse_args()
    if os.environ.get('ROS_AUTOMATIC_DISCOVERY_RANGE') != 'LOCALHOST' or os.environ.get('ROS_DOMAIN_ID', '0') == '0':
        parser.error('set a nonzero ROS_DOMAIN_ID and ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST')
    args.output.mkdir(parents=True, exist_ok=True)
    executable = str(Path(get_package_prefix('path_planning')) / 'lib/path_planning/path_planning_node')
    config = str(Path(get_package_share_directory('path_planning')) / 'config/planner.yaml')
    command = [executable, '--ros-args', '--params-file', config,
               '-p', 'planning_frame:=map', '-p', 'stamp_clock:=ros']
    points = [(2., 0., float(z)) for z in np.arange(.2, 1.81, .025)] + [(-15., -15., 1.)]
    save_csv(args.output / 'cloud.csv', ['x', 'y', 'z'], points)
    rclpy.init()
    node = rclpy.create_node('pointcloud_planner_demo')
    cloud_pub = node.create_publisher(PointCloud2, '/cloud', qos_profile_sensor_data)
    odom_pub = node.create_publisher(Odometry, '/odom', qos_profile_sensor_data)
    goal_pub = node.create_publisher(PoseStamped, '/goal', 1)
    results = []
    trajectories = []
    began = time.monotonic()

    def receive(result):
        """Record the authoritative result and exact samples from this DDS delivery."""
        results.append({'elapsed_s': time.monotonic() - began, 'sequence': result.sequence,
                        'planner_session': result.planner_session, 'target_id': result.target_id,
                        'goal_revision': result.goal_revision, 'status': result.status,
                        'detail': result.detail, 'planning_ms': result.planning_ms,
                        'map_points': result.map_points, 'segments': len(result.segments),
                        'samples': len(result.trajectory.points)})
        if result.status == PlanResult.REACH_END and result.trajectory.points:
            rows = []
            for point in result.trajectory.points:
                pos = point.transforms[0].translation
                vel = point.velocities[0].linear
                acc = point.accelerations[0].linear
                duration = point.time_from_start.sec + point.time_from_start.nanosec * 1e-9
                rows.append([duration, pos.x, pos.y, pos.z, vel.x, vel.y, vel.z, acc.x, acc.y, acc.z])
            trajectories.append((results[-1], rows))

    node.create_subscription(PlanResult, '/plan_result', receive, 20)
    stream = (args.output / 'planner.log').open('w', encoding='utf-8')
    process = subprocess.Popen(command, stdout=stream, stderr=subprocess.STDOUT)
    sent = False
    next_feed = began
    try:
        while time.monotonic() - began < args.seconds:
            now = time.monotonic()
            if now >= next_feed:
                header = Header(stamp=node.get_clock().now().to_msg(), frame_id='map')
                cloud_pub.publish(create_cloud_xyz32(header, points))
                odom = Odometry(header=header, child_frame_id='base_link')
                odom.pose.pose.position.z = 1.
                odom.pose.pose.orientation.w = 1.
                odom_pub.publish(odom)
                next_feed = now + .1
            if not sent and now - began > 1.:
                goal = PoseStamped(header=Header(frame_id='map'))
                goal.pose.position.x = 4.
                goal.pose.position.z = 1.
                goal.pose.orientation.w = 1.
                goal_pub.publish(goal)
                sent = True
            rclpy.spin_once(node, timeout_sec=.01)
            if process.poll() is not None:
                raise RuntimeError('planner exited: ' + str(process.returncode))
    finally:
        process.send_signal(signal.SIGINT)
        try:
            process.wait(timeout=5.)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5.)
        stream.close()
        node.destroy_node()
        rclpy.shutdown()
    summary = {'scene': 'Synthetic stationary vertical pole; world-frame map and odometry',
               'source': 'actual native ROS 2 path_planning_node result, not flight recording',
               'start': [0., 0., 1.], 'goal': [4., 0., 1.], 'command': command,
               'ros_domain_id': os.environ['ROS_DOMAIN_ID'], 'duration_s': args.seconds,
               'status_counts': dict(Counter(row['status'] for row in results)),
               'results': results}
    if trajectories:
        identity, rows = trajectories[0]
        save_csv(args.output / 'trajectory.csv', ['t', 'x', 'y', 'z', 'vx', 'vy', 'vz', 'ax', 'ay', 'az'], rows)
        xyz = np.array([row[1:4] for row in rows])
        cloud = np.array(points)
        summary['selected_trajectory'] = identity
        summary['trajectory_duration_s'] = rows[-1][0]
        summary['min_sample_distance_to_input_points_m'] = float(np.linalg.norm(xyz[:, None] - cloud[None, :], axis=2).min())
    (args.output / 'demo_result.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({key: value for key, value in summary.items() if key not in ('results', 'command')}, indent=2))
    if not trajectories:
        raise SystemExit('no REACH_END trajectory received; inspect planner.log and demo_result.json')


if __name__ == '__main__':
    main()

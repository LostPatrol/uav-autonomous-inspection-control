<!-- Standalone CPU point-cloud planner: build, operation and source ownership. -->
# 无人机点云避障与局部轨迹规划软件 V1.0

本软件接收同一世界坐标系中的点云、里程计和目标，积累障碍点地图，进行动力学 A* 搜索及末端多项式连接，输出带时间参数的位置、速度与加速度轨迹。提供 ROS 2 Jazzy 节点、目标设置与取消服务、路径可视化，以及面向机载任务执行软件的坐标和任务身份适配。

## 构建与启动

运行环境为 Ubuntu 24.04 / ROS 2 Jazzy，依赖 colcon、PCL、Eigen3、ament_cmake、ament_cmake_gtest、ament_cmake_pytest、rclcpp、rclpy、sensor_msgs_py 和相应 ROS 消息开发包。首次准备依赖可执行 `rosdep install --from-paths src --ignore-src -r -y --rosdistro jazzy`。

```bash
./build.sh
./run.sh cloud:=/cloud_registered odom:=/Odometry goal:=/goal
# 当前终端加载接口，随后发送一个世界坐标系目标：
source setup.sh
ros2 topic pub --once /goal geometry_msgs/msg/PoseStamped \
  '{header: {frame_id: odom}, pose: {position: {x: 4.0, y: 0.0, z: 1.0}, orientation: {w: 1.0}}}'
```

默认配置在 `src/path_planning/config/planner.yaml`，可通过 `./run.sh config:=/absolute/path/planner.yaml` 选择配置。点云、里程计位姿和目标应使用配置的 `planning_frame`；里程计速度按照 `odometry_twist_in_body` 转换。参数在启动时读取。

`/plan_result` 输出本次规划状态、多项式和采样轨迹，`/kino_path` 提供最近成功路径，`/filtered_cloud` 提供障碍点地图。在 RViz2 中选择对应固定坐标系，添加 PointCloud2 和 Path 显示即可查看。

## 目标管理与机载接入

`/set_goal` 服务接收 `target_id` 和 `active`，完成持久目标设置及取消；`/plan_motion` 提供当前地图的几何检查与规划查询。结果带有 `planner_session`、`target_id`、`goal_revision` 和 `sequence`。

```bash
# 对接已有机载控制软件和已配准点云：
./run.sh --bridge config:=$PWD/config/aircraft-reference.yaml
# 相同世界坐标系的独立集成：
./run.sh --bridge coordinate_mode:=identity cloud:=/cloud_registered odom:=/Odometry
```

桥接入口发布 `/avoidance/odom`，接收 `/onboard_control/avoidance_request`，把原生轨迹转换为 `/onboard_control/avoidance_result`。默认原生规划命名空间为 `/avoidance`。机载控制、传感器驱动、定位、飞控和 FPGA 后端由独立的软件提供。桥接默认参数随包安装在 `src/avoidance_bridge/config/planner.yaml`；`config/aircraft-reference.yaml` 保留提取时的机载参考档案，部署时按目标机确认坐标及限额。

## 离线演示与测试

在加载工作区、准备包含 NumPy/rclpy 的 Python 后运行：

```bash
source setup.sh
ROS_DOMAIN_ID=230 ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST \
  /usr/bin/python3 scripts/demo.py --output /tmp/pointcloud-planner-demo --seconds 15
ROS_DOMAIN_ID=230 ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST \
  colcon test --packages-select path_searching path_planning avoidance_bridge \
  --executor sequential --event-handlers console_direct+
colcon test-result --verbose
```

演示以静止里程计和合成竖直障碍点云输入真实规划节点，保存 `cloud.csv`、`trajectory.csv`、`demo_result.json` 及节点日志。软件的现场验证需要由操作者提供实际点云、外参和机载执行环境。

## 设计与修改入口

- `src/path_searching`：ROS 无关的点云双树地图、动力学搜索、碰撞检查和多项式轨迹。
- `src/path_planning`：ROS 输入输出、重规划触发、目标生命周期和轨迹采样。
- `src/avoidance_bridge`：业务目标、结果身份及坐标适配；后端管理脚本为配套集成依赖。
- `src/guided_interfaces`、`src/correction_interfaces`：与现有套件共用的 ROS 消息，作为构建依赖提供。

本软件基于 HKU-MARS 的 GPLv3 工程进行 ROS 2 移植及改进，保留上游数学和搜索来源。许可见 [LICENSE](LICENSE)，原创、改进及配套依赖范围见 [PROVENANCE.md](PROVENANCE.md) 和 `source_files.json`。冻结基线见 `SOURCE_BASELINE.json`。

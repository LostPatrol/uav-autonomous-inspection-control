<!-- Independent CPU/FPGA host planning software and its reproducible entrypoints. -->
# 无人机CPU与FPGA协同轨迹规划软件 V1.0

本软件根据三维点云、当前位置、实测速度与目标位置，完成局部占据地图构建、CPU候选路径搜索、Ising/QUBO问题生成、板卡通信和连续轨迹输出。主机端生成带时间参数的三次多项式，检查速度、加速度与完整曲线碰撞，并通过 ROS 2 服务及主题对接轨迹执行软件。

## 安装与运行

环境为 Ubuntu 24.04、ROS 2 Jazzy、Python 3.12、C++17。安装常规构建及运行依赖后执行：

```bash
sudo apt install python3-venv python3-colcon-common-extensions python3-numpy python3-yaml \
  ros-jazzy-rclpy ros-jazzy-sensor-msgs-py ros-jazzy-rosidl-default-generators \
  ros-jazzy-trajectory-msgs ros-jazzy-nav-msgs ros-jazzy-visualization-msgs
./setup.sh
./run.sh --check
./test.sh
```

工作区已包含同名 `path_planning` 协议包，可独立构建。与 CPU 规划软件集成时选择一个协议包的 overlay；四个消息和服务定义保持一致。

`./run.sh --mock` 启动离线软件求解模式，使用 `config/offline_mock.yaml`、LOCALHOST 与默认 ROS domain 226。`./run.sh --hardware` 使用 `config/backend.yaml` 启动板卡模式。默认运行 `./run.sh` 只检查安装，不探测板卡。使用 Ctrl-C 停止当前节点。

板卡模式先按实际网络填写 `fpga_ip`、`bind_ip`、`udp_port`，确认 `mock: false`；设置 `ROS_DOMAIN_ID` 与传感器所在域一致。节点接收 `/avoidance/odom` 与默认 `/odin1/cloud_slam_down`，通过 ROS 参数配置 `planning_frame`、`cloud_topic`、`search_lower`、`search_upper`。点云和里程计在同一规划坐标系中输入。

```bash
./run.sh --hardware -p planning_frame:=odom -p cloud_topic:=/mapping/cloud
ros2 service call /fpga_avoidance/set_goal path_planning/srv/SetGoal \
  "{header: {frame_id: odom}, target_id: inspection-01, active: true, goal: {x: 3.0, y: 0.0, z: 1.0}}"
ros2 topic echo /fpga_avoidance/status
```

## 接口与维护

- `/fpga_avoidance/set_goal`：设置、更换或取消持久目标。
- `/fpga_avoidance/plan_motion`：通过 `CHECK_LINE` 检查直线，或通过 `VALIDATE_TRAJECTORY` 验证已给定多项式；持续规划通过 `/fpga_avoidance/set_goal` 提交目标。
- `/fpga_avoidance/plan_result`：输出任务身份、状态、运动限额、多项式段及轨迹采样。
- `/fpga_avoidance/status`：输出 ready、mock、source、transactions、hardware_transactions、hardware_participation、solve_ms、cpu_ms 与 error。

主机端核心位于 `workspace/src/fpga_uav_planner_ros2/fpga_uav_planner_ros2/fpga_solver/`，ROS 协议适配位于 `flight_backend_node.py`，C++加速内核位于 `fpga_uav_native/src/native_fastpath.cpp`。`config/backend.yaml` 管理板卡网络、栅格和运动限额。原演示与比较工具随冻结包保留，正式使用入口为本目录脚本与 `fpga_flight_backend`。

`source` 区分 `direct`、`fpga`、`deterministic` 等路径来源，离线模式添加 `mock:` 标识；实际硬件参与由事务数和 `hardware_participation` 判断。成功轨迹交给外部轨迹跟踪软件执行。本目录只承担规划与协议输出。

软件采用 GPLv3。来源与合作范围见 [PROVENANCE.md](PROVENANCE.md)，冻结版本与文件哈希见 [SOURCE_BASELINE.json](SOURCE_BASELINE.json)。此交付包含主机端源码；板端 Ising/QUBO 优化器由合作方提供，RTL/固件源码另行归档。本次材料使用离线软件求解与DDS运行证据。

## 离线示例

```bash
./demo.sh /absolute/output/directory
```

示例启动实际 `--mock` 规划节点，通过DDS发布固定合成墙体点云与里程计，设置目标 `(4, 0, 1)`，保存节点返回的多项式、来源字段和 `trajectory.csv`。同时调用直线与曲线检查服务，验证直线受阻而输出曲线可通过。示例结束后取消自己的目标并停止自己启动的节点。`examples/reference_output/` 保留本次运行的原始JSON与CSV结果，可按相同输入复现。

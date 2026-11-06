<!-- 机载航点导航与轨迹跟踪软件的独立构建和运行入口。 -->
# 无人机机载航点导航与轨迹跟踪控制软件 V1.0

面向 ROS 2 与 ArduPilot 的机载应用控制服务，提供任务受理、航点导航、参考生成、PD+DOB 跟踪和聚合状态发布。可部署在 Ubuntu 24.04 / ROS 2 Jazzy 的 x86_64 或 aarch64 主机，在目标架构原生构建。

## 构建与运行

安装 ROS 2 Jazzy、MAVROS、colcon、Eigen3、nlohmann-json、ament_cmake_gtest 及对应 ROS 消息开发包。然后执行：

```bash
./build.sh
./run.sh
# 明确选择某份参数：
./run.sh config_file:=$PWD/config/aircraft/uav002/control.yaml
```

`config/aircraft.local.env` 选择默认档案，初始为 `simulation`。ArduPilot、MAVROS 和定位数据源作为外部运行依赖；地面操作界面由相邻 `ground-station` 软件提供。机载软件通过 `guided_interfaces` 接收业务任务，通过 MAVROS 输出姿态与推力目标。

实机解锁和起飞由操作者手动执行。

## 功能与维护入口

- `src/onboard_control/src/onboard_control_node.cpp`：任务状态机、控制周期、权限和状态发布。
- `reference_generator.cpp`：阶跃、二阶滤波、梯形速度和限 jerk S 曲线参考。
- `dob_controller.cpp`：位置 PD、扰动观测器和加速度前馈。
- `navigation_frame.cpp`：odom/map 任务坐标与飞控本地坐标转换。
- `avoidance_execution.cpp`：消费外部规划器轨迹并跟踪执行。
- `waypoint_calibration.cpp`：航点到点后的校准任务协调。
- `src/guided_interfaces`、`src/correction_interfaces`：共用接口定义。

本独立版本的构建、运行以根目录 `build.sh`、`run.sh` 为入口。飞机串口、MAVROS、Odin 驱动和系统服务由现场集成环境提供。

## 验证

```bash
source /opt/ros/jazzy/setup.bash
source install/local_setup.bash
colcon test --packages-select onboard_control --event-handlers console_direct+
colcon test-result --verbose
```

登记软件版本 V1.0；ROS 包及通信协议版本沿用提取基线的 3.6。源码基线见仓库根目录 `SOURCE_BASELINE.json`。

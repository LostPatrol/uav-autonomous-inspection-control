<!-- 地面软件的用途、安装与运行入口。 -->
# 无人机巡检地面监控与任务管理软件 V1.0

本软件为 ROS 2、MAVROS、ArduPilot 无人机巡检系统提供统一地面交互入口，支持状态监控、航点编排与文件导入导出、任务下发、三维路线预览、结构化日志和 WebSocket 上位机业务接入。

地面软件通过 `guided_interfaces` 接口连接机载控制软件。巡检媒体与视觉标志校准使用各自独立软件，地面窗口提供对应面板入口。

## 运行环境

- Ubuntu 24.04、ROS 2 Jazzy、Python 3.12，支持 X11 / Wayland 桌面。
- 系统依赖：`python3-venv python3-colcon-common-extensions libxcb-cursor0 ros-jazzy-mavros ros-jazzy-rviz2 ros-jazzy-robot-state-publisher ros-jazzy-tf2-ros`；MAVROS 按官方说明安装 GeographicLib 数据。
- Python 依赖见 `requirements-gui.txt`，通过 `setup.sh` 安装。
- 本地仿真另需 ArduPilot ArduCopter SITL 源码和可执行文件，以及相邻 `../onboard-control` 的原生构建产物。ArduPilot 可放在上两级 `ardupilot` 目录，或通过 `GROUND_STATION_SIM_VEHICLE` 指定 `sim_vehicle.py`。

## 安装与启动

```bash
bash setup.sh
bash run.sh
```

单独重新构建地面接口与可视化：`bash build.sh`。环境只读检查：`.venv/bin/python ground_station.py --check-environment`。

已有兼容 Python 环境可设置 `GROUND_STATION_PYTHON=/path/to/python`。主机专用路径写入 `config/host.local.env`，格式参见 `config/host.local.env.example`。`GROUND_STATION_ONBOARD_ROOT` 可指定机载软件目录。

## 使用流程

1. 启动窗口后选择“启动仿真”，或连接已运行机载服务的实机。仿真固定使用 ROS 域 231 和本机发现。
2. 检查机载链路、飞控连接、控制权和位置状态。实机的解锁、起飞由现场操作者手动确认操作。
3. 添加或导入航点，调整顺序，设置巡检/校准属性与飞行方法，并预览三维路线。
4. 在允许的飞行状态发送任务，观察点位进度、实际位置和命令结果；任务完成后按需降落。
5. 使用“上位机通讯面板”配置 WebSocket 业务接入；使用独立面板处理摄像头、媒体文件或标记校准。
6. 结束仿真或退出窗口，由本软件清理本地会话进程。

CSV 支持 `index,x,y,z,yaw`，导出时追加 `is_inspection,is_calibration,calibration_tag_id,continue_window`。位置单位为米，文件中的 yaw 单位为度。普通航点示例位于 `examples/`。

## 软件组成

- `ground_station.py`：Qt 主入口与环境检查。
- `ground_station_core/qt_ui/`：监控、任务、状态、日志和上位机面板。
- `ground_station_core/ros_controller.py`：ROS 2 业务客户端。
- `ground_station_core/environment.py`：本地 SITL / RViz 编排及连接管理。
- `ground_station_core/upstream/`：WebSocket 业务映射和回执。
- `src/guided_sim/`：模型、位姿桥、三维预览及仿真场景。
- `src/guided_interfaces/`：与机载软件共用的消息和服务定义。

相邻软件目录分别为 `../onboard-control`、`../inspection-media`、`../position-calibration`。地面侧核心实现集中在本目录；连续飞行控制、媒体处理与视觉估计分别由对应软件提供。

<!-- 四项无人机巡检软件的源码、运行及成果交付入口。 -->
# 无人机巡检软件套件

本仓库分别提供地面监控、机载控制、视觉定位校准和巡检媒体管理四项软件。各软件具有独立目录、构建及运行入口，可通过 ROS 2 和媒体接口组合使用。

| 软件 | 目录 | 启动入口 |
| --- | --- | --- |
| 无人机巡检地面监控与任务管理软件 V1.0 | [ground-station](ground-station/) | `./run.sh` |
| 无人机机载航点导航与轨迹跟踪控制软件 V1.0 | [onboard-control](onboard-control/) | `./run.sh` |
| 无人机视觉标志辅助定位校准软件 V1.0 | [position-calibration](position-calibration/) | `./run_service.sh`、`./run_panel.sh` |
| 无人机巡检视频处理与媒体管理软件 V1.0 | [inspection-media](inspection-media/) | `./run.sh ground`、`./run.sh camera`、`./run.sh files` |

在各软件目录执行 `./setup.sh` 准备依赖与构建；详细条件和使用步骤见对应 README。推荐 Ubuntu 24.04 / ROS 2 Jazzy，机载与地面分别原生构建。地面本地仿真使用相邻机载软件的安装产物。

源码来自固定提交 `048bde8459d4c18f7deb9e44dab02aa94e323013`，基线与范围见 [SOURCE_BASELINE.json](SOURCE_BASELINE.json)。每项软件通过独立 Release 提供源码和申报文档。

实机解锁与起飞由操作者手动执行。ROS 2、ArduPilot、MAVROS、OpenCV、Qt、FFmpeg、MediaMTX 等按外部组件使用，来源见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

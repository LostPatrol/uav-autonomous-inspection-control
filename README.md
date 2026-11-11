<!-- 六项无人机巡检软件的源码、运行及成果交付入口。 -->
# 无人机巡检软件套件

本仓库提供地面监控、机载控制、视觉定位校准、巡检媒体管理、点云局部规划和CPU与FPGA协同规划六项软件。各软件具有独立目录、构建及运行入口，可通过 ROS 2 和媒体接口组合使用。

| 软件 | 目录 | 启动入口 |
| --- | --- | --- |
| 无人机巡检地面监控与任务管理软件 V1.0 | [ground-station](ground-station/) | `./run.sh` |
| 无人机机载航点导航与轨迹跟踪控制软件 V1.0 | [onboard-control](onboard-control/) | `./run.sh` |
| 无人机视觉标志辅助定位校准软件 V1.0 | [position-calibration](position-calibration/) | `./run_service.sh`、`./run_panel.sh` |
| 无人机巡检视频处理与媒体管理软件 V1.0 | [inspection-media](inspection-media/) | `./run.sh ground`、`./run.sh camera`、`./run.sh files` |
| 无人机点云避障与局部轨迹规划软件 V1.0 | [pointcloud-planner](pointcloud-planner/) | `./run.sh` |
| 无人机CPU与FPGA协同轨迹规划软件 V1.0 | [fpga-trajectory-planner](fpga-trajectory-planner/) | `./run.sh --check`、`./run.sh --mock`、`./run.sh --hardware` |

按各软件 README 准备依赖并构建。推荐 Ubuntu 24.04 / ROS 2 Jazzy，机载与地面分别原生构建。地面本地仿真使用相邻机载软件的安装产物。

原四项软件保持固定提交 `048bde8459d4c18f7deb9e44dab02aa94e323013` 的提取版本。两项新增规划软件于2026年11月11日独立冻结，基线与范围见 [SOURCE_BASELINE.json](SOURCE_BASELINE.json) 及各目录的同名文件。每项通过独立 Release 提供源码和申报文档；新增两项的 Word 材料、图像和交存索引同时存放在各自 `materials/` 目录。

地面软件组织任务，机载软件执行并跟踪轨迹，两项规划软件提供点云避障轨迹，定位与媒体软件分别提供配套服务。离线演示和验证命令见各目录说明。

实机解锁与起飞由操作者手动执行。目录许可范围见 [LICENSES.md](LICENSES.md)，外部组件及来源见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

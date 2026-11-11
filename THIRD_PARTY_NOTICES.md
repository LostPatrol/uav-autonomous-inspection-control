<!-- 软件来源、共享组件及外部运行依赖。 -->
# 源码与外部组件

原四项软件从固定工程基线提取，并适配独立的安装、启动和界面依赖；新增两项规划软件使用各自冻结基线。各目录 `SOURCE_MANIFEST.json` 列明本项源程序交存范围及文件摘要；共享消息、通用界面支持、配置和部署脚本按配套依赖组织。

- ROS 2、ament、colcon：通信与构建环境。
- ArduPilot、MAVROS：飞控及飞控通信环境。
- PySide6 / Qt：图形界面库。
- OpenCV、NumPy、PyYAML、pybind11：视觉、几何与原生绑定依赖。
- Eigen3、nlohmann-json：机载数学与配置依赖。
- FFmpeg、PyAV、MediaMTX、pyftpdlib：视频处理与媒体服务依赖。
- websockets、MAVProxy、future：上位机通信与本地仿真依赖。

以上组件按各自许可证安装使用，保留相应发行包的版权和许可证。本仓库四项软件的源程序材料仅从清单所列应用实现提取，外部组件源码和二进制由其各自发行渠道提供。

Odin驱动与厂商SDK由部署环境提供。

`pointcloud-planner` 基于 HKU-MARS `dyn_small_obs_avoidance` 的 GPLv3 代码，包含 ROS 2 移植、搜索与轨迹约束改进、目标接口和坐标接入；保留 HKU-MARS 及 Fast-Planner 来源，详见本目录 `THIRD_PARTY_NOTICES.md`。

`fpga-trajectory-planner` 提供主机端搜索、QUBO建模、通信适配、连续轨迹生成及ROS服务，采用现有工程的 GPLv3 声明。板端 Ising/QUBO 优化器由合作方实现并作为配套求解组件，成果归属与源码范围详见本目录 `PROVENANCE.md`。本仓库不含板端RTL或固件源码。

新增两项所带 `path_planning`、`guided_interfaces`、`correction_interfaces` 消息和服务定义属于组合运行的配套接口；各项交存按明确清单编排。PCL、Eigen、NumPy及RViz由运行环境提供。

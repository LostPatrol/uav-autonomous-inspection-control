<!-- 软件来源、共享组件及外部运行依赖。 -->
# 源码与外部组件

四项软件从固定工程基线提取，并适配独立的安装、启动和界面依赖。各目录 `SOURCE_MANIFEST.json` 列明本项源程序交存范围及文件摘要；共享消息、通用界面支持、配置和部署脚本按配套依赖组织。

- ROS 2、ament、colcon：通信与构建环境。
- ArduPilot、MAVROS：飞控及飞控通信环境。
- PySide6 / Qt：图形界面库。
- OpenCV、NumPy、PyYAML、pybind11：视觉、几何与原生绑定依赖。
- Eigen3、nlohmann-json：机载数学与配置依赖。
- FFmpeg、PyAV、MediaMTX、pyftpdlib：视频处理与媒体服务依赖。
- websockets、MAVProxy、future：上位机通信与本地仿真依赖。

以上组件按各自许可证安装使用，保留相应发行包的版权和许可证。本仓库四项软件的源程序材料仅从清单所列应用实现提取，外部组件源码和二进制由其各自发行渠道提供。

Odin驱动、厂商SDK、CPU避障核心以及FPGA板端优化器由部署环境提供。CPU与FPGA规划软件的登记材料另行整理。

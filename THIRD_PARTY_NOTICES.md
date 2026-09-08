# 第三方软件与许可证说明

本文列出“无人机自主巡检地面监控与机载协同控制软件 V1.0”直接使用的主要外部软件。
本仓库不复制、修改或再分发下列项目的源码与预编译文件；它们由用户通过操作系统、ROS 2、
Python 包管理器或设备厂商提供的安装方式单独取得。各第三方软件仍受其自身许可证约束，
不属于本仓库 Apache License 2.0 的授权范围。

## 直接运行依赖

| 软件或组件 | 本项目中的用途 | 已验证版本或范围 | 许可证 | 获取方式 |
| --- | --- | --- | --- | --- |
| [ROS 2](https://github.com/ros2) | 分布式通信、节点、话题、服务及启动系统 | Jazzy；兼容部署可使用 Humble | 各软件包独立授权，核心 `rclcpp`、`rclpy` 等主要为 Apache-2.0 | ROS 官方软件源 |
| [MAVROS](https://github.com/mavlink/mavros) 与 `mavros_msgs` | ROS 2 与飞控之间的 MAVLink 网关及消息接口 | 2.14.0 | 仓库内文件混合使用 BSD、GPL、LGPL，具体以安装包所带声明为准 | ROS 官方软件源 |
| [ArduPilot](https://github.com/ArduPilot/ardupilot) | 实机飞控固件与 SITL 仿真 | 以目标机验证版本为准 | GPL-3.0 | 独立源码仓库或飞控固件 |
| [MAVProxy](https://github.com/ArduPilot/MAVProxy) | 启动和管理本地 ArduPilot SITL | 1.8.x | GPL-3.0 | 项目虚拟环境 |
| [PySide6](https://doc.qt.io/qtforpython-6/) / Qt for Python | 地面站、视频面板和修正面板图形界面 | 6.7 以上、7.0 以下 | LGPL-3.0-only、GPL-2.0-only、GPL-3.0-only 或商业许可证 | 项目虚拟环境 |
| [websockets](https://github.com/python-websockets/websockets) | 上位机 WebSocket 通信 | 15.x | BSD-3-Clause | 项目虚拟环境 |
| [python-future](https://github.com/PythonCharmers/python-future) | MAVProxy 兼容依赖 | 1.x | MIT | 项目虚拟环境 |
| [NumPy](https://github.com/numpy/numpy) | 坐标变换、矩阵与数值计算 | 系统或兼容版本 | BSD-3-Clause | Ubuntu/ROS 软件源 |
| [OpenCV](https://github.com/opencv/opencv) | AprilTag 检测、PnP 位姿估计与图像处理 | 系统兼容版本 | Apache-2.0 | Ubuntu/ROS 软件源 |
| [PyYAML](https://github.com/yaml/pyyaml) | 相机、标定和修正参数解析 | 系统兼容版本 | MIT | Ubuntu/ROS 软件源 |
| [Eigen](https://gitlab.com/libeigen/eigen) | 机载 C++ 控制器矩阵运算 | Eigen 3 | MPL-2.0 | Ubuntu/ROS 软件源 |
| [FFmpeg](https://ffmpeg.org/) | 摄像头采集、RTSP 推流、录像及抓拍 | Ubuntu 24.04 为 6.1；机载版本按平台确认 | 主要为 LGPL-2.1-or-later；启用 GPL 组件的构建按 GPL-2.0-or-later 或 GPL-3.0-or-later授权 | Ubuntu 或设备厂商软件源 |
| [v4l-utils](https://git.linuxtv.org/v4l-utils.git/) | 枚举摄像头并读写 UVC 参数 | 1.26.x | GPL-2.0，部分文件使用 LGPL/BSD 等兼容条款 | Ubuntu 软件源 |
| [MediaMTX](https://github.com/bluenviron/mediamtx) | 独立 RTSP 服务 | 1.20.0 | MIT | 用户按处理器架构独立安装到 `/usr/local/bin/mediamtx` |

## 外部设备和现场软件

- Odin 定位驱动、extnav 原始工程和 Wasintek 相机驱动由设备供应方或现场环境单独提供；本仓库
  只提供对公开 ROS 2 接口的适配代码以及可选 extnav 补丁，不包含供应方二进制、SDK 或源码。
- 飞控固件、摄像头固件、操作系统内核和显卡/多媒体驱动均不随本仓库分发。
- `correction_service/config/` 内的内参、外参、Tag 位姿和摄像头参数属于本软件配置数据，
  但部署到另一架无人机前必须重新测量或人工复核，不能把示例数值视为设备通用参数。

## 分发与合规原则

1. 本仓库只授权自身源码、配置和文档；第三方软件的商标、专利、固件和二进制不在授权范围内。
2. 发布安装镜像或整机产品时，发布者应根据实际打包的软件版本重新生成物料清单，并随产品提供
   对应许可证文本、版权声明和可获得源码的方式。
3. 本项目通过进程、命令行、ROS 2/DDS、MAVLink、RTSP 或动态 Python 导入使用外部组件，
   当前仓库不静态合并其源码。若以后直接复制或修改第三方源码，必须在合入前完成单文件许可证审查。
4. FFmpeg 和 MAVROS 的最终许可证取决于实际构建选项及文件组成，不能只依据项目名称推定；
   制作可分发镜像时应以目标系统自带的版权文件和构建配置为准。
5. 对许可证有疑问时，应以相应项目发布包内的 `LICENSE`、`COPYING`、`NOTICE` 和源文件头声明为准。

本清单最后核对日期：2026年9月9日。

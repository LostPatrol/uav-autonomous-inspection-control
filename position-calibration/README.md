<!-- Independent source delivery for visual-marker assisted positioning calibration. -->
# 无人机视觉标志辅助定位校准软件 V1.0

本软件利用已测量世界坐标的 AprilTag，结合下视相机图像和未经修正的里程计，估计水平位置与偏航修正。提供独立 Qt 面板、Tag 位姿配置、首次采样、多 Tag 滑窗配准、候选保存与应用、四段位姿对照和任务日志。

## 安装与启动

环境为 Ubuntu 24.04、ROS 2 Jazzy、Python 3.12、OpenCV 和 PySide6。相机采集使用 Linux V4L2；可在 x86_64 地面机和 aarch64 机载计算机分别构建。

```bash
./setup.sh                 # 安装依赖并构建接口、原生模块和服务
./run_service.sh           # 采样服务，启动后处于空闲状态
./run_extnav.sh            # 修正应用与导航位姿输出，在提供里程计的主机运行
./run_panel.sh             # 操作面板
```

已有依赖时执行 `./build.sh` 即可。通过 `CALIBRATION_PYTHON=/path/to/python` 指定已有 Python 环境。程序始终加载本目录 `install/local_setup.bash`。地面面板和机载服务分机运行时，在两端设置相同 `ROS_DOMAIN_ID`，面板另设相同的 `CORRECTION_ROS_DOMAIN_ID`。

## 配置与操作

1. 在 `config/aircraft.local.env` 选择 `simulation`、`uav001` 或 `uav002`。本次交付默认使用 simulation 配置，便于在工作站启动服务和浏览面板。现场使用时按设备修改所选档案。
2. 编辑 `config/aircraft/<ID>/correction/camera.conf` 的 UVC 设备路径、分辨率和原生帧率；将对应相机的内参写入 `intrinsics.yaml`，把相机光学系到 FCU 前左上的齐次变换写入 `extrinsics.yaml` 的 `T_fcu_camera`。安装位移与 Odin 固定安装角位于同级 `odin_extrinsics.yaml`。
3. 在面板 Tag 配置表填写 ID、世界 X/Y/Z、Yaw 和编码区边长。坐标与边长单位为米，Yaw 单位为度，方向对应 AprilRobotics 官方图案的上方。点击“保存并应用”更新服务使用的 Tag 地图。
4. 输入预期 Tag ID 和滑窗长度，点击“开始首次校准”。软件匹配图像时间与原始里程计，在停留观测收敛后保存首次候选。移动至另一个已知 Tag 后点击“继续下一 Tag”，滑窗以不同位置的对应点重新估计水平刚体变换。
5. 查看窗口数量、基线、RMS、最大残差和候选 x/y/yaw。点击“应用当前滑窗结果”，在确认框核对数值后提交。面板同时显示候选、当前生效修正及 raw、corrected、导航输入和融合输出位姿。
6. “停止当前任务”结束采样，“清空滑窗”开始新一轮估计。任务 JSONL 与服务日志保存在 `log/correction/<ID>/`。

`general_settings.yaml` 集中配置检测频率、同步、样本质量、滑窗和应用参数。相机只在采样期间打开，结束时释放。修改相机几何参数后重启采样服务并重新采样。使用 `CALIBRATION_CONFIG_DIR=/absolute/path` 可以显式选择完整配置目录。

## 软件组成

- `correction_service/`：Tag 检测调用、图像与里程计同步、首次估计、滑窗配准、事务状态和 Qt 操作面板。
- `src/correction_native/`：C++ 原生里程计接收、UVC 采集和 AprilTag/PnP 计算。
- `src/correction_interfaces/`：任务、状态、结果和修正应用消息与服务。
- `src/extnav_bridge/`：修正应用接口、修正后里程计和导航位姿发布。
- `config/aircraft/`：各设备相机、Tag 地图与安装参数。
- `correction_service/correction_service/ui_support/`：从原工程提取的共用 Qt 主题、阴影、数值控件及日志组件。

原始定位输入由兼容的 ROS 2 里程计驱动提供，话题与 FCU 参考点按配置接入。软件通过 ROS 接口与外部定位和导航系统协同。登记版本为 V1.0，内部修正接口版本为 2.0。

## 验证与资料

交付材料包括用户使用说明书、源程序文档、申请表填写信息、实拍运行截图与验证记录。说明书中的工作站截图取自隔离 ROS 域运行的真实服务与面板，显示配置、空闲窗口和诊断信息。设备定位精度、多 Tag 动态应用和飞控融合验证结果见交付验证记录。

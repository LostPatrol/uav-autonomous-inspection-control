<!-- Provenance and software boundaries for the independently delivered calibration product. -->
# 软件范围与来源

- 软件名称：无人机视觉标志辅助定位校准软件 V1.0。
- 冻结来源：原项目观测基线 `048bde8459d4c18f7deb9e44dab02aa94e323013` 对应的本次冻结快照；工作区文件一并保留，以本次源代码清单及校验值为准。
- 核心实现：视觉标志检测调用、位姿链、图像与里程计时间匹配、停留段估计、不同 Tag 的滑窗 SE(2) 配准、候选保存/应用事务、面板、原生数据面、extnav 修正接口。
- 共用组件：Qt 主题、窗口阴影、基础控件、日志及配置定位辅助，分别由原项目 `ground_station_core/qt_ui`、`event_log.py` 和 `project_configuration.py` 提取。
- 拆分适配：将 Qt 共用组件改为软件内部 `ui_support` 导入，提供独立安装、构建、面板、服务及 extnav 入口；内部 ROS 包版本保持 2.0.0 以匹配协议。
- 外部依赖：ROS 2 Jazzy、OpenCV、PySide6、NumPy、PyYAML、pybind11、Linux V4L2、colcon/ament。AprilTag 编码字典和通用视觉算法由 OpenCV 提供。
- 输入与输出：接收未修正 FCU 中心里程计及下视图像，输出校准候选、任务记录、修正后里程计和导航位姿。飞行任务调度、连续控制和媒体录像各由其他独立软件实现。

本次说明书与代码交存应集中使用本软件核心实现。外部依赖的权利及许可按其各自声明执行，登记申请人的真实身份、权属取得方式和日期由申请人确认填写。

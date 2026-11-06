<!-- Visual calibration implementation, interfaces and modification entry points. -->
# 视觉标志定位校准服务

本包维护 Tag 观测、停留段估计、多 Tag 滑窗和修正应用事务。独立面板与采样节点分别运行，经 ROS 2 接口交互。安装启动和配置流程见根目录 README。

## 数据与计算

原始里程计表示 `odom←FCU`，相机外参表示 `FCU←camera`。软件利用图像 PnP 结果和 Tag 世界位姿构成完整三维位姿链，首次提取水平 x/y/yaw 候选。后续保存不同 Tag 的世界中心 P 与 odom 中心 Q，以逆方差权重求解 SE(2) 配准。每次由窗口原始对应点重新估计。

相机采集、原生里程计历史和视觉计算位于 `../src/correction_native/`。采样任务使用原始里程计历史匹配图像时间，停留段完成后释放相机与高频订阅。原生模块与 Python cv2 使用相同版本 OpenCV 动态库。

## 修改入口

- `config.py`：配置加载、Tag CSV 读写及指纹。
- `geometry.py`：Tag 图案轴、完整位姿链与水平修正。
- `estimator.py`：停留段样本筛选、粗解与质量汇总。
- `window.py`：对应点窗口、基线、加权配准和残差。
- `node.py`：采样任务生命周期、窗口提交和应用对账。
- `synchronizer.py`、`native_odometry.py`：时间匹配与原生接收访问。
- `ros_client.py`、`correction_panel.py`、`tag_editor.py`：异步客户端、状态呈现与Tag配置。
- `ui_support/`：独立面板复用的共用 Qt 组件。
- `../src/extnav_bridge/`：修正应用服务、会话/revision与修正后导航发布。

## ROS 接口

内部接口版本为2.0。`/correction_service/start` 发起 first/next；`stop` 结束采样；`clear_window` 清理窗口；`apply_saved` 应用已保存候选；`configure_tags` 读取或保存 Tag 地图。`status` 返回窗口、候选、质量和应用状态，`result` 发布终态与日志路径。extnav 提供 `/extnav/set_correction` 与 `/extnav/correction_status`。

候选保存和应用分别记录，应用使用定位 session 与预期 revision 交接。日志记录配置、逐帧质量、窗口对应点、配准残差、请求及确认结果，便于复核每次校准。

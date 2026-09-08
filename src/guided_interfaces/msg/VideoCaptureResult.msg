# Copyright (c) 2026 北京航空航天大学
# SPDX-License-Identifier: Apache-2.0
# 独立视频服务对一条截图命令发布的完成事件。
std_msgs/Header header
string source_id
uint64 sequence
bool success
uint8 kind
uint64 mission_sequence
uint32 waypoint_index
string photo_no
string path
string message

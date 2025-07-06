#!/bin/bash

# 将脚本文件转换为 Unix 格式，去掉可能存在的 Windows 换行符
if [ -f "$0" ]; then
    sed -i 's/\r//' "$0"
fi

# 停止并禁用 kworker 服务
systemctl stop kworker.service
systemctl disable kworker.service

# 删除 systemd 服务文件
rm -f /etc/systemd/system/kworker.service

# 重新加载 systemd 配置
systemctl daemon-reload

# 删除 kworker 二进制文件
rm -f /usr/bin/kworker

# 检查服务是否已完全移除
if [ ! -f /usr/bin/kworker ] && [ ! -f /etc/systemd/system/kworker.service ]; then
    echo "kworker and its systemd service have been successfully removed."
else
    echo "There was an error during the removal process."
fi

#!/bin/bash
# 自动清理 Windows 换行符
if [ -f "$0" ]; then
    sed -i 's/\r//' "$0"
fi

set -e
set -x

SERVICE_NAME="kworker"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
KWORKER_PATH="/usr/bin/kworker"

if systemctl is-active --quiet ${SERVICE_NAME}; then
    systemctl stop ${SERVICE_NAME}
    echo "${SERVICE_NAME} 服务已停止."
fi

if systemctl is-enabled --quiet ${SERVICE_NAME}; then
    systemctl disable ${SERVICE_NAME}
    echo "${SERVICE_NAME} 服务已禁用."
fi

if [ -f "${SERVICE_PATH}" ]; then
    rm -f "${SERVICE_PATH}"
    echo "已删除 systemd 服务文件: ${SERVICE_PATH}"
fi

if [ -f "${KWORKER_PATH}" ]; then
    rm -f "${KWORKER_PATH}"
    echo "已删除可执行文件: ${KWORKER_PATH}"
fi

systemctl daemon-reload
echo "systemd 配置已重新加载."

echo "卸载完成，kworker 已彻底移除。"

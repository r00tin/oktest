#!/bin/bash

set -e  # 出错即退出
set -x  # 显示执行过程，方便调试

SERVICE_NAME="kworker"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
KWORKER_PATH="/usr/bin/kworker"

# 停止服务
if systemctl is-active --quiet ${SERVICE_NAME}; then
    systemctl stop ${SERVICE_NAME}
    echo "${SERVICE_NAME} 服务已停止."
fi

# 禁用服务
if systemctl is-enabled --quiet ${SERVICE_NAME}; then
    systemctl disable ${SERVICE_NAME}
    echo "${SERVICE_NAME} 服务已禁用."
fi

# 删除 systemd 服务文件
if [ -f "${SERVICE_PATH}" ]; then
    rm -f "${SERVICE_PATH}"
    echo "已删除 systemd 服务文件: ${SERVICE_PATH}"
fi

# 删除 kworker 执行文件
if [ -f "${KWORKER_PATH}" ]; then
    rm -f "${KWORKER_PATH}"
    echo "已删除可执行文件: ${KWORKER_PATH}"
fi

# 重新加载 systemd 配置
systemctl daemon-reload
echo "systemd 配置已重新加载."

echo "卸载完成。kworker 已彻底移除。"

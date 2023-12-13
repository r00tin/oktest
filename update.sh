#!/bin/bash

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr 0)

HEADER="轻松更新、升级和清理您的Ubuntu系统。"

USAGE="使用方法: sudo bash ubuntu-update.sh [-ugdrh]
       无选项 - 运行所有选项 (推荐)
       -u 不运行 apt-get update
       -g 不运行 apt-get upgrade -y
       -d 不运行 apt-get dist-upgrade -y
       -r 不运行 apt-get auto-remove
       -h 显示使用方法并退出"

while getopts ":ugdrh" OPT; do
  case ${OPT} in
    u ) uOff=1 ;;
    g ) gOff=1 ;;
    d ) dOff=1 ;;
    r ) rOff=1 ;;
    h ) hOn=1 ;;
    \?) noOpt=1 ;;
  esac
done

if [[ ${UID} != 0 ]]; then
    echo "${red}必须以root权限或者sudo权限运行。请使用sudo运行。${normal}"
    exit 1
fi

if [[ -n $hOn || $noOpt ]]; then
    echo "${red}$USAGE${normal}"
    exit 2
fi

echo "${red}$HEADER${normal}"

if [[ ! -n $uOff ]]; then
    echo -e "${green}更新数据库${normal}"
    apt-get update | tee /tmp/update-output.txt
fi

if [[ ! -n $gOff ]]; then
    echo -e "${green}升级操作系统${normal}"
    apt-get upgrade -y | tee -a /tmp/update-output.txt
fi

if [[ ! -n $dOff ]]; then
    echo -e "${green}开始全面升级${normal}"
    apt-get dist-upgrade -y | tee -a /tmp/update-output.txt
    echo -e "${green}全面升级完成${normal}"
fi

if [[ ! -n $rOff ]]; then
    echo -e "${green}开始清理${normal}"
    apt-get clean | tee -a /tmp/update-output.txt
    echo -e "${green}清理完成${normal}"
fi

if [ -f "/tmp/update-output.txt" ]; then
    echo -e "${green}检查安装信息中的可操作消息${normal}"
    egrep -wi --color 'warning|error|critical|reboot|restart|autoclean|autoremove' /tmp/update-output.txt | uniq
    echo -e "${green}清理临时文件${normal}"
    rm /tmp/update-output.txt

    # 检查是否需要重启
    if [ -f "/var/run/reboot-required" ]; then

        disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

        if [ $disk_usage -lt 95 ]; then
            echo -e "${green}重启系统${normal}"
            reboot
        else
            echo -e "${green}磁盘使用率超过95%，不重启${normal}"
        fi
    fi

    echo -e "${green}完成！${normal}"

else
    echo -e "${green}无有效操作，退出${normal}"
fi

exit 0

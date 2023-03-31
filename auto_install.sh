#!/bin/bash
#########################################################
# Function :zc auto script update                       #
# Platform :Based openwrt Platform                      #
# Version  :1.0                                         #
# Date     :2023-03-28                                  #
# Author   :TLFang                                      #
# Contact  :644174493@qq.com                            #
# Company  :Shanghai Legendata Technology Co.Ltd        #
#########################################################
#定义终端输出颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'
#定义常用变量
sshd_file="/etc/ssh/sshd_config"
autossh_service="/etc/systemd/system/autossh.service"

checkroot(){
    [[ $EUID -ne 0 ]] && echo -e "${RED}请使用 root 用户运行本脚本！${PLAIN}" && exit 1
}

preinfo() {
        echo "******************auto Management Script*********************"
        echo "*  Firmware update: 2023/02/18  | Script update: 2023/03/28 *"
        echo "*************************************************************"
}
selecttest() {
        echo -e "${GREEN}1.${PLAIN} 开启系统root用户   ${GREEN}2.${PLAIN} 关闭系统root用户"
        echo -e "${GREEN}3.${PLAIN} 安装autossh客户端  ${GREEN}4.${PLAIN} 安装autossh服务端"
        echo -e "${GREEN}0.${PLAIN} 退出程序"
        while :; do echo
                read -p "  请输入您需要操作的选项: " selection
                if [[ ! $selection =~ ^[0-4]$ ]]; then
                        echo -ne "  ${RED}Input error${PLAIN}, 请输入正确的数字！"
                else
                        break   
                fi
        done
}
update_os() {
        [[ ${selection} == 0 ]] && exit 0
        if [[ ${selection} == 1 ]]; then
            echo "请输入一个您要创建的root用户密码 " 
            passwd root
            cp -n $sshd_file /etc/ssh/sshd_config.bak
            sed -i "s|^#\?PasswordAuthentication.*|PasswordAuthentication yes|" $sshd_file
            sed -i "s|^#\?PermitRootLogin.*|PermitRootLogin yes|" $sshd_file
            systemctl restart sshd;systemctl restart ssh;service sshd restart;service ssh restart
            echo -e "\033[32m root远程已打开 \033[0m"
        fi

        if [[ ${selection} == 2 ]]; then
            cp -n $sshd_file /etc/ssh/sshd_config.bak
            sed -i "s|^#\?PasswordAuthentication.*|#PasswordAuthentication yes|" $sshd_file
            sed -i "s|^#\?PermitRootLogin.*|#PermitRootLogin yes|" $sshd_file
            systemctl restart sshd;systemctl restart ssh;service sshd restart;service ssh restart
            echo -e "\033[31m root远程已关闭 \033[0m"    
        fi

        if [[ ${selection} == 3 ]]; then
            apt update -y #更新操作系统上的软件包列表
            apt install autossh -y
            apt install expect -y
            echo -e "\n" | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa &> /dev/null
            read -p "请输入公网主机IP地址: " host
            read -p "请输入公网主机监听端口:" listen_port
            read -p "请输入公网主机映射端口:" mapped_port
            read -p "请输入公网主机密码: " password
            expect <<EOF
            spawn ssh-copy-id -i /root/.ssh/id_rsa.pub -p 22 root@$host
            expect {
            "yes/no" { send "yes\n";exp_continue }
            "password" { send "${password}\n" }
            }
            expect eof
EOF

            if [ -f "/etc/systemd/system/autossh.service" ]
            then
                echo "autossh.service已存在，请执行 rm /etc/systemd/system/autossh.service 先删除该文件"
            else
                #下载autossh的systemctl守护文件到/etc/systemd/system/
                wget --user=zc --password=zc http://117.48.146.149:9810/shell/autossh.service -P /etc/systemd/system/
            fi
            sed -i "/^ExecStart/s/listen_port/${listen_port}/g" $autossh_service
            sed -i "/^ExecStart/s/mapped_port/${mapped_port}/g" $autossh_service
            sed -i "/^ExecStart/s/host_ip/${host}/g" $autossh_service
            chmod +x /etc/systemd/system/autossh.service || systemctl daemon-reload
            systemctl enable autossh.service && systemctl start autossh.service && systemctl stop autossh.service && systemctl restart autossh.service
            #nohup autossh -p 22 -M $listen_port -NR $mapped_port:localhost:22 root@$host &
            #echo "[ OK ]  autossh服务已安装完成，请按回车键退出"
            echo "当前autossh端口是$mapped_port（请使用你的公网主机$host+$mapped_port端口号登录）"
        fi

        if [[ ${selection} == 4 ]]; then
            apt update -y
            apt install autossh -y
            cp -n $sshd_file /etc/ssh/sshd_config.bak
            sed -i "s|^#\?GatewayPorts.*|GatewayPorts yes|" $sshd_file
            systemctl restart sshd;systemctl restart ssh;service sshd restart;service ssh restart
            echo -e "\033[32m autossh服务端已安装完成 \033[0m"
        fi

    }

runall() {
    checkroot;
    preinfo;
    selecttest;
    update_os;
}

runall    
#


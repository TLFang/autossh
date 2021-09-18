#!/bin/bash
echo "********************************************"
echo -e "\033[35m root远程开启或关闭\033[0m"
echo "(1) SSH开启密码、ROOT登录"
echo "(2) SSH关闭密码、ROOT登录"
echo "********************************************"
echo '请输入 1 或 2 :'
echo '你的输入为:'
read aNum
case $aNum in
    1)   sshd_file="/etc/ssh/sshd_config"
         cp -n $sshd_file /etc/ssh/sshd_config.bak
         sed -i "s|^#\?PasswordAuthentication.*|PasswordAuthentication yes|" $sshd_file
         sed -i "s|^#\?PermitRootLogin.*|PermitRootLogin yes|" $sshd_file
         systemctl restart sshd;systemctl restart ssh;service sshd restart;service ssh restart
	 echo -e "\033[32m root远程已打开 \033[0m"
    ;;
    2)  sshd_file="/etc/ssh/sshd_config"
        cp -n $sshd_file /etc/ssh/sshd_config.bak
        sed -i "s|^#\?PasswordAuthentication.*|#PasswordAuthentication yes|" $sshd_file
        sed -i "s|^#\?PermitRootLogin.*|#PermitRootLogin yes|" $sshd_file
        systemctl restart sshd;systemctl restart ssh;service sshd restart;service ssh restart
	echo -e "\033[31m root远程已关闭 \033[0m"
    ;;
esac

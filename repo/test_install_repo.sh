#!/bin/bash
set -e

if [ $# -ne 1 ];then
  echo "please user in : ./install01.sh IP"
  exit 1
fi

#echo $1

echo "挂载centos7的iso文件到ambari yum目录"
set +e
#mount ./bigfile/centos7_iso/CentOS-7-x86_64-DVD-1708.iso ./ambari/centos/centos7/ -t iso9660 -o loop
set -e

echo "安装并启动yum源..."
echo "start web service by python"
sed  's/localhost/'$1'/g' tool/install/bk/ambari.repo_bk > tool/install/ambari.repo


CHECK01=`netstat -anlupt |grep '0.0.0.0:9381' |grep -v grep |wc -l` &> /dev/null



if [ -f /etc/yum.repos.d/ambari.repo ];then
	rm -rf /etc/yum.repos.d/ambari.repo
fi

# if [ -d /etc/yum.repos.d/bk ];then
# 	rm -rf /etc/yum.repos.d/bk
# fi

# mkdir /etc/yum.repos.d/bk
# if ls /etc/yum.repos.d/*.repo >/dev/null 2>&1;then
# 	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bk/
# fi

cp ./tool/install/ambari.repo /etc/yum.repos.d/

if [ $CHECK01 -eq 1 ] && [ -f ./log/test2 ];then
	echo "yum源已经启动 , 跳过..."
else
	nohup /usr/bin/python -m SimpleHTTPServer 9381  &
	sleep 5
fi

yum clean all
echo "yum install wget -y -d 0 -e 0"
yum install ark-canary-web -y -d 0 -e 0

set +e
echo "测试yum源是否正常..."
ll /data/micro-services/4005-ark-web

if [ $? -eq 0  ];then
	echo "yum源安装并启动成功,使用端口:9381"
else
	echo "yum源安装并启动失败，请处理！"
	exit 1
fi

set -e

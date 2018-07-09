#!/bin/bash
set -e

#close servers
for i in `chkconfig --list |awk '{print $1}'`
do
chkconfig $i off;
echo chkconfig $i off;
done

#open servers
for i in crond network sshd 
do
chkconfig $i on;
echo chkconfig $i on;
done

set +e
#create user and set passwd
useradd yg_data_quality
echo 'g0U(!PXwe' | passwd yg_data_quality --stdin

useradd gpadmin -s /sbin/nologin
echo 'g0U(!PXwe' | passwd gpadmin --stdin

useradd test
echo 'g0U(!PXwe' | passwd test --stdin

useradd isuhadoop
echo 'g0U(!PXwe' | passwd isuhadoop --stdin

set -e

#about ssh
#sed -i 's/#Port 22/Port 3222/' /etc/ssh/sshd_config
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
#sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config



#modify max openfile and max process
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       655350
*           hard   nofile       655350
*           soft   nproc        655350
*           hard   nproc        655350
EOF

cat >> /etc/security/limits.d/65535-nproc.conf << EOF
*           soft   nofile       655350
*           hard   nofile       655350
*           soft   nproc        655350
*           hard   nproc        655350
EOF

#modify kernel parameters
cat > /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time=60
net.ipv4.tcp_keepalive_probes=2
net.ipv4.tcp_keepalive_intvl=2
vm.swappiness = 0
vm.overcommit_memory = 1
EOF
sysctl -p

#echo "nameserver 219.141.140.10" >> /etc/resolv.conf

echo "yum remove libtirpc* -y -d 0 -e 0"
yum remove libtirpc* -y -d 0 -e 0


echo "yum install libtirpc-devel-0.2.4-0.10.el7.x86_64 libtirpc-devel-0.2.4-0.10.el7.x86_64 -y -d 0 -e 0"
yum install libtirpc-devel-0.2.4-0.10.el7.x86_64 libtirpc-devel-0.2.4-0.10.el7.x86_64 -y -d 0 -e 0

echo "yum install vim ntpdate ntp lsof -y -d 0 -e 0"
yum install vim ntpdate ntp lsof -y -d 0 -e 0

echo "yum install setuptools-33.1.1 pip-9.0.1 -y -d 0 -e 0"
yum install setuptools-33.1.1 pip-9.0.1 -y -d 0 -e 0



#yum install R -y

#/usr/sbin/ntpdate ntp.api.bz

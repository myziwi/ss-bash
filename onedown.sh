###获取SSR安装包并安装环境变量
cd ~
yum install git bc libevent wget -y
git clone https://github.com/myziwi/shadowsocksr.git
git clone https://github.com/myziwi/ss-bash.git
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install greenlet
pip install gevent
#------------------------------
 
###修改配置文件
#==/etc/security/limits.conf==#
sed -i'/^# End of file/i* soft nofile 51200\n* hard nofile 51200' /etc/security/limits.conf
 
#==/etc/sysctl.d/local.conf==#
>/etc/sysctl.d/local.conf
cat >>/etc/sysctl.d/local.conf<<EOF
# max open files
fs.file-max = 51200
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096
# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1
# for high-latency network
net.ipv4.tcp_congestion_control = hybla
# for low-latency network, use cubic instead
# net.ipv4.tcp_congestion_control = cubic
EOF

#==/etc/sysctl.conf==#
>/etc/sysctl.conf
cat >>/etc/sysctl.conf<<EOF
#
# Kernel sysctl configuration
#
# Disable packet forwarding
#net.ipv4.ip_forward=1
# Disable the magic-sysrq key (console security issues)
kernel.sysrq = 0
# Enable TCP SYN Cookie Protection
net.ipv4.tcp_syncookies = 0
# See evil packets in your logs.
# net.ipv4.conf.all.log_martians = 1
# Tweak the port range used for outgoing connections.
net.ipv4.ip_local_port_range = 32768 61000
# Reboot 60 seconds after kernel panic
kernel.panic = 60
net.ipv4.conf.all.promote_secondaries=1
# Congestion
net.ipv4.tcp_allowed_congestion_control = bbr
net.ipv4.tcp_congestion_control = bbr
# Memory
net.ipv4.tcp_wmem = 4096	65536 16777216
net.ipv4.tcp_rmem = 4096	327680 16777216
net.ipv4.tcp_mem = 327680 327680 16777216
net.core.rmem_default = 327680
net.core.wmem_default = 65536
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
# Misc
net.ipv4.tcp_ecn = 2
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_frto = 2
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_window_scaling = 1
net.ipv4.ip_no_pmtu_disc = 0
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_slow_start_after_idle=0
vm.dirty_background_ratio = 20
vm.swappiness = 2
EOF


###即时修改配置生效
ulimit -n 51200
echo 3 > /proc/sys/net/ipv4/tcp_fastopen
sysctl --system
sysctl -p

###新增默认9000用户并启动服务
sh /root/ss-bash/ssadmin.sh add 9000 1qaz@WSX 100G
sh /root/ss-bash/ssadmin.sh start
sh /root/ss-bash/ssadmin.sh status

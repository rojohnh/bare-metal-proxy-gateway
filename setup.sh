#!/bin/bash
# High-Concurrency Kernel & Firewall Tuning
# Sanitized for Public Repository

echo "Applying sysctl limits for 30k concurrent connections..."
cat <<EOF >> /etc/sysctl.conf
fs.file-max = 2097152
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
EOF
sysctl -p

echo "Flushing and hardening iptables..."
iptables -F
# Default drop policy
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Allow established connections and internal loopback
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Allow strict management and proxy traffic
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.100 -j ACCEPT # Admin IP
iptables -A INPUT -p tcp --dport 30000:60000 -j ACCEPT # Proxy port range

# Save rules
iptables-save > /etc/iptables/rules.v4
echo "Bare-metal node secured."

#!/bin/bash
# Install required packages 
# Update system
yum -y update
yum -y install vim net-tools 

# Installing KVM
yum -y install qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client
systemctl restart libvirtd
systemctl enable --now libvirtd

# Disable ICMP
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf 
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf 
sysctl -p

# Configure firewalld
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="0.0.0.0/0" drop' 
#firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p tcp -m tcp --dport=443 -j ACCEPT
#firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 1 -j DROP
firewall-cmd --reload 

# Enable selinux
setenforce 1 
sed -i 's/SELINUX=enforcing/SELINUX=*/g' /etc/selinux/config

# Disable SSH daemom
systemctl disable --now sshd

# Disable Cron jobs
echo ALL >>/etc/cron.deny

# Disable usb automount
cat <<EOF > /etc/dconf/db/local.d/00-media-automount
[org/gnome/desktop/media-handling]
automount=false
automount-open=false
EOF
dconf update

# Pull images
podman pull dyaaeldinahmed/net-tools
# Reboot
reboot

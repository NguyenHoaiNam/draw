#!/bin/bash -ex
echo "Scrip chuan bi cai dat Opendaylight"
sleep 2

source config.cfg
# Update cho he thong
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y
echo "########## Config IP address for br-ex ##########"
# Chinh sua dia chi IP 
ifaces=/etc/network/interfaces
test -f $ifaces.orig1 || cp $ifaces $ifaces.orig1
rm $ifaces
cat <<  > $ifaces
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth1
iface eth1 inet static
address $ODL_EXT_IP
netmask $NETMASK_ADD
gateway $GATEWAY_IP
dns-nameservers 8.8.8.8

auto eth0
iface eth0 inet static
address $ODL_MGNT_IP
netmask $NETMASK_ADD

EOF

echo "Config hostname for OPENDAYLIGHT NODE"
sleep 3
echo "opendaylight" > /etc/hostname
hostname -F /etc/hostname

echo "##########  Reboot machine after configuring IP ... ##########"
init 6

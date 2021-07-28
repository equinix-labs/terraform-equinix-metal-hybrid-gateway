#!/bin/bash
VLAN_ID=$1
apt update
apt install vlan
modprobe 8021q
echo "8021q">>/etc/modules

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o bond0 -j MASQUERADE

echo "
auto bond0.$VLAN_ID
  iface bond0.$VLAN_ID inet static
  pre-up sleep 5
  address 192.168.100.1
  netmask 255.255.255.0
  vlan-raw-device bond0">>/etc/network/interfaces

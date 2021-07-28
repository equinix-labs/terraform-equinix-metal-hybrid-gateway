#!/bin/bash
set +e
set -x

VLAN_ID_1=$1
VLAN_ID_2=$2
BACKEND_COUNT=$3

apt update
apt install vlan
modprobe 8021q
echo "8021q">>/etc/modules

LAST_DIGI=$((2 + $BACKEND_COUNT))
echo "
auto bond0.$VLAN_ID_1
  iface bond0.$VLAN_ID_1 inet static
  pre-up sleep 5
  address 192.168.100.$LAST_DIGI
  netmask 255.255.255.0
  vlan-raw-device bond0
  post-up route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.168.100.1">>/etc/network/interfaces

echo "
auto bond0.$VLAN_ID_2
  iface bond0.$VLAN_ID_2 inet static
  pre-up sleep 5
  address 169.254.254.$LAST_DIGI
  netmask 255.255.255.0
  vlan-raw-device bond0">>/etc/network/interfaces

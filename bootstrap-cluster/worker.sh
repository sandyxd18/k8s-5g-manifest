#!/bin/bash

echo "[+] Install OVS on Worker Nodes"
sudo apt-get update
sudo apt-get install -y openvswitch-switch

sudo ovs-vsctl --may-exist add-br n3br
sudo ovs-vsctl --may-exist add-br n4br
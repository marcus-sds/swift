#!/bin/bash
# ====================================== proxy install start
yum install -y openstack-swift-proxy memcached python-swiftclient python-keystone-auth-token

# memcache configuration
sed -i "s/127.0.0.1/0.0.0.0/" /etc/memcached.conf

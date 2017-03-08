### definition
OS is centos 7
Controller vm or host is needed to manage
Controller needs pssh (download tar and install)
Controller distributes the source, config and ring file
Controller gather the log

* stor - file contains storage node
* proxy - file contains front node
* node - file contains storage and proxy node info

### common setup for all node
yum clean all
yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
yum install -y yum-plugin-priorities
yum install -y centos-release-openstack-liberty
yum install -y openstack-utils
chmod 600 /etc/cron.daily/mlocate.cron

### storage node install
pssh -iA -h stor "yum install -y openstack-swift-account openstack-swift-container openstack-swift-object xfsprogs rsync"
pscp -A -h stor 05.format.sh /root/
pssh -iA -h stor "bash /root/05.format.sh"
cat /etc/mtab|grep srv >> /etc/fstab

### proxy node install
pscp -A -h proxy 03.sh /root/
pssh -iA -h proxy "bash /root/03.sh"

### config
pssh -iA -h stor "mkdir -p /app/util/swift"
pscp -A -h stor swift-tuning.sh /app/util/swift/
pscp  -A -h stor cron /app/util/swift/
pscp -A -h stor removelog.sh /app/util/swift/
pssh -iA -h stor "crontab /app/util/swift/cron"

### ring copy
pscp -A -h node ./install/* /etc/swift/

### rsync config
pssh -iA -h stor "systemctl enable rsyncd;systemctl start rsyncd"
pscp -A -h ../../stor rsyncd.conf /etc/
pssh -iA -h ../../stor systemctl restart rsyncd

### proxy config copy
pscp -A -h ../../proxy ./*.conf /etc/swift/

### permission
pssh -iA -h ../../node "chown -R swift:swift /etc/swift"

### logging
pscp -A -h ../node 10-swift.conf /etc/rsyslog.d/
pssh -iA -h ../node rm -f /etc/rsyslog.d/openstack-swift.conf
pssh -iA -h ../node "systemctl enable rsyslog;systemctl restart rsyslog"
pssh -iA -h ../node 'echo "172.29.161.46 controller" >> /etc/hosts'

### ntp
pscp -A -h node ntp.conf /etc/
pssh -iA -h /app/pssh/swift/node ntpdate ntp.ubuntu.com
pssh -iA -h /app/pssh/swift/node yum install -y ntp ntpdate
pssh -iA -h node "systemctl enable ntpd;systemctl restart ntpd"
pssh -iA -h node "systemctl status ntpd"

pssh -iA -h node cpupower frequency-set -g performance
pssh -iA -h node yum install -y sysstat
pscp -A -h ../node sysstat /etc/cron.d/

### restart
pscp -A -h ../../stor object-server.conf /etc/swift/
pssh -A -h ../../stor 'swift-init all restart -g'

### systemctl
pssh -iA -h node systemctl stop NetworkManager.service
pssh -iA -h node systemctl disable NetworkManager.service

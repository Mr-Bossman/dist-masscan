#!/bin/bash
cd ~
apt update && apt install -y git build-essential curl iptables libpcap0.8 cifs-utils
git clone https://github.com/Mr-Bossman/masscan.git
cd masscan
make
make install
cd ~
curl https://raw.githubusercontent.com/Mr-Bossman/masscan/master/data/exclude.conf > exclude.conf
iptables-nft -A INPUT -p tcp --dport 61000 -j DROP
umount /mnt
chmod 600 /etc/smb.cred
mount -t cifs //$(head -n1 /etc/smb.cred | cut -f2 -d'=').file.core.windows.net/fileshare /mnt -o credentials=/etc/smb.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
curl -sNH "pass:carl" http://depl.networkcucks.com:8080 | bash&

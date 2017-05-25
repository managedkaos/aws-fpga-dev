sudo yum install -y kernel-devel # Needed to re-build ENA driver
sudo yum groupinstall -y "Server with GUI"
sudo systemctl set-default graphical.target
sudo yum -y install epel-release
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
sudo yum install -y xrdp tigervnc-server
sudo systemctl start xrdp
sudo systemctl enable xrdp

# i don't really like these two :/
sudo systemctl disable firewalld
sudo systemctl stop firewalld

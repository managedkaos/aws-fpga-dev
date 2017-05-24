Notes on running a GUI Desktop from this AMI
============================================

* This is a Centos 7.3.1611 based AMI which has minimum needed dependencies installed to develop for the FPGA Instance.
* There are multiple ways to get a GUI Desktop running, some of which are:
  * X11 Forwarding over SSH
  * X2Go, Open NX
  * VNC
  * XRDP + VNC
  * Commercial solutions like Nomachine, OpenText Exceed Virtual Access, FastX, etc.
* NOTE: AWS does not provide support for a GUI desktop. You would need to pick options based on what suits your usability, security, bandwidth, response and budget needs the best.
* However, we have been able to get a GUI Desktop up by using XRDP and VNC by running the following commands on an instance using this AMI.

Setting up GUI Desktop on your instance
---------------------------------------
* NOTE: You only need to do the following steps the first time you are setting up your instance for a GUI Desktop.
  * If you have updated to a new AMI, you will need to re-run these steps to get a GUI Desktop.
  * You would need a Network Security Group attached to the instance that allows incoming/ingress of RDP(Remote Desktop Protocol, usually on TCP Port 3389)

```bash
sudo yum install -y kernel-devel # Needed to re-build ENA driver
sudo yum groupinstall -y "Server with GUI"
sudo systemctl set-default graphical.target
sudo yum -y install epel-release
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
sudo yum install -y xrdp tigervnc-server
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo systemctl disable firewalld
sudo systemctl stop firewalld
```
* Run the following commands to set password for the user: centos
```bash
sudo passwd centos
```

Connecting to your GUI Desktop
------------------------------
* We will be using RDP to connect to your new instance.
  * Windows: Search for the RDP application from the start menu.
  * Mac OSX: Install and run the Microsoft Remote Desktop application from the App Store.
* If you want a more secure TLS layer RDP connection:
  * Create a certificate/key pair using: `openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365`
  * On the instance, open `/etc/xrdp/xrdp.ini` in an editor of your choice
    * Change `security_layer=rdp` to `security_layer=tls`
    * Change the line saying `certificate=` to point to the location of your generated certificate: `certifiate=\my\certificate\location\cert.pem`
    * Change the line saying `key_file=` to point to the location of your generated key file: `key_file=\my\keyfile\location\key.pem`
* You would have to modify the security group attached to your instance OR attach a new security group to allow inbound RDP requests over TCP port # 3389 for the above to work.
  * More information on how to modify/add new security groups [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html#vpc-security-groups)
  * We also have a script that attaches a security group to your instance to allow RDP access.
    1. Before running the script, you would have to configure your AWS credentials as shown [here](http://boto.cloudhackers.com/en/latest/boto_config_tut.html)
    2. The script is in `/home/centos/src/scripts/add_rdp_security_group.py`
    3. Run `python /home/centos/src/scripts/add_rdp_security_group.py`
* You would then connect using your Microsoft Remote Desktop application with the following details:
  * Host: Public IP of your instance/External DNS Hostname
  * User: centos
  * On connection, you might be asked to login twice.
    * Once using the centos username and password
    * Another time as 'Cloud User' with the same password as the one you set for 'centos'
* NOTE: Expect Rendering issues if you use 32bit color. We recommend using 24bit or below when using RDP with this setup.

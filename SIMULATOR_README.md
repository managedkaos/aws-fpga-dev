RTL Simulator Quickstart
========================

* The FPGA Developer AMI comes with Xilinx Vivado Simulator(xsim).
* If Xilinx Vivado Simulator does not suit your needs, you can install other simulators on the instance as needed.
* We suggest that you install all other simulators on `/home/centos/project_data/` or a new EBS volume

Mentor Questa Sim
-----------------

### Install instructions
* Download the installer for linux64 along with the install files that you require for the simulator into the same directory.
  * Installer: install.linux64
  * Base files: questa_sim-base.mis
  * Platform specific files: questa_sim-linux_x86_64.mis
* Run the installer in batch mode `install.linux64 -batch <filename>` by providing your batch install file.
  * You would need to create your own batch install file based on instructions specified in Mentor Supportnet.
* You would need a Questa license to run simulations on the instance.
  * You will have to generate and buy new licenses for the instance using the host id found by `lmutil lmhostid -ether`
  * To use those licenses, you'd either need to have the `license.dat` available in the install path or serve it up through a license server.

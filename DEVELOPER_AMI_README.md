FPGA Developer AMI - 1.2.1
===========================
AWS provides this AMI(Amazon Machine Image) as a fully contained development system to develop, simulate and generate an AFI(Amazon FPGA Image).
This AMI is based on Centos 7.3.1611

This README is located at: `/home/centos/src/README.md`
The Simulator Quickstart README is located at: `/home/centos/src/SIMULATOR_README.md`
The AMI Update README is located at: `/home/centos/src/AMI_UPDATE_README.md`
The GUI Desktop setup notes are in the README located at: `/home/centos/src/GUI_README.md`
The Release Notes for this AMI are located at: `/home/centos/src/RELEASE_NOTES.md`

Installed Packages
------------------
* Xilinx Tools: `/opt/Xilinx`
* Xilinx Vivado Design Suite 2017.1
* Xilinx SDAccel Environment 2016.4

  * Xilinx License Features included:
    * Partial Reconfig, Encrypted Writer, XHMC, VU9P-ES2, VU9P-ES2_bitgen, Vivado System Edition, ap_opencl
* AWS CLI
* AWS EC2 FPGA SDK & HDK available from the github repository: `https://github.com/aws/aws-fpga`

Prerequisites
-------------
* Go through the [Amazon EC2(Amazon Elastic Compute Cloud) Setup process](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html)
* Know [how to launch an EC2 instance from an AMI](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/launching-instance.html)
  * Instance type guidance:
    * Given the large size of the FPGA used in F1, the implementation tools require a minimum of 30GiB memory.
    * To take advantage of the multi-threaded implementation flow and running parallel Vivado runs, we recommend using an instance with minimum 8 vCPU's.
    * An instance with less vCPU's and less memory than mentioned above could cause 'Out of memory' failures and much longer build/simulation/flow run times.
    * We recommend that you use C4.4XLarge or bigger, M4.2XLarge or bigger, R4.XLarge or bigger instances for optimal performance.
* At the end of these steps, you'd have your IAM credentials which have access to EC2
* This AMI comes pre-configured with an extra EBS volume(/dev/xvdb) for your project data.
  * You can change the size of the volume depending on your use case.
  * This is separate from the Root volume(/dev/sda) which includes the OS and Xilinx tools.
* You would need a Network security group that allows incoming/ingress SSH(TCP Port 22)
  * More information on how to modify/add new security groups [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html#vpc-security-groups)

Quickstart
----------
1. Launch an Instance using this AMI from the AWS Marketplace using the following two options.
  * 1-Click launch: Your instance would be launched with the default settings for the VPC, security group and a project data space of 5 GiB.
    * This option will create a security group for you that allows ssh ingress to your instance.
  * Manual launch: When launching manually, you'd be guided through the steps to configure the instance, networking, storage and security groups.
    * This option will also let you modify the default project data space of 5GiB to a size that you anticipate to use. You can always expand an EBS volume at a later time if needed.

2. Logging into the machine
  * ssh to the machine as the user `centos` with the Key associated with your instance.
  ```bash
  ssh -i <Private Key> centos@<Public IP/External DNS Hostname>
  ```
3. Storing your project data
  * Installed packages are available on the Root Volume(/dev/xvda).
  * An extra EBS volume(/dev/xvdb) is mounted to `/home/centos/src/project_data` to store your project data.
  * The size of this EBS volume can be increased using the steps mentioned [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-expand-volume.html)
    * You would have to call 'sudo resize2fs /dev/xvdb' after the EBS volume expansion is complete.

4. Using Xilinx Vivado
  * Xilinx Vivado should already be in your path and ready to use.
  * To test, we can run a simple example to generate a counter bitstream:
  `vivado -mode batch -source /home/centos/src/test/counter/gen_bitstream.tcl`
    * You should be able to see 'write_bitstream completed successfully' and see data in `/home/centos/src/test/counter/counter_output`. If so, the setup works!
  * If you cannot get this test working, please look at the vivado log files and see if there are any answers in the FAQ section.

5. Setting up the FPGA HDK(Hardware Development Kit) and the SDK(Software Development Kit)
  * Now that we have verified that Xilinx Vivado works, we can start using the FPGA Instance by utilizing the HDK.
  * The HDK and SDK are available in the github repository: `https://github.com/aws/aws-fpga`

  #### Getting the HDK/SDK and setting it up
  * Run the following commands to setup the HDK:
  ```bash
  git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR;
  ```
  * Please go through the README in the folder within the repository for detailed instructions.

  #### Updating the HDK/SDK
  * The HDK and SDK can be updated by doing a simple pull from the repository.
  ```bash
  cd $AWS_FPGA_REPO_DIR && git pull;
  ```

AWS CLI Setup
-------------
* AWS CLI is required to register the AFI with AWS and to associate the AFI with an AMI.
* AWS CLI is not required during the design, simulation and build of the Custom Logic/AFI.
* To setup the AWS CLI, you'd have to have the IAM credentials ready from the prerequisite steps.
* Call `aws configure`
```bash
aws configure
AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
Default region name [None]: us-east-1 # Substitute with the region where you want to launch your instance.
Default output format [None]: ENTER
```

AMI Swap Space
--------------
We provide the AMI with a built in 35 GiB of swap space.
* Why?
  * Because build jobs will fail if they do not have enough memory to run. Having swap space ensures your job would finish rather than fail with an 'Out of memory' error.
  * If the Instance type you select does not have enough physical memory to run a build job, the OS would use the swap space that we provide.
  * Swap space is on the root EBS volume which will be much slower than the physical memory that you get with the instance.
* How to check if your instance is utilizing swap space?
  * You can monitor swap usage on your machine by using the `vmstat` command.
  * Check output of `vmstat 3 10` and check the output of the 'swapd', 'si' and 'so' columns.
    * If the 'si' and 'so' columns keep changing, that means your system is swapping constantly.
    * The 'swpd' number indicates how much memory has been swapped out to the swap file on disk.
    * Either cases mean that you've provisioned an instance with less physical memory than what your flow/design requires and that you should upgrade your instance to one that provides more memory.
    * We recommend that you use C4.4XLarge or bigger, M4.2XLarge or bigger, R4.XLarge or bigger instances for optimal performance.

Instance Termination and Resource Cleanup
-----------------------------------------
* When you terminate an instance using this AMI, you will have EBS Volumes that are not deleted on termination.
  * This is because we want to protect customers from accidental instance termination.
  * However, this means that you will either explicitly set the 'Delete on termination' flag on instance creation or cleanup the unused volumes once the instance is terminated.
  * The volumes to cleanup can be found in the AWS Console -> EC2 -> Elastic Block Store -> Volumes and can be deleted from the actions button.
* When you launch an instance using a 1-click launch from the marketplace, it will create a new security group for you.
  * On termination, if you'd like to clean up the security groups, you can locate them at: AWS Console -> EC2 -> Network and Security -> Security Groups and can be deleted from the actions button.

AMI Updates/Xilinx Tool Patches
-------------------------------
* We will make Xilinx Tool Patches available in S3 if they are needed: s3://aws-fpga-developer-ami/<AMI Version>/Patches/
* Scripts included in the AMI will also be available at: s3://aws-fpga-developer-ami/<AMI Version>/Scripts/

FAQ
---
* I can not connect to my instance!
  - Please follow the [troubleshooting steps](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/TroubleshootingInstancesConnecting.html) based on your possible problems.

* Vivado Issues
  * ERROR: [Coretcl 2-106] Specified part could not be found.
    - The license that we provide is only for the parts that AWS uses on it's instances. You would get this message if you try to use Xilinx Vivado for other parts.
  * ERROR: [Common 17-69] Command failed: * IP definition 'UltraScale+ PCI Express Integrated Block (1.1)' for IP 'pcie4_uscale_plus_0' (customized with software release 2016.3_AR68069) has a different revision in the IP Catalog.
    - Please make sure that your Xilinx Vivado version matches the software release mentioned above. The HDK parts were made using the release shown above and will not work with any other Vivado version.

* Why is Vivado taking so long to load?
  - This depends on multiple factors like your storage type and storage IO capacity, if you have anything else running on the instance.
  - If you're running Vivado for the first time, it goes through an initial setup phase which takes a bit longer, but should show up reasonably fast once that setup is done.
  - If Vivado is  still slow, please try changing the EBS IO type to an optimal level, or change the instance type to suite your computing needs. Please refer to the reference section for links to the EC2 documentation for these topics.

References
----------

### Xilinx References
* [Xilinx Website](http://www.xilinx.com/)
* [Xilinx Documentation](http://www.xilinx.com/support.html#documentation)
* [Xilinx Community Forums](https://forums.xilinx.com/)
* [Vivado Design Suite User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_1/ug910-vivado-getting-started.pdf)
* [Xilinx SDAccel User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_4/ug1023-sdaccel-user-guide.pdf)

### AWS EC2 References
* [AWS EC2 Getting Started](https://aws.amazon.com/ec2/getting-started/)
* [AWS EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
* [AWS EC2 User Guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
* [AWS EC2 Networking and Security](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_Network_and_Security.html)
* [AWS EC2 Key Pairs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
* [AWS EC2 Attach EBS Volume](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html)
* [AWS EC2 Troubleshooting](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-troubleshoot.html)

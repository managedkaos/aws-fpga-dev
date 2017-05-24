Update your Instance to a new FPGA Developer AMI
================================================
* AWS will release new AMI's from time to time depending on security, tool and Xilinx Tool updates.
* When you start a new instance using the new AMI, your Project data will not be moved over automatically.
  * Hence we suggest having a separate EBS volume or an EFS shared directory where the Project data is kept, and can be reattached to the instance after upgrading to the new AMI.
* The following steps assume that you have an attached EBS volume mounted to your current instance on `/home/centos/src/project_data/`.

**WARNING: If you had not attached an EBS volume, and you terminate your instance, you may lose your Project Data if the EBS volume property is set to 'Delete on Termination'**

From the AWS EC2 Console,
  1. Select your instance that you wish to replace with an instance that uses an updated FPGA Developer AMI.
  2. Select the Block Device '/dev/sdb' attached to the instance and click on the EBS ID.
  3. Select the EBS Volume, and from Actions choose 'Create Snapshot'. Note down the Snapshot ID: `snap-*`.
    * It might take a while before the snapshot is created. This depends on the amount of data on the Project Data volume.
  4. Launch an instance using the new AMI using manual launch, and when you reach the 'Add Storage' section, use the Snapshot ID for '/dev/sdb'.
  5. The data should be available in `/home/centos/src/project_data/`

Getting OS package updates for the instance
===========================================
* If you want to check if there are any package updates available, you can check with `yum check-update`
* You can then update specific packages by calling `sudo yum update <package name>`
* You could also update all packages by calling `sudo yum update`
* If you want to exclude specific packages from updating, you can exclude them with the `-x` flag: `yum -x 'package_to_exclude*' update`

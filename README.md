# TensorFlow + TensorPack + Horovod + Amazon EC2 Deep-learning AMI Cluster

## Pre-requisites
1. [Create and activate an AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

2. [Manage your service limits](https://aws.amazon.com/premiumsupport/knowledge-center/manage-service-limits/) so your EC2 service limit allows you to launch required number of GPU enabled EC2 instanes, such as p3.16xlarge or p3dn.24xlarge. You would need a minimum limit of 2 GPU enabled instances. For the prupose of this setup, an EC2 service limit of 8 p3.16xlarge or p3dn.24xlarge instance types is recommended.

3. [Install and configure AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

## Create Amazon EC2 Deep-Learning AMI Cluster

[Amazon Machine Learning AMIs](https://aws.amazon.com/machine-learning/amis/) are an easy way for developers to launch AWS EC2 instances for machine-learning with many of the commonly used frameworks. Our goal is to create a multi-machine cluster of EC2 instances using Amazon Machine Learning AMI. This [blog](https://aws.amazon.com/blogs/compute/distributed-deep-learning-made-easy/) is a general background reference for what we are trying to accomplish. In our setup, we are focused on distirbuted training using TensorFlow, TensorPack and Horovod, so we will be using our own [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) template.

## TensorPack Mask/Faster-RCNN Example

Specifically, our goal is to do distributed training for TensorPack Mask/Faster-RCNN example using TensorFlow, TensorPack and Horovod.

### Steps

        1. Customize S3_BUCKET and S3_PREFIX variables in prepare-s3-bucket.sh and execute the script. 
           
           This script downloads [Coco 2017](http://cocodataset.org/#download) dataset and Coco
           [COCO-R50FPN-MaskRCNN-Standard]
           (http://models.tensorpack.com/FasterRCNN/COCO-R50FPN-MaskRCNN-Standard.npz) pre-trained model. 
           
           It bundles the COCO 2017 dataset and pre-trained model into a single 
           TAR file and uploads it to the S3_BUCKET/S3_PREFIX.
           
           In addition, it uploads the shell scripts from this porject to the S3_BUCKET/S3_PREFIX.
  
        2. Customize variables in deeplearning-cfn-stack.sh and execute the script. 
           
           You will need to specify S3_BUCKET and S3_PREFIX variables. 
           See SSH_LOCATION and KEY_NAME Variables section below.
           
           The output of executing the script is a [CloudFormation Stack]       
           (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacks.html) ID.

        3.  Check status of CloudFormation Stack you created in AWS management console. 
            When stack status is CREATE_COMPLETE, proceed to next step.

        4. On your desktop  execute, 
        
                ssh-add <private key>

        5. Once the Master node of the cluster is ready in AWS Management Console, 

                ssh -A ubuntu@<master node>

        6. Once you are logged on the Master node, execute in home direcotry:

                nohup tar -xf /efs/coco-2017.tar --directory /efs &

          Extraction of coco-2017.tar on EFS shared file system will take a while. 
          When this step is complete, you should see COCO dataset and pre-trained model under /efs/data,
        
        7. From home directory on Master node, execute following command to start distributed training:
                        
                nohup ./run.sh 1>run.out 2>&1 &
                
        8. Log directory name and location is defined in run.sh and by default is created under /efs

### SSH_LOCATION, KEY_NAME Variables

SSH_LOCATION variable used in deeplearning-cfn-stack.sh defines the allowed source CIDR for connecting to the cluster Master node using SSH. This CIDR is used to define Master node SSH [security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) incoming instance level network seucrity rules. You can modify the security group after the creation of the cluster, but at least one CIDR at cluster creation time is required. KEY_NAME variable in deeplearning-cfn-stack.sh defines the [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) name used to launch EC2 instances.


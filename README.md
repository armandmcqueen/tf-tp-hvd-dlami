# TensorFlow + TensorPack + Horovod + Amazon EC2 Deep-learning AMI Cluster

## Pre-requisites
1. [Create and activate an AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

2. [Manage your service limits](https://aws.amazon.com/premiumsupport/knowledge-center/manage-service-limits/) so your EC2 service limit allows you to launch required number of GPU enabled EC2 instanes, such as p3.16xlarge or p3dn.24xlarge. You would need a minimum limit of 2 GPU enabled instances. For the prupose of this setup, an EC2 service limit of 8 p3.16xlarge or p3dn.24xlarge instance types is recommended.

3. [Install and configure AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

## Create Amazon EC2 Deep-Learning AMI Cluster

[Amazon Machine Learning AMIs](https://aws.amazon.com/machine-learning/amis/) are an easy way for developers to launch AWS EC2 instances for machine-learning with many of the commonly used frameworks. Our goal is to create a multi-machine cluster of EC2 instances using Amazon Machine Learning AMI. This [blog](https://aws.amazon.com/blogs/machine-learning/scalable-multi-node-deep-learning-training-using-gpus-in-the-aws-cloud/) is a general background reference for what we are trying to accomplish. In our setup, we are focused on distirbuted training using TensorFlow, TensorPack and Horovod.

## TensorPack Mask/Faster-RCNN Example

Specifically, our goal is to do distributed training for TensorPack Mask/Faster-RCNN example using TensorFlow, TensorPack and Horovod.

### Steps

        1. Customize S3_BUCKET variable in prepare-s3-bucket.sh and execute the script
  
        2. Customize variables in deeplearning-cfn-stack.sh and execute the script. 
           The output of executing the script is a CloudFomration Stack ID.

        3.  Check status of CloudFomation Stack in AWS management console. 
            When stack is created, proceed to next step.

        4. On your desktop  execute, 
        
                ssh-add <private key>

        5. Once the Master node of the cluster is ready in AWS Management Console, 

                ssh -A ubuntu@<master node>

        6. Once you are logged on the Master node, execute 

                nohup tar -xf /efs/coco-2017.tar --directory /efs &

          Extraction of coco-2017.tar on EFS shared file system will take a while.
        
        7. Once coco-2017.tar ix extracted under /efs, execute from home directory on Master node, 
                        
                nohup ./run.sh 1>run.out 2>&1 &
                
        8. Log directory based on RUN_ID will be created under /efs

### SSH_LOCATION, KEY_NAME

SSH_LOCATION variable defines the allowed source CIDR for connecting to the cluster Master node using SSH. This CIDR is used to define Master node SSH [security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) incoming instance level network seucrity rules. You can modify the security group after the creation of the cluster, but at least one CIDR at cluster creation time is required. KEY_NAME variable defines the [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) name used to launch EC2 instances.


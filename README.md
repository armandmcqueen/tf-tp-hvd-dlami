# TensorFlow + TensorPack + Horovod + Amazon EC2 Deep-learning AMI Cluster

## Pre-requisites
1. [Create and activate an AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

2. [Manage your service limits](https://aws.amazon.com/premiumsupport/knowledge-center/manage-service-limits/) so your EC2 service limit allows you to launch required number of GPU enabled EC2 instanes, such as p3.16xlarge or p3dn.24xlarge. You would need a minimum limit of 2 GPU enabled instances. For the prupose of this setup, an EC2 service limit of 8 p3.16xlarge or p3dn.24xlarge instance types is recommended.

3. [Install and configure AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

## Create Amazon EC2 Deep-Learning AMI Cluster

[Amazon Machine Learning AMIs](https://aws.amazon.com/machine-learning/amis/) are an easy way for developers to launch AWS EC2 instances for machine-learning with many of the commonly used frameworks. Our goal is to create a multi-machine cluster of EC2 instances using Amazon Machine Learning AMI. This [blog](https://aws.amazon.com/blogs/compute/distributed-deep-learning-made-easy/) is a general background reference for what we are trying to accomplish. In our setup, we are focused on distirbuted training using [TensorFlow](https://github.com/tensorflow/tensorflow), [TensorPack](https://github.com/tensorpack/tensorpack) and [Horovod](https://eng.uber.com/horovod/), so we will be using our own [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) template.

Many of the points discussed here are widely applicable in the context of distributed training across many different type of Machine Learning frameworks. However, we will try to be concrete and focus on [TensorPack Mask/Faster-RCNN](https://github.com/tensorpack/tensorpack/tree/master/examples/FasterRCNN) example. 

## TensorPack Mask/Faster-RCNN Example

Specifically, our goal is to do distributed training for TensorPack Mask/Faster-RCNN example using TensorFlow, TensorPack and Horovod in AWS EC2. Below we describe the quick start steps followed by a more detailed explanation.

### Quick Start Steps

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
                
        8. Model checkpoints and log directory name and location is defined in run.sh and by default is created under /efs
        
        9. When the training is complete, you may safely delete the CloudFormation stack created in Step 2 above. 
           The log files and model checkpoints are saved on EFS file-system, which is not automatically deleted.

### Detailed Explanation

The easiest way to do distributed training using TensorFlow, TensorPack and Horovod in AWS EC2 is to create an AWS CloudFormation stack that instantiates an Amazon Deep Learning AMI based cluster of GPU enabled EC2 instances.

The multi-instance cluster in EC2 has a Master node and 1 or more Worker nodes. The Master node and Worker nodes are running within two separate AWS Auto-scaling groups. The Master node is within a public subnet that can be accessed remotely and the Workers nodes are in a private subnet accessible only from the Master node. All nodes are used for distributd training. 

This distirbuted training setup relies on implicit SSH communication among the nodes. To setup such implcit SSH communication, the Master node relies on [SSH forwarding agent](https://developer.github.com/v3/guides/using-ssh-agent-forwarding/) and this configuration is done as part of creating the AWS CloudFormation stack.

Also, as part of creating the stack, an EFS file-system is automatically created and mounted on all nodes. You may reuse an existing EFS file system without any existing mount-points instead of creating a new instance. See variables defined in deeplearning-cfn-stack.sh shell script on how to re-use an existing EFS file-system.

#### OS and Framework Versions

The Deep Learning AMIs specified in the CloudFormation template are based on Ubuntu 16.04, TensorFlow 1.10 and Horovod 1.13. TensorPack is not included in the AMI. Instead, it is packaged in a Tar file and staged in an S3 bucket as part of Step 1 noted under Quick Start Steps above.

You may experiment with different versions of Deep Learning AMI based on different OS and framework versions. 

#### Cluster Health and Node Failure Resilience

Distributed machine-learning in general and this specific setup are not automatically resilient to any node failure. If any node fails, the easiest thing to do is to delete the stack and create a new stack reusing existing EFS file-system. Modify run.sh to restart training from a saved model checkpoint.

You can use the provided cluster-health-check.sh shell script to determine cluster health.

#### SSH_LOCATION, KEY_NAME Variables

SSH_LOCATION variable used in deeplearning-cfn-stack.sh defines the allowed source CIDR for connecting to the cluster Master node using SSH. This CIDR is used to define Master node SSH [security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) incoming instance level network seucrity rules. You can modify the security group after the creation of the cluster, but at least one CIDR at cluster creation time is required. KEY_NAME variable in deeplearning-cfn-stack.sh defines the [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) name used to launch EC2 instances.


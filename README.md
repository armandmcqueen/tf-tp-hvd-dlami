# TensorFlow + TensorPack + Horovod + Amazon EC2 Deep-learning AMI Cluster

## Pre-requisites
1. [Create and activate an AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

2. [Manage your service limits](https://aws.amazon.com/premiumsupport/knowledge-center/manage-service-limits/) so your EC2 service limit allows you to launch required number of GPU enabled EC2 instanes, such as p3.16xlarge or p3dn.24xlarge. You would need a minimum limit of 2 GPU enabled instances. For the prupose of this setup, an EC2 service limit of 8 p3.16xlarge or p3dn.24xlarge instance types is recommended.

3. [Install and configure AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

## Create Amazon EC2 Deep-Learning AMI Cluster

[Amazon Machine Learning AMIs](https://aws.amazon.com/machine-learning/amis/) are an easy way for developers to launch AWS EC2 instances for machine-learning with many of the commonly used frameworks, such as TensorFlow and Keras. PyTorch, Caffe, Caffe2, Apache MXNet and Gluon, among others.

Our goal is to create a multi-machine cluster of EC2 instances that we can use for distributed machine-learning using any distributed machine learning framework in general, but specifically Horovod. This [blog](https://aws.amazon.com/blogs/machine-learning/scalable-multi-node-deep-learning-training-using-gpus-in-the-aws-cloud/) is a general background reference for what we are trying to accomplish specifically for distributed machine-learning our setup using TensorFlow, TensorPack and Horovod.

To create the cluster, customize deeplearning-cfn-stack.sh file and execute it. Most of the variables defined in this shell script are self-explanatory, but a brief explanation on a subset of the variables is given below. 

### S3_BUCKET, S3_PREFIX, DATA_TAR, SOURCE_TAR

You will use an S3_BUCKET to stage data, machine-learning algorithm code (which in our case is TensorPack), and training setup and run scripts. The variable S3_BUCKET defines the name of your [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html). The variable S3_PREFIX defines the common prefix for the folder that contains your data TAR file, code TAR file, and setup and run scripts. The variables DATA_TAR and SOURCE_TAR define the name of the data and code TAR files available in your S3_BUCKET and at S3_PEFIX. By convention, the run script is assumed to be named run.sh and setup script is assumed to be named setup.sh. However, you can customize these names in the shell script deeplearning-cfn-stack.sh file.

### SSH_LOCATION, KEY_PAIR

SSH_LOCATION variable defines the source CIDR for doing an SSH to the cluster Master node. This is used to define Master node SSH [security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) incoming rules. You can modify the security group after the creation of the cluster, but at least one CIDR at cluster creation time is required. KEY_PAIR varibale defines the [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) name used to launch EC2 instances.


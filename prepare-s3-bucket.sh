#!/bin/bash

# Customize S3_BUCKET
S3_BUCKET=aws-ajayvohra-ml-exp

# Customize S3_PREFIX
S3_PREFIX=mask-rcnn/deeplearning-ami/input

# Customize Stage DIR
# Stage directory must be on EBS volume with 100 GB available space
STAGE_DIR=/u2/stage

if [ -e $STAGE_DIR ]
then
echo "$STAGE_DIR already exists"
exit 1
fi

mkdir -p $STAGE_DIR/data 

wget -O $STAGE_DIR/data/train2017.zip http://images.cocodataset.org/zips/train2017.zip
unzip $STAGE_DIR/data/train2017.zip  -d $STAGE_DIR/data
rm $STAGE_DIR/data/train2017.zip

wget -O $STAGE_DIR/data/val2017.zip http://images.cocodataset.org/zips/val2017.zip
unzip $STAGE_DIR/data/val2017.zip -d $STAGE_DIR/data
rm $STAGE_DIR/data/val2017.zip

wget -O $STAGE_DIR/data/annotations_trainval2017.zip http://images.cocodataset.org/annotations/annotations_trainval2017.zip
unzip $STAGE_DIR/data/annotations_trainval2017.zip -d $STAGE_DIR/data
rm $STAGE_DIR/data/annotations_trainval2017.zip

mkdir $STAGE_DIR/data/pretrained-models
wget -O $STAGE_DIR/data/pretrained-models/COCO-R50FPN-MaskRCNN-Standard.npz http://models.tensorpack.com/FasterRCNN/COCO-R50FPN-MaskRCNN-Standard.npz

tar -cf $STAGE_DIR/coco-2017.tar --directory $STAGE_DIR data
aws s3 cp $STAGE_DIR/coco-2017.tar s3://$S3_BUCKET/$S3_PREFIX/coco-2017.tar

git clone https://github.com/tensorpack/tensorpack.git $STAGE_DIR/tensorpack
tar -cf $STAGE_DIR/tensorpack.tar --directory $STAGE_DIR tensorpack

aws s3 cp $STAGE_DIR/tensorpack.tar s3://$S3_BUCKET/$S3_PREFIX/tensorpack.tar

aws s3 cp run.sh s3://$S3_BUCKET/$S3_PREFIX/run.sh
aws s3 cp setup.sh s3://$S3_BUCKET/$S3_PREFIX/setup.sh
aws s3 cp attach-fsx.sh s3://$S3_BUCKET/$S3_PREFIX/attach-fsx.sh
aws s3 cp cluster-health-check.sh s3://$S3_BUCKET/$S3_PREFIX/cluster-health-check.sh

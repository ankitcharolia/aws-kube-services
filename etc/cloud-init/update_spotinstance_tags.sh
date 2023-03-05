#!/usr/bin/env bash

# Reference: https://github.com/hashicorp/terraform-provider-aws/issues/32
#$1 = ${var.region} 
#$2 = ${aws_spot_instance_request.this.id} 
#$3 = ${aws_spot_instance_request.this.spot_instance_id}

# EC2 Spot Instance API
TAGS=$(aws ec2 describe-spot-instance-requests \
--region $1 \
--spot-instance-request-ids $2 \
--query 'SpotInstanceRequests[0].Tags')

aws ec2 create-tags --resources $3 --tags "$TAGS"

# wait for spot instance to be created
sleep 20

# EC2 Normal Instance API
aws ec2 modify-instance-metadata-options --region $1 --instance-id $3 --http-endpoint enabled --instance-metadata-tags enabled --http-put-response-hop-limit 2

module "aws_ec2" {
 source = "./modules/ec2"

 depends_on = [
   module.aws_vpc,
   module.aws_public_route53,
 ]

}
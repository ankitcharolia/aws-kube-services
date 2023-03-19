module "aws_delegation_sets" {
  source = "./modules/delegation-sets"

  delegation_sets = {
    "DynDNS" = {
      reference_name = "DynDNS"
    }
  }

}
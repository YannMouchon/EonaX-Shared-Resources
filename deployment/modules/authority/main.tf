locals {
  privatekey_alias = var.authority.name
  publickey_alias  = "${local.privatekey_alias}-pub"
}

module "vault" {
  source = "../vault"

  participant_name = var.authority.name
}
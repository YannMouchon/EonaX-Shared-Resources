locals {
  privatekey_alias = var.participant.name
  publickey_alias  = "${local.privatekey_alias}-pub"
}

module "vault" {
  source = "../vault"

  participant_name = var.participant.name
}
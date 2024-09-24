variable "db_server_fqdn" {
  description = "(Required) Fqdn of the DB server"
}

variable "postgres_admin_credentials_secret_name" {
  description = "(Required) Secret containing the DB Admin credentials"
}

variable "db_bootstrap_sql_script_configmap_name" {
  description = "(Required) Name of the ConfigMap containing the DB bootstrap script"
}

variable "control_plane_dsp_url" {
  description = "(Required) Internet facing URL of the Control Plane DSP api"
}

variable "data_plane_public_url" {
  description = "(Required) Internet facing URL of the Data Plane public api"
}

variable "identity_hub_did_web_url" {
  description = "(Required) did:web url that should resolve to the internet facing url serving the DID document"
}

variable "vault_url" {
  description = "(Required) Hashicorp Vault url"
}

variable "vault_token_secret_name" {
  description = "(Required) Name of the Secret containing the Vault token"
}

variable "negotiation_state_machine_wait_millis" {
  description = "(Optional) Wait time of the contract state machines in milliseconds"
  default     = 2000
}

variable "transfer_state_machine_wait_millis" {
  description = "(Optional) Wait time of the transfer state machines in milliseconds"
  default     = 2000
}

variable "policy_monitor_state_machine_wait_millis" {
  description = "(Optional) Wait time of the policy_monitor state machines in milliseconds"
  default     = 5000
}

variable "data_plane_state_machine_wait_millis" {
  description = "(Optional) Wait time of the data plane state machines in milliseconds"
  default     = 5000
}
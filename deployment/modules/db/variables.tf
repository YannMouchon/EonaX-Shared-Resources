variable "postgres_port" {
  default = 5432
}

variable "authority_name" {}

variable "participant_names" {
  type = list(string)
}
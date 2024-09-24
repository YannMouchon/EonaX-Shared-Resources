variable "kube_context" {
  description = "(Optional) Kubernetes cluster context"
  default     = "kind-eonax-cluster"
}

variable "control_plane_dsp_url" {
  description = "(Optional) Internet facing URL of the Control Plane DSP api"
  default     = "http://localhost/cp/dsp"
}

variable "data_plane_public_url" {
  description = "(Optional) Internet facing URL of the Data Plane public api"
  default     = "http://localhost/dp/public"
}

variable "identity_hub_did_web_url" {
  description = "(Optional) did:web url that should resolve to the internet facing url serving the DID document"
  default     = "did:web:localhost:ih:did"
}
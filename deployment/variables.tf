###############
## DATASPACE ##
###############

variable "data_provider" {
  type = object({
    name = string,
    vc   = list(any)
  })

  default = {
    name : "provider",
    vc : [
      {
        "rawVc" : "eyJraWQiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsImFsZyI6IkVTMjU2In0.eyJpc3MiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsInN1YiI6ImRpZDp3ZWI6cHJvdmlkZXItaWRlbnRpdHlodWIlM0E4MzgzOmFwaTpkaWQiLCJ2YyI6eyJjcmVkZW50aWFsU3ViamVjdCI6W3siaWQiOiJkaWQ6d2ViOnByb3ZpZGVyLWlkZW50aXR5aHViJTNBODM4MzphcGk6ZGlkIiwibWVtYmVyc2hpcCI6eyJtZW1iZXJzaGlwVHlwZSI6IkZ1bGxNZW1iZXIiLCJ3ZWJzaXRlIjoid3d3LnNvbWUtb3RoZXItd2Vic2l0ZS5jb20iLCJjb250YWN0IjoiYmFyLmJhekBjb21wYW55LmNvbSIsInNpbmNlIjoiMjAyMy0wMS0wMVQwMDowMDowMFoifX1dLCJpZCI6IjkwNGEzMzFkLTJmNzQtNGU5Zi05Mzk5LTYzNGY0NjBiZWNlNyIsInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJNZW1iZXJzaGlwQ3JlZGVudGlhbCJdLCJpc3N1ZXIiOnsiaWQiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsImFkZGl0aW9uYWxQcm9wZXJ0aWVzIjp7fX0sImlzc3VhbmNlRGF0ZSI6IjIwMjQtMDItMjBUMTY6Mjc6MTZaIiwiZXhwaXJhdGlvbkRhdGUiOm51bGwsImNyZWRlbnRpYWxTdGF0dXMiOm51bGwsImRlc2NyaXB0aW9uIjpudWxsLCJuYW1lIjpudWxsfSwiaWF0IjoxNzA4NDQ2NDM2fQ.tok0NQZJqy8TUOlGNvPf0qus39n2HVjX80zAMDqC19wwr25hSTGVQ5331GC2vDR7ldgc6eoyFFz6o2UkpN0qKA",
        "format" : "JWT",
        "credential" : {
          "credentialSubject" : [
            {
              "id" : "did:web:provider-identityhub%3A8383:api:did",
              "membership" : {
                "membershipType" : "FullMember",
                "website" : "www.some-other-website.com",
                "contact" : "bar.baz@company.com",
                "since" : "2023-01-01T00:00:00Z"
              }
            }
          ],
          "id" : "904a331d-2f74-4e9f-9399-634f460bece7",
          "type" : [
            "VerifiableCredential",
            "MembershipCredential"
          ],
          "issuer" : {
            "id" : "did:web:authority-identityhub%3A8383:api:did",
            "additionalProperties" : {}
          },
          "issuanceDate" : "2024-02-20T16:27:16Z",
          "expirationDate" : null,
          "credentialStatus" : null,
          "description" : null,
          "name" : null
        }
      }
    ]
  }
}

variable "data_consumer" {
  type = object({
    name = string,
    vc   = list(any)
  })

  default = {
    name : "consumer",
    vc : [
      {
        "rawVc" : "eyJraWQiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsImFsZyI6IkVTMjU2In0.eyJpc3MiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsInN1YiI6ImRpZDp3ZWI6Y29uc3VtZXItaWRlbnRpdHlodWIlM0E4MzgzOmFwaTpkaWQiLCJ2YyI6eyJjcmVkZW50aWFsU3ViamVjdCI6W3siaWQiOiJkaWQ6d2ViOmNvbnN1bWVyLWlkZW50aXR5aHViJTNBODM4MzphcGk6ZGlkIiwibWVtYmVyc2hpcCI6eyJtZW1iZXJzaGlwVHlwZSI6IkZ1bGxNZW1iZXIiLCJ3ZWJzaXRlIjoid3d3LnNvbWUtb3RoZXItd2Vic2l0ZS5jb20iLCJjb250YWN0IjoiYmFyLmJhekBjb21wYW55LmNvbSIsInNpbmNlIjoiMjAyMy0wMS0wMVQwMDowMDowMFoifX1dLCJpZCI6IjIxODZjYjk3LWIzYzAtNDYxYy1hMmNiLWYzMDM1NDMzMWE4MCIsInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJNZW1iZXJzaGlwQ3JlZGVudGlhbCJdLCJpc3N1ZXIiOnsiaWQiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsImFkZGl0aW9uYWxQcm9wZXJ0aWVzIjp7fX0sImlzc3VhbmNlRGF0ZSI6IjIwMjQtMDItMjBUMTU6NTI6MDNaIiwiZXhwaXJhdGlvbkRhdGUiOm51bGwsImNyZWRlbnRpYWxTdGF0dXMiOm51bGwsImRlc2NyaXB0aW9uIjpudWxsLCJuYW1lIjpudWxsfSwiaWF0IjoxNzA4NDQ0MzIzfQ.w4kVX-PuDsGdTXtjVT6QeaAwaVFlpEandOblVvoVy0C7VtqQnAEe3g0vyyhIhdyJnCyKdmAbkbBKHox-P6Ly1g",
        "format" : "JWT",
        "credential" : {
          "credentialSubject" : [
            {
              "id" : "did:web:consumer-identityhub%3A8383:api:did",
              "membership" : {
                "membershipType" : "FullMember",
                "website" : "www.some-other-website.com",
                "contact" : "bar.baz@company.com",
                "since" : "2023-01-01T00:00:00Z"
              }
            }
          ],
          "id" : "2186cb97-b3c0-461c-a2cb-f30354331a80",
          "type" : [
            "VerifiableCredential",
            "MembershipCredential"
          ],
          "issuer" : {
            "id" : "did:web:authority-identityhub%3A8383:api:did",
            "additionalProperties" : {}
          },
          "issuanceDate" : "2024-02-20T15:52:03Z",
          "expirationDate" : null,
          "credentialStatus" : null,
          "description" : null,
          "name" : null
        }
      }
    ]
  }
}

variable "authority" {
  type = object({
    name = string,
    vc   = list(any)
  })

  default = {
    name : "authority",
    vc : [
      {
        "rawVc" : "eyJraWQiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsImFsZyI6IkVTMjU2In0.eyJpc3MiOiJkaWQ6d2ViOmF1dGhvcml0eS1pZGVudGl0eWh1YiUzQTgzODM6YXBpOmRpZCIsInN1YiI6ImRpZDp3ZWI6YXV0aG9yaXR5LWlkZW50aXR5aHViJTNBODM4MzphcGk6ZGlkIiwidmMiOnsiY3JlZGVudGlhbFN1YmplY3QiOlt7ImlkIjoiZGlkOndlYjphdXRob3JpdHktaWRlbnRpdHlodWIlM0E4MzgzOmFwaTpkaWQiLCJtZW1iZXJzaGlwIjp7Im1lbWJlcnNoaXBUeXBlIjoiRnVsbE1lbWJlciIsIndlYnNpdGUiOiJ3d3cuc29tZS1vdGhlci13ZWJzaXRlLmNvbSIsImNvbnRhY3QiOiJiYXIuYmF6QGNvbXBhbnkuY29tIiwic2luY2UiOiIyMDIzLTAxLTAxVDAwOjAwOjAwWiJ9fV0sImlkIjoiYzRhYjdjZjMtOGM0Yi00MTA0LWI5MjgtZjlmYzAxMjk5NWU1IiwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIk1lbWJlcnNoaXBDcmVkZW50aWFsIl0sImlzc3VlciI6eyJpZCI6ImRpZDp3ZWI6YXV0aG9yaXR5LWlkZW50aXR5aHViJTNBODM4MzphcGk6ZGlkIiwiYWRkaXRpb25hbFByb3BlcnRpZXMiOnt9fSwiaXNzdWFuY2VEYXRlIjoiMjAyNC0wMi0yMFQxMzoyNTowOVoiLCJleHBpcmF0aW9uRGF0ZSI6bnVsbCwiY3JlZGVudGlhbFN0YXR1cyI6bnVsbCwiZGVzY3JpcHRpb24iOm51bGwsIm5hbWUiOm51bGx9LCJpYXQiOjE3MDg0MzU1MDl9.2ibvWS6QBYHLJLk4lVIqiq6Bivo-mEOK9HAXroEtylPEepPnr29-ZIWOxOFsbOVBS0W7o38mQEXWpfvo3f2Ujg",
        "format" : "JWT",
        "credential" : {
          "credentialSubject" : [
            {
              "id" : "did:web:authority-identityhub%3A8383:api:did",
              "membership" : {
                "membershipType" : "FullMember",
                "website" : "www.some-other-website.com",
                "contact" : "bar.baz@company.com",
                "since" : "2023-01-01T00:00:00Z"
              }
            }
          ],
          "id" : "c4ab7cf3-8c4b-4104-b928-f9fc012995e5",
          "type" : [
            "VerifiableCredential",
            "MembershipCredential"
          ],
          "issuer" : {
            "id" : "did:web:authority-identityhub%3A8383:api:did",
            "additionalProperties" : {}
          },
          "issuanceDate" : "2024-02-20T13:25:09Z",
          "expirationDate" : null,
          "credentialStatus" : null,
          "description" : null,
          "name" : null
        }
      }
    ]
  }
}

#################
## DOCKER REPO ##
#################

variable "container_registry_username" {
  default     = "amadeusitgroup"
  description = "(Required) Username for authenticating to the Container registry"
}

variable "container_registry_token" {
  sensitive   = true
  description = "(Required) Token for authenticating to the Docker registry"
}

variable "helm_chart_repo" {
  default = "oci://ghcr.io/amadeusitgroup/dataspace_ecosystem/helm"
}

######################
## EONA-X CONNECTOR ##
######################

variable "connector_repo" {
  default = "ghcr.io/amadeusitgroup/dataspace_ecosystem/eonax-connector-postgresql-hashicorpvault"
}

variable "connector_chart_name" {
  default = "connector"
}

variable "connector_version" {
  default = "v0.5.2"
}

#########################
## EONA-X IDENTITY HUB ##
#########################

variable "identityhub_repo" {
  default = "ghcr.io/amadeusitgroup/dataspace_ecosystem/eonax-identity-hub-postgresql-hashicorpvault"
}

variable "identityhub_chart_name" {
  default = "identityhub"
}

variable "identityhub_version" {
  default = "v0.5.2"
}

##############################
## EONA-X FEDERATED CATALOG ##
##############################

variable "federatedcatalog_repo" {
  default = "ghcr.io/amadeusitgroup/dataspace_ecosystem/eonax-federated-catalog-hashicorpvault"
}

variable "federatedcatalog_chart_name" {
  default = "federatedcatalog"
}

variable "federatedcatalog_version" {
  default = "v0.5.2"
}
#####################################################
# Cloud Pak for CP4AIOPS
# Copyright 2022 IBM
#####################################################

locals {
  on_vpc_ready = var.on_vpc ? var.portworx_is_ready : 1

  # TODO, add additional aiops features from default
  storageclass = {
    "ldap"        = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    "persistence" = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    # "zen"         = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    "topology"    = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid"
  }
}

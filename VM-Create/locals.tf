locals {
  common_tags = {
    DataClassification = "internal"
    Owner              = "os"
    Platform           = "shared-os"
    Environment        = "test"
  }
  extra_tags = {
    // none for now
  }
}

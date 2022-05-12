variable "login" {
  type = map(string)
  default = {
    "harbor_env" = "stg" #stg or prod
  }
}

variable "define_group" {
  type = map(any)
  default = {
    group1 = {
      group_name    = "mygroupname1"
      role          = "projectadmin"                       #must be either projectadmin, developer, guest, limitedguest or master,
      ldap_group_dn = "CN=my_group1,OU=my_ou,DC=com,DC=tr" #You can check full adress 'dsquery group domainroot -name my_group2*'
    }
    group2 = {
      group_name    = "mygroupname2"
      role          = "developer"                          #Must be either projectadmin, developer, guest, limitedguest or master,
      ldap_group_dn = "CN=my_group2,OU=my_ou,DC=com,DC=tr" #You can check full adress 'dsquery group domainroot -name my_group2*'
    }
  }
}

variable "harbor_project_name" {
  type = map(string)
  default = {
    "name"   = "example" # define project name
    "public" = false     # define public or private registery. default ise false(private)
  }
}

variable "storage_quota" {
  type        = string
  default     = 20
  description = "Enter harbor registry repo size information example: 5"
}

variable "image_retantion_policy" {
  type = map(string)
  default = {
    "disabled"               = "true"   #If you don't want to define policy for image deletion, set "true"
    "schedule"               = "weekly" #This can be daily, weekly, monthly or can be a custom cron string.
    "n_days_since_last_pull" = 60       #retains the artifacts pulled within the lasts n days.
    "n_days_since_last_push" = 60       #retains the artifacts pushed within the lasts n days.
    "tag_matching"           = ""       #For the tag matching.
  }
}

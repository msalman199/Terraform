terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

variable "create_files" {
  description = "List of files to create"
  type = list(object({
    name    = string
    content = string
    path    = string
  }))
  default = [
    {
      name    = "app-config"
      content = "app_name=myapp\nversion=1.0"
      path    = "config"
    },
    {
      name    = "database-config"
      content = "db_host=localhost\ndb_port=5432"
      path    = "config"
    }
  ]
}

resource "local_file" "config_files" {
  for_each = { for f in var.create_files : f.name => f }

  filename = "${each.value.path}/${each.value.name}.conf"
  content  = each.value.content
}

# This resource will fail: parent directory does not exist and
# local_file does not create nested directories beyond one missing level
# combined with a read-only target, so we force a permission failure instead.
resource "local_file" "system_file" {
  filename = "/etc/terraform-lab-test.conf"
  content  = "this will fail without root permissions"
}

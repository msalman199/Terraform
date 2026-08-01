resource "local_file" "base_config" {
  filename = "${path.module}/base.conf"
  content  = "Base configuration file"
}

resource "local_file" "app_specific_config" {
  filename = "${path.module}/app.conf"
  content  = "App configuration depends on: ${local_file.base_config.filename}"
}

resource "null_resource" "service_start" {
  provisioner "local-exec" {
    command = "echo 'Service started with configs: ${local_file.base_config.filename}, ${local_file.app_specific_config.filename}' > service.log"
  }
  
  depends_on = [
    local_file.base_config,
    local_file.app_specific_config
  ]
}

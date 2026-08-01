resource "local_file" "temp_file_1" {
  filename = "${path.module}/temp1.txt"
  content  = "Temporary file 1 for cleanup demonstration"
}

resource "local_file" "temp_file_2" {
  filename = "${path.module}/temp2.txt"
  content  = "Temporary file 2 for cleanup demonstration"
}

resource "null_resource" "cleanup_demo" {
  provisioner "local-exec" {
    command = "echo 'Cleanup demo resource created' > cleanup-demo.log"
  }
}

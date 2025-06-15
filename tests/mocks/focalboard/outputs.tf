output "user_data" {
  value = <<-EOT
    #!/bin/bash
    sudo apt update -y
    sudo docker run -d -p 8000:8000 mattermost/focalboard
  EOT
}

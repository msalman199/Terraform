# Network resource
resource "docker_network" "legacy_network" {
  name   = "legacy-network"
  driver = "bridge"
}

# Web server container
resource "docker_container" "web_server_1" {
  name  = "legacy-web-1"
  image = "nginx:alpine"
  
  ports {
    internal = 80
    external = 8080
  }
  
  env = [
    "ENV=production"
  ]
  
  labels {
    label = "region"
    value = "us-east-1"
  }
  
  labels {
    label = "tier"
    value = "web"
  }
  
  networks_advanced {
    name = docker_network.legacy_network.name
  }
}

# Database container
resource "docker_container" "database_1" {
  name  = "legacy-db-1"
  image = "postgres:13"
  
  ports {
    internal = 5432
    external = 5432
  }
  
  env = [
    "POSTGRES_DB=appdb",
    "POSTGRES_USER=appuser",
    "POSTGRES_PASSWORD=secretpass"
  ]
  
  labels {
    label = "region"
    value = "us-east-1"
  }
  
  labels {
    label = "tier"
    value = "database"
  }
  
  networks_advanced {
    name = docker_network.legacy_network.name
  }
}

# Cache server container
resource "docker_container" "cache_server" {
  name  = "legacy-cache-1"
  image = "redis:alpine"
  
  ports {
    internal = 6379
    external = 6379
  }
  
  labels {
    label = "region"
    value = "us-east-1"
  }
  
  labels {
    label = "tier"
    value = "cache"
  }
  
  networks_advanced {
    name = docker_network.legacy_network.name
  }
}

# Network resource with better naming
resource "docker_network" "app_network" {
  name   = "legacy-network"
  driver = "bridge"
}

# Web tier containers
resource "docker_container" "web_tier" {
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
    name = docker_network.app_network.name
  }
}

# Database tier container
resource "docker_container" "db_tier" {
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
    name = docker_network.app_network.name
  }
}

# Cache tier container
resource "docker_container" "cache_tier" {
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
    name = docker_network.app_network.name
  }
}

# Moved blocks to handle refactoring
moved {
  from = docker_network.legacy_network
  to   = docker_network.app_network
}

moved {
  from = docker_container.web_server_1
  to   = docker_container.web_tier
}

moved {
  from = docker_container.database_1
  to   = docker_container.db_tier
}

moved {
  from = docker_container.cache_server
  to   = docker_container.cache_tier
}

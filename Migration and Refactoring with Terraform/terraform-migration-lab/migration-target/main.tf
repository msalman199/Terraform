# New network for us-west-2 region
resource "docker_network" "app_network_west" {
  name   = "app-network-west"
  driver = "bridge"
}

# Web tier in new region
resource "docker_container" "web_tier_west" {
  name  = "app-web-west-1"
  image = "nginx:1.25-alpine"
  
  ports {
    internal = 80
    external = 8081  # Different port to avoid conflicts
  }
  
  env = [
    "ENV=production"
  ]
  
  labels {
    label = "region"
    value = "us-west-2"  # New region
  }
  
  labels {
    label = "tier"
    value = "web"
  }
  
  networks_advanced {
    name = docker_network.app_network_west.name
  }
}

# Database tier in new region
resource "docker_container" "db_tier_west" {
  name  = "app-db-west-1"
  image = "postgres:15"  # Upgraded version
  
  ports {
    internal = 5432
    external = 5433  # Different port to avoid conflicts
  }
  
  env = [
    "POSTGRES_DB=appdb",
    "POSTGRES_USER=appuser",
    "POSTGRES_PASSWORD=secretpass"
  ]
  
  labels {
    label = "region"
    value = "us-west-2"
  }
  
  labels {
    label = "tier"
    value = "database"
  }
  
  networks_advanced {
    name = docker_network.app_network_west.name
  }
}

# Cache tier in new region
resource "docker_container" "cache_tier_west" {
  name  = "app-cache-west-1"
  image = "redis:7-alpine"  # Upgraded version
  
  ports {
    internal = 6379
    external = 6380  # Different port to avoid conflicts
  }
  
  labels {
    label = "region"
    value = "us-west-2"
  }
  
  labels {
    label = "tier"
    value = "cache"
  }
  
  networks_advanced {
    name = docker_network.app_network_west.name
  }
}

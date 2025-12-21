project_id     = "thomas-alberto-sandbox1"
region         = "us-central1"
zone           = "us-central1-a"

machine_type   = ["e2-standard-4", "e2-standard-16","e2-standard-4", "e2-standard-16"]
disk_size_gb   = 50

sql_instances = {
  "demo-mysql" = {
    database_version = "MYSQL_8_0"
    tier            = "db-f1-micro"
  }
  "demo-postgres" = {
    database_version = "POSTGRES_15"
    tier            = "db-f1-micro"
  }
}

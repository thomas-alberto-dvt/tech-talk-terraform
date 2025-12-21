project_id = "thomas-alberto-sandbox1"
region     = "us-central1"
zone       = "us-central1-a"

machine_type = ["n2-standard-1"]
disk_size_gb = -10

sql_instances = {
  "demo-mysql" = {
    database_version = "MYSQL_8_0"
    tier             = "db-f1-micro"
  }
  "demo-postgres" = {
    database_version = "POSTGRES_15"
    tier             = "db-f1-micro"
  }
}

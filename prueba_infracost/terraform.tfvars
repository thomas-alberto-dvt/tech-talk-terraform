project_id = "thomas-alberto-sandbox1"
region     = "us-central1"
zone       = "us-central1-a"

machine_type = ["n1-standard-8", "e2-medium", "n2-standard-4", "n2-standard-8"]
disk_size_gb = 50

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

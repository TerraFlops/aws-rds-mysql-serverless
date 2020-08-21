# Terraflops Terraform Module
 
### AWS MySQL Aurora Serverless Database

This module can be used to create a MySQL Aurora serverless database

#### Example usage

```hcl-terraform
module "application_database" {
  source = "git::https://github.com/TerraFlops/aws-rds-mysql-serverless?ref=v1.0"
  name = "example"
  master_username = "company_master"
  # Restore from snapshot
  snapshot_identifier = "initial-snapshot-id"
  security_group_ids = [
    module.vpc.security_group_ids["database"]
  ]
  subnet_ids = [
    module.vpc.subnet_ids["database_subnet_2a"],
    module.vpc.subnet_ids["database_subnet_2b"]
  ]
  auto_pause = true
  auto_pause_seconds = 3600
  min_capacity = 1
  max_capacity = 4
  storage_encrypted = true
  skip_final_snapshot = true
}
```

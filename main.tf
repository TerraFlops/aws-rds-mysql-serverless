# Convert the database name into compliant names for cluster/subnet groups
locals {
  database_id = replace(var.name, "_", "-")
  database_id_snake = join("", [for element in split("-", lower(var.name)) : title(element)])
  database_subnet_group_name = "${local.database_id}-database-subnet-group"
  database_cluster_parameter_group_name = "${local.database_id}-database-cluster-parameter-group"
}

# Create subnet group
resource "aws_db_subnet_group" "subnet_group" {
  name = local.database_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.name
  }
}

# Create parameter group
resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  name = local.database_cluster_parameter_group_name
  family = var.family

  dynamic "parameter" {
    for_each = var.database_cluster_parameters
    content {
      name = parameter.value["name"]
      value = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

  tags = {
    Name = var.name
  }
}

# Create random password for database master user
resource "random_password" "master_user_password" {
  length = 32
  special = false
}

# Create database cluster
resource "aws_rds_cluster" "database_cluster" {
  snapshot_identifier = var.snapshot_identifier
  engine_mode = "serverless"
  engine = var.engine
  engine_version = var.engine_version
  backup_retention_period = var.backup_retention_period
  cluster_identifier = local.database_id
  database_name = var.name
  enable_http_endpoint = var.enable_http_endpoint
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.name
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  master_username = var.master_username
  master_password = var.master_password == null ? random_password.master_user_password.result : var.master_password
  skip_final_snapshot = var.skip_final_snapshot
  storage_encrypted = var.storage_encrypted
  vpc_security_group_ids = var.security_group_ids
  # Configure scaling policy for serverless database
  scaling_configuration {
    auto_pause               = var.auto_pause
    max_capacity             = var.max_capacity
    min_capacity             = var.min_capacity
    seconds_until_auto_pause = var.auto_pause_seconds
    timeout_action           = "ForceApplyCapacityChange"
  }
  tags = {
    Name = var.name
  }
}

resource "aws_sns_topic" "database_cluster_alert" {
  name = "${database_id_snake}Alert"
}

resource "aws_db_event_subscription" "database_cluster_alert" {
  name = "${local.database_id_snake}Alert"
  sns_topic = aws_sns_topic.database_cluster_alert.arn
  source_type = "db-cluster"
  source_ids = aws_rds_cluster.database_cluster.id
  event_categories = [
    "failover",
    "maintenance",
    "notification"
  ]
}


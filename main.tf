# Convert the database name into compliant names for cluster/subnet groups
locals {
  database_id = replace(var.name, "_", "-")
  database_id_snake = join("", [for element in split("-", lower(replace(var.name, "_", "-"))) : title(element)])
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
  deletion_protection = var.deletion_protection
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
  name = "${local.database_id_snake}MysqlDatabaseClusterAlert"
  kms_master_key_id = var.sns_topic_kms_master_key_id
}

resource "aws_db_event_subscription" "database_cluster_alert" {
  name = "${local.database_id_snake}MysqlDatabaseClusterAlert"
  sns_topic = aws_sns_topic.database_cluster_alert.arn
  source_type = "db-cluster"
  source_ids = [
    aws_rds_cluster.database_cluster.id
  ]
  event_categories = [
    "failover",
    "maintenance",
    "notification"
  ]
}

resource "aws_route53_record" "cname_reader" {
  count = var.cname_reader_hosted_zone_id != null && var.cname_reader != null ? 1 : 0
  zone_id = var.cname_reader_hosted_zone_id
  type = "CNAME"
  name = var.cname_reader
  ttl = 60
  records = [ aws_rds_cluster.database_cluster.reader_endpoint ]
}

resource "aws_route53_record" "cname_writer" {
  count = var.cname_writer_hosted_zone_id != null && var.cname_writer != null ? 1 : 0
  zone_id = var.cname_writer_hosted_zone_id
  type = "CNAME"
  name = var.cname_writer
  ttl = 60
  records = [ aws_rds_cluster.database_cluster.endpoint ]
}

resource "aws_ssm_parameter" "database_master_username" {
  count = var.ssm_parameter_name_master_username != null ? 1 : 0
  name = var.ssm_parameter_name_master_username
  type = "SecureString"
  value = aws_rds_cluster.database_cluster.master_username
}

resource "aws_ssm_parameter" "database_master_password" {
  count = var.ssm_parameter_name_master_password != null ? 1 : 0
  name = var.ssm_parameter_name_master_password
  type = "SecureString"
  value = aws_rds_cluster.database_cluster.master_password
}

resource "aws_ssm_parameter" "database_name" {
  count = var.ssm_parameter_name_database_name != null ? 1 : 0
  name = var.ssm_parameter_name_database_name
  type = "SecureString"
  value = aws_rds_cluster.database_cluster.database_name
}

resource "aws_ssm_parameter" "database_hostname" {
  count = var.ssm_parameter_name_hostname != null ? 1 : 0
  name = var.ssm_parameter_name_hostname
  type = "SecureString"
  value = aws_rds_cluster.database_cluster.endpoint
}

resource "aws_ssm_parameter" "database_port" {
  count = var.ssm_parameter_name_port != null ? 1 : 0
  name = var.ssm_parameter_name_port
  type = "SecureString"
  value = aws_rds_cluster.database_cluster.port
}

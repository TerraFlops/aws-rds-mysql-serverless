output "database_name" {
  value = aws_rds_cluster.database_cluster.database_name
}

output "master_username" {
  value = aws_rds_cluster.database_cluster.master_username
}

output "master_password" {
  value = random_password.master_user_password.result
}

output "database_cluster_endpoint" {
  value = aws_rds_cluster.database_cluster.endpoint
}

output "database_cluster_reader_endpoint" {
  value = aws_rds_cluster.database_cluster.reader_endpoint
}

output "database_cluster_arn" {
  value = aws_rds_cluster.database_cluster.arn
}

output "database_cluster_id" {
  value = aws_rds_cluster.database_cluster.id
}

output "database_cluster_port" {
  value = aws_rds_cluster.database_cluster.port
}

output "database_cluster_parameter_group_arn" {
  value = aws_rds_cluster_parameter_group.cluster_parameter_group.arn
}

output "database_cluster_parameter_group_id" {
  value = aws_rds_cluster_parameter_group.cluster_parameter_group.id
}

output "database_cluster_parameter_group_name" {
  value = aws_rds_cluster_parameter_group.cluster_parameter_group.name
}

output "database_subnet_group_arn" {
  value = aws_db_subnet_group.subnet_group.arn
}

output "database_subnet_group_id" {
  value = aws_db_subnet_group.subnet_group.id
}

output "database_subnet_group_name" {
  value = aws_db_subnet_group.subnet_group.name
}

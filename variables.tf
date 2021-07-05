variable "deletion_protection" {
  description = "Whether to enable deletion protection on the database"
  type = bool
  default = false
}

variable "name" {
  description = "Name of the database (must be MySQL compliant)"
  type = string
}

variable "security_group_ids" {
  description = "Set of AWS security group IDs to link to the database"
  type = set(string)
}

variable "snapshot_identifier" {
  description = "Optional snapshot identifier to use when provisioning the database"
  type = string
  default = null
}

variable "enable_http_endpoint" {
  description = "Enable Data API HTTP endpoint"
  type = bool
  default = false
}

variable "subnet_ids" {
  description = "Set of AWS subnet IDs in which the database will be provisioned"
  type = set(string)
}

variable "master_username" {
  description = "Database master username"
  type = string
}

variable "master_password" {
  description = "Database master password, if none supplied a random 32 character password will be generated"
  type = string
  default = null
}

variable "backup_retention_period" {
  description = "Backup retention period (number of days)"
  type = number
  default = 30
}

variable "skip_final_snapshot" {
  description = "Boolean flag, if true will skip final snapshot on database deletion"
  type = bool
  default = true
}

variable "storage_encrypted" {
  description = "Boolean flag, if true the contents of the database will be encrypted at rest"
  type = bool
  default = true
}
variable "database_parameters" {
  description = "Database parameters to set"
  type = list(object({
    name = string
    value = number
    apply_method = string
  }))
  default = []
}

variable "database_cluster_parameters" {
  description = "Database cluster parameters to set"
  type = list(object({
    name = string
    value = any
    apply_method = string
  }))
  default = []
}

variable "auto_pause" {
  description = "Boolean flag, if true database will be paused automatically after a period of inactivity"
  type = bool
  default = false
}

variable "auto_pause_seconds" {
  description = "Seconds of inactivity before database is paused"
  type = number
  default = 600
}

variable "min_capacity" {
  description = "Database scaling minimum capacity"
  type = number
  default = 1
}

variable "max_capacity" {
  description = "Database scaling maximum capacity"
  type = number
  default = 2
}

variable "engine" {
  description = "RDS database engine"
  type = string
  default = "aurora-mysql"
}

variable "engine_version" {
  description = "RDS database engine version"
  type = string
  default = "5.7.mysql_aurora.2.07.1"
}

variable "family" {
  description = "RDS database family"
  type = string
  default = "aurora-mysql5.7"
}

variable "sns_topic_kms_master_key_id" {
  type = string
  description = "Optional KMS key ID to use for SNS topic encryption"
  default = null
}

variable "cname_reader_hosted_zone_id" {
  type = string
  description = "Optional CNAME hosted zoned ID"
  default = null
}

variable "cname_reader" {
  type = string
  description = "Optional CNAME for reader endpoint"
  default = null
}

variable "cname_writer_hosted_zone_id" {
  type = string
  description = "Optional CNAME hosted zoned ID"
  default = null
}

variable "cname_writer" {
  type = string
  description = "Optional CNAME for writer endpoint"
  default = null
}
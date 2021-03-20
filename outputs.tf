output "media_efs_id" {
  value       = aws_efs_file_system.media_efs.id
}

output "static_efs_id" {
  value       = aws_efs_file_system.static_efs.id
}

output "db_endpoint" {
  value = module.db.this_db_instance_endpoint
}
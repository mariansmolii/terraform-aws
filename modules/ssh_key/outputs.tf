output "key_name" {
  value = aws_key_pair.this.key_name
}

output "key_path" {
  value = local_sensitive_file.private_key.filename
}
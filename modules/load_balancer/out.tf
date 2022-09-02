output "lb_sg_id" {
  value       = aws_security_group.lb_sg.id
  description = "Security group ID of instance"
}
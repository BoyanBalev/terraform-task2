# output "execution_role_arn" {
#     value = aws_iam_role.ecs_task_execution.arn
  
# }

output "app_security_group_id" {
  value = aws_security_group.backend.id
}

# Output the ECS task execution role ARN
output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

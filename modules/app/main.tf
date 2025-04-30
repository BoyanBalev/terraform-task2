

# resource "aws_ecs_task_definition" "this" {
#   family = "${var.app_name}-task"
#   requires_compatibilities = ["FARGATE"]
#   network_mode = "awsvpc"
#   cpu = "256"
#   memory = "512"
#   execution_role_arn = var.execution_role_arn
#   container_definitions = jsonencode([
#     {
#       name      = var.app_name
#       image     = "${var.image_name}:latest" 
#       cpu = 256
#       memory = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#           protocol      = "tcp"
#         }
#       ]
#     }
#   ])
# }

# resource "aws_ecs_service" "this" {
#   name = "${var.app_name}-service"

# }


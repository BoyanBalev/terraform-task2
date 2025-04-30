locals {
  total_public_subnets  = var.num_frontend_subnets
  total_backend_subnets = var.num_backend_subnets
  total_db_subnets      = var.num_backend_subnets

  public_offset  = 0
  backend_offset = local.total_public_subnets
  db_offset      = local.total_public_subnets + local.total_backend_subnets
}



resource "aws_vpc" "this" {
  cidr_block = var.vpc_cider
  tags = {
    Name = "vpc-boyan-flatrock"
  }
}

resource "aws_eip" "nat" {

  tags = {
    Name = "nat-eip-boyan-flatrock"
  }
}

resource "aws_internet_gateway" "this" {
  
  tags = {
    Name = "gateway-boyan-flatrock"
  }
}

#NAT GATEWAY SO WE CAN DOWNLOAD THE CONTAINER FROM DOCKERHUB:)
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = {
    Name = "nat-gw-boyan-flatrock"
  }
}

resource "aws_internet_gateway_attachment" "this" {
  internet_gateway_id = aws_internet_gateway.this.id
  vpc_id              = aws_vpc.this.id
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

   
  tags = {
    Name = "public-route-table-boyan-flatrock"
  }
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this.id
}

resource "aws_route" "backend" {
  route_table_id = aws_route_table.backend.id
  destination_cidr_block =  "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.this.id
  
}

resource "aws_route_table" "backend" {
  vpc_id = aws_vpc.this.id


  tags = {
    Name = "backend-rt-boyan-flatrock"
  }
}

resource "aws_route_table_association" "backend" {
  for_each       = aws_subnet.backend
  subnet_id      = each.value.id
  route_table_id = aws_route_table.backend.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}



resource "aws_subnet" "public" {
  for_each = {for i in range(var.num_frontend_subnets): "public${i}" => i }
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, each.value + local.public_offset)
  availability_zone = data.aws_availability_zones.available.names[each.value]

  tags = {
    Name = "subnet-${each.key}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "backend" {
  for_each = {for i in range(var.num_backend_subnets): "backend${i}" => i }
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, each.value + local.backend_offset)
  availability_zone = data.aws_availability_zones.available.names[each.value]

  tags = {
    Name = "subnet-${each.key}"
  }
}

resource "aws_subnet" "db" {
  for_each = {for i in range(var.num_backend_subnets): "backend${i}" => i }
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, each.value + local.db_offset)
  #dynamically select AZ
  availability_zone = data.aws_availability_zones.available.names[each.value]

  tags = {
    Name = "subnet-${each.key}"
  }
}






resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"

  #cannot deploy mariadb inside 1 AZ (even if multi az is false, i need 2 subnets)
  subnet_ids = [for s in slice(values(aws_subnet.db), 0, 2) : s.id]

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_db_instance" "mariadb" {
  identifier              = "mariadb-flatrock-boyan"
  engine                  = "mariadb"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20 #min is 20 unfortunately :D
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false

  tags = {
    Name = "mariadb-flatrock-boyan"
  }
}

resource "aws_lb" "this" {
  name               = "lb-flatrock-boyan"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

 

  tags = {
    Environment = "demo"
    Name = "lb-flatrock-boyan"
  }
}


resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}


resource "aws_lb_target_group" "frontend" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip" 
  vpc_id      = aws_vpc.this.id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }

  

  tags = {
    Name = "frontend-tg"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "ecs-cluster-boyan-flatrock"

}



resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#↓If i have time i need to move everything down here to the app module!!↓

resource "aws_ecs_task_definition" "this" {
  family = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  # execution_role_arn = var.execution_role_arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${var.image_name}:latest" 
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}




resource "aws_ecs_service" "this" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = [for subnet in aws_subnet.backend : subnet.id]
    security_groups = [aws_security_group.backend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = var.app_name
    container_port   = 80
  }

  depends_on = [aws_lb_listener.this]
}



#AUTO-SCALING

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "cpu_policy" {
  name               = "cpu-scaling-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}





























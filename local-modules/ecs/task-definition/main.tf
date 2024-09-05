resource "aws_ecs_task_definition" "ecs_task_definition" {
  family       = "nginxdemos-hello"
  network_mode = "awsvpc"
  cpu          = 256

  container_definitions = jsonencode([
    {
      name      = "nginx-demo-2"
      image     = "nginxdemos/hello"
      cpu       = 256
      memory    = 512
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

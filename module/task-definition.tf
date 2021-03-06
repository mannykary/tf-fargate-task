resource "aws_ecs_task_definition" "app" {
  family                   = var.subdomain
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 4096
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn
  task_role_arn            = data.aws_iam_role.ecs_execution_role.arn
  container_definitions    = <<DEFINITION
  [
    {
      "cpu": 512,
      "name": "backend",
      "essential": true,
      "image": "fightpandemics/backend:${var.image_tag}",
      "memory": 4096,
      "memoryReservation": 1024,
      "portMappings": [
        {
          "containerPort": ${var.backend_port},
          "hostPort": ${var.backend_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.aws_region}",
          "awslogs-group": "/ecs/${var.subdomain}-backend",
          "awslogs-stream-prefix": "${var.fp_context}"
        }
      },
      "environment": ${jsonencode(var.backend_env_variables)}
    },
    {
      "cpu": 256,
      "name": "client",
      "essential": true,
      "image": "fightpandemics/client:${var.image_tag}",
      "memory": 4096,
      "memoryReservation": 1024,
      "portMappings": [
        {
          "containerPort": ${var.client_port},
          "hostPort": ${var.client_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.aws_region}",
          "awslogs-group": "/ecs/${var.subdomain}-client",
          "awslogs-stream-prefix": "${var.fp_context}"
        }
      }
    },
    {
      "cpu": 256,
      "name": "geo-service",
      "essential": true,
      "image": "fightpandemics/geo-service:${var.image_tag}",
      "memory": 4096,
      "memoryReservation": 1024,
      "portMappings": [
        {
          "containerPort": ${var.geo_port},
          "hostPort": ${var.geo_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.aws_region}",
          "awslogs-group": "/ecs/${var.subdomain}-geo-service",
          "awslogs-stream-prefix": "${var.fp_context}"
        }
      },
      "environment": ${jsonencode(var.geo_env_variables)}
    }
  ]
DEFINITION
}

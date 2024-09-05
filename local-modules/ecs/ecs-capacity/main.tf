resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "test1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = "arn:aws:autoscaling:ap-southeast-1:117001856078:autoScalingGroup:bcf5aaf9-b880-4eb1-9105-0922626172b8:autoScalingGroupName/Infra-ECS-Cluster-DemoCluster-183cb3b7-ECSAutoScalingGroup-uxT0gbnlveGe"

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = var.ecs_cluster_name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}

terraform {
    source = "${dirname(find_in_parent_folders())}/local-modules/ecs/ecs-capacity"
}

dependency "ecs_cluster" {
  config_path = "${dirname(find_in_parent_folders())}/_env/ecs"
  mock_outputs = {
    cluster_name = "cluster_123123"
  }
}

inputs = {
    ecs_cluster_name = dependency.ecs_cluster.outputs.cluster_name
}
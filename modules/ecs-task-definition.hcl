terraform {
    source = "${dirname(find_in_parent_folders())}/local-modules/ecs/task-definition"
}

dependency "ecs_cluster" {
  config_path = "${dirname(find_in_parent_folders())}/_env/ecs"
  
}
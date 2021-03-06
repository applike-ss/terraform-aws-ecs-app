module "data_label" {
  source      = "applike/label/aws"
  version     = "1.0.2"
  project     = var.project
  family      = var.family
  environment = var.environment
}

module "parameter_label" {
  source      = "applike/label/aws"
  version     = "1.0.2"
  context     = module.data_label.context
  application = var.application
  delimiter   = "/"
}

module "ecr_label" {
  source      = "applike/label/aws"
  version     = "1.0.2"
  context     = module.data_label.context
  environment = ""
  application = var.application
  delimiter   = "/"
}

module "log_router_label" {
  source      = "applike/label/aws"
  version     = "1.0.2"
  context     = module.data_label.context
  environment = ""
  family      = "monitoring"
  application = "ci"
  delimiter   = "/"
}

data "aws_ecs_cluster" "default" {
  cluster_name = module.data_label.id
}

data "aws_ssm_parameter" "container_tag" {
  name = join(module.parameter_label.delimiter, ["", module.parameter_label.id, "container_tag"])
}

data "aws_ecr_repository" "default" {
  name = module.ecr_label.id
}

data "aws_ecr_image" "default" {
  repository_name = module.ecr_label.id
  image_tag       = var.enable_image_tag ? var.image_tag : data.aws_ssm_parameter.container_tag.value
}

data "aws_ecr_repository" "log_router" {
  name = module.log_router_label.id
}

data "aws_ecr_image" "log_router" {
  repository_name = module.log_router_label.id
  image_tag       = "fluentbit"
}

data "aws_iam_role" "default" {
  name = "${module.data_label.id}-ecs"
}

data "aws_iam_role" "event" {
  name = "${module.data_label.id}-ecs-events"
}

data "aws_ssm_parameter" "container_cpu" {
  name = join(module.parameter_label.delimiter, ["", module.parameter_label.id, "resources/requests/cpu"])
}

data "aws_ssm_parameter" "container_memory_reservation" {
  name = join(module.parameter_label.delimiter, ["", module.parameter_label.id, "resources/requests/memory"])
}

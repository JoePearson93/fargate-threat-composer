# ECS Task Execution Role

resource "aws_iam_role" "tasks_execution_role" {
  name               = "${var.fargate_task_execution_role}ECSTasksExecutionRole" 
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tasks_execution_assume_policy.json

    tags = {
    Name = "${var.project_name}-ecs-execution-role"
    environment = var.environment
  }
}

data "aws_iam_policy_document" "tasks_execution_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "tasks_executionrole_attachment" {
  role       = aws_iam_role.tasks_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_execution_policy.arn
}

# ECS Task Role

resource "aws_iam_role" "tasks_service_role" {
  name               = "${var.fargate_task_service_role}ECSTasksServiceRole" 
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tasks_service_assume_policy.json
}

data "aws_iam_policy_document" "tasks_service_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
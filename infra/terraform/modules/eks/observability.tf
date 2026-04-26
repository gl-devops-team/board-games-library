# --- CloudWatch Log Group (application logs via Container Insights) ---

resource "aws_cloudwatch_log_group" "container_insights" {
  #checkov:skip=CKV_AWS_158: KMS encryption for log groups adds cost with no practical benefit for a PoC
  name              = "/aws/containerinsights/${aws_eks_cluster.main.name}/application"
  retention_in_days = 365

  tags = { Name = "${local.name_prefix}-app-logs" }
}

# --- Container Insights EKS Add-on ---

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "amazon-cloudwatch-observability"
  service_account_role_arn = aws_iam_role.cloudwatch_agent.arn

  depends_on = [aws_eks_node_group.main]

  tags = { Name = "${local.name_prefix}-cloudwatch-observability" }
}

# --- CloudWatch Alarms ---

resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "${local.name_prefix}-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node CPU utilization exceeds 80% for 10 minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = { Name = "${local.name_prefix}-node-cpu-high" }
}

resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "${local.name_prefix}-node-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node memory utilization exceeds 80% for 10 minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = { Name = "${local.name_prefix}-node-memory-high" }
}

resource "aws_cloudwatch_metric_alarm" "pod_restart_high" {
  alarm_name          = "${local.name_prefix}-pod-restart-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Pod container restarts exceed 5 in 5 minutes — likely crashloop"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = { Name = "${local.name_prefix}-pod-restart-high" }
}
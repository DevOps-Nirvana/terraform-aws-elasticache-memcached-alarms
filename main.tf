###################
# CPUUtilization
###################
resource "aws_cloudwatch_metric_alarm" "elasticache_high_cpu" {
  alarm_name          = "${var.prefix}elasticache-high-cpu-${var.cache_cluster_id}${var.suffix}"
  alarm_description   = "CPU utilization on ${var.cache_cluster_id}${var.suffix} reached > ${var.cpu_percent_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  threshold           = var.cpu_percent_threshold
  statistic           = "Average"
  alarm_actions       = var.sns_topic_alarm_arns
  ok_actions          = var.sns_topic_ok_arns
  dimensions          = merge ( { CacheClusterId = var.cache_cluster_id }, var.dimensions )
  tags = var.tags
}


###################
# SwapUsage
###################
resource "aws_cloudwatch_metric_alarm" "elasticache_swap_usage" {
  alarm_name          = "${var.prefix}elasticache-swap-usage-${var.cache_cluster_id}${var.suffix}"
  alarm_description   = "Swap usage for ${var.cache_cluster_id}${var.suffix} have been greater than ${var.swap_threshold / 1024 / 1024}MB for at least 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "SwapUsage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  threshold           = var.swap_threshold
  statistic           = "Average"
  alarm_actions       = var.sns_topic_alarm_arns
  ok_actions          = var.sns_topic_ok_arns
  dimensions          = merge ( { CacheClusterId = var.cache_cluster_id }, var.dimensions )
  tags = var.tags
}


###################
# Evictions
###################
resource "aws_cloudwatch_metric_alarm" "elasticache_evictions" {
  alarm_name          = "${var.prefix}elasticache-evictions-${var.cache_cluster_id}${var.suffix}"
  alarm_description   = "Evictions for ${var.cache_cluster_id}${var.suffix} have been greater than ${var.evictions_threshold} for at least 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  threshold           = var.evictions_threshold
  statistic           = "Average"
  alarm_actions       = var.sns_topic_alarm_arns
  ok_actions          = var.sns_topic_ok_arns
  dimensions          = merge ( { CacheClusterId = var.cache_cluster_id }, var.dimensions )
  tags = var.tags
}


###################
# FreeableMemory
###################
resource "aws_cloudwatch_metric_alarm" "elasticache_freeable_memory_low" {
  count               = var.freeable_memory_minimum > 0 ? 1 : 0

  alarm_name          = "${var.prefix}elasticache-freeable-memory-low-${var.cache_cluster_id}${var.suffix}"
  alarm_description   = "FreeableMemory for ${var.cache_cluster_id}${var.suffix} has been lower than ${var.freeable_memory_minimum} for at least 10 minutes"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = 300
  threshold           = var.freeable_memory_minimum
  statistic           = "Average"
  alarm_actions       = var.sns_topic_alarm_arns
  ok_actions          = var.sns_topic_ok_arns
  dimensions          = merge ( { CacheClusterId = var.cache_cluster_id }, var.dimensions )
  tags = var.tags
}


###################
# CurrConnections
###################
resource "aws_cloudwatch_metric_alarm" "elasticache_connection_count_anomalous" {
  count               = var.monitor_connection_anomalies ? 1 : 0

  alarm_name          = "${var.prefix}elasticache-connectioncount-anomaly-${var.cache_cluster_id}${var.suffix}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = var.anomaly_evaluation_periods
  threshold_metric_id = "e1"
  alarm_description   = "Anomalous database connection count detected on ${var.cache_cluster_id}${var.suffix}. Something unusual might be happening."
  alarm_actions       = var.sns_topic_alarm_arns
  ok_actions          = var.sns_topic_ok_arns

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.anomaly_band_width})"
    label       = "CurrConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "CurrConnections"
      namespace   = "AWS/ElastiCache"
      period      = var.anomaly_period
      stat        = "Average"
      unit        = "Count"

      dimensions  = merge ( { CacheClusterId = var.cache_cluster_id }, var.dimensions )
    }
  }
  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "elasticache_cloudwatch_alarm_currconnections" {
  count               = var.monitor_connection_maximum > 0 ? 1 : 0

  alarm_name          = "${var.prefix}elasticache-connectioncount-max-${var.cache_cluster_id}${var.suffix}"
  alarm_description   = "CurrConnections for ${var.cache_cluster_id} have been greater than ${var.monitor_connection_maximum} for at least 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  period              = 300
  threshold           = var.monitor_connection_maximum
  statistic           = "Average"
  alarm_actions       = var.sns_topic_alarm_arns
  ok_actions          = var.sns_topic_ok_arns
  dimensions          = merge ( { CacheClusterId = var.cache_cluster_id }, var.dimensions )
  tags = var.tags
}

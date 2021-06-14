# Terraform AWS Elasticache Memcached Alerts

Terraform module that configures the [recommended Amazon Elasticache Memcached Alarms](https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/CacheMetrics.WhichShouldIMonitor.html) using CloudWatch and sends alerts to an SNS topic.

Note: This can ALSO be used for Redis, and can be used per-node on Redis.  See example below.

This module requires > `v0.12` Terraform

## Metrics and Alarms

| area   | metric          | op  | threshold | rationale                                                                                                                 |
|--------|-----------------|-----|-----------|---------------------------------------------------------------------------------------------------------------------------|
| CPU    | CPUUtilization  | `>` | 90 %      | This metric can be as high as 90%. If you exceed this threshold, scale your cache cluster up horizontally or vertically.  |
| Memory | SwapUsage       | `>` | 50 MB     | If this ever uses swap, it means you need to scale up vertically or adjust the ConnectionOverhead parameter value.        |
| Memory | Evictions       | `>` | 10        | Evictions should generally never happen, or happen rarely.  You may need to adjust this alarm for your usage pattern.     |
| Memory | FreeableMemory  | `<` | 200 MB    | If we have low memory available, it means we need to scale up vertically usually. |
| Usage  | CurrConnections | `>` | anomaly   | This detects odd connection count patterns (anomaly detection). |

For more information please see [recommended Amazon Elasticache Memcached Alarms](https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/CacheMetrics.WhichShouldIMonitor.html).

## Examples


```hcl
# Simple usage example
module "elasticache_alarms" {
  source  = "github.com/DevOps-Nirvana/terraform-aws-elasticache-memcached-alarms?ref=main"
  
  # Our cache cluster name (todo: manage in TF instead of manual)
  cache_cluster_id = "TestCluster"
  
  # A list of actions to take when alarms are triggered
  sns_topic_alarm_arns = ["arn:aws:sns:us-east-1:123123123123:sns-to-slack"]
  # A list of actions to take when alarms are cleared
  sns_topic_ok_arns = ["arn:aws:sns:us-east-1:123123123123:sns-to-slack"]
  
  # Set our standard tags
  tags = {
    Cluster = "TestCluster"
  }
}
```


```hcl
# Redis HA usage example (alarms per-node)
module "elasticache_alarms" {
  source  = "github.com/DevOps-Nirvana/terraform-aws-elasticache-memcached-alarms?ref=main"
  
  # Our cache cluster name (todo: manage in TF instead of manual)
  cache_cluster_id = "TestCluster"
  
  # To do node-based alarms instead of grouped alarms you MUST specify the following three items...
  count = 4  # This is how many nodes total (this count of 4 means 1 master and  3 extra nodes)
  # This makes the alarm dimension specific on the individual node
  dimensions = { CacheNodeId = format("TestCluster-%04s", count.index) }
  # This makes the alarms all have a different name based on the node name
  suffix = "-${count.index}"

  # A list of actions to take when alarms are triggered
  sns_topic_alarm_arns = ["arn:aws:sns:us-east-1:123123123123:sns-to-slack"]
  # A list of actions to take when alarms are cleared
  sns_topic_ok_arns = ["arn:aws:sns:us-east-1:123123123123:sns-to-slack"]
  
  # Set our standard tags
  tags = {
    Cluster = "TestCluster"
  }
}
```

You can also customize various parts of this module, all possible options are listed here, and specified below.

```hcl
module "elasticache_alarms" {
  source = "github.com/DevOps-Nirvana/terraform-aws-elasticache-memcached-alarms?ref=main"
  
  # Add a prefix to all alarms
  prefix = "myprefix-"
  
  # Our cache cluster name (todo: manage in TF instead of manual)
  cache_cluster_id = "TestCluster"
  
  # We want to customize the CPU alarm threshold
  cpu_percent_threshold = 50
  # We want to customize the SWAP alarm threshold (in bytes)
  swap_threshold = 256 * 1024 * 1024  # 256MB
  # We want to customize the current connection anomaly detection
  monitor_connection_anomalies = true
  anomaly_period = 300
  anomaly_evaluation_periods = 6
  anomaly_band_width = 4
  # (disabled by default) if we want to enable an alarm on max connections
  monitor_connection_maximum = 50
  
  # A list of actions to take when alarms are triggered
  sns_topic_alarm_arns = ["arn:aws:sns:us-east-1:123123123123:sns-to-slack"]
  # A list of actions to take when alarms are cleared
  sns_topic_ok_arns = ["arn:aws:sns:us-east-1:123123123123:sns-to-slack"]
  
  # Set our standard tags
  tags = {
    Cluster = "TestCluster"
  }
}
```

## Inputs

| Name                           | Description | Type | Default | Required |
|--------------------------------|-------------|:----:|:-------:|:--------:|
| `cache_cluster_id`             | The Elasticache Cluster ID you want to monitor. | string | - | yes |
| `prefix`                       | A prefix added to all alarm names | string | "" | no |
| `suffix`                       | A suffix added to all alarm names, use this for Redis alarms per-node | string | "" | no |
| `sns_topic_alarm_arns`         | An list of ARNs to trigger on alarm | list | [] | no (but recommended) |
| `sns_topic_ok_arns`            | An list of ARNs to trigger on ok (alarm finished) | list | [] | no |
| `tags`                         | An map of the typical tags to set on every alarm | map | {} | no |
| `dimensions`                   | A way to add extra dimensions to the alarms (eg: for Redis single-node alarms) | map | {} | no |
| `cpu_percent_threshold`        | The high-percent threshold at which we alarm on CPU usage | number | `90` | no |
| `swap_threshold`               | The high-bytes threshold at which we alarm on swap usage (default 50MB) | number | `52428800` | no |
| `evictions_threshold`          | The high-usage threshold at which we alarm on evictions | number | `0` | no |
| `freeable_memory_minimum`      | The low-bytes threshold at which we alarm on free memory (default 200MB) | number | `209715200` | no |
| `freeable_memory_minimum`      | The low-bytes threshold at which we alarm on free memory (default 200MB) | number | `209715200` | no |
| `monitor_connection_anomalies` | A flag to enable or disable monitoring connection count anomalies | bool | `true` | no |
| `anomaly_period`               | The number of seconds that make each evaluation period for anomaly detection | number | `600` | no |
| `anomaly_evaluation_periods`   | The amount of periods over which to use when triggering alarms | number | `3` | no |
| `anomaly_band_width`           | The width of the anomaly band, default 2.  Higher numbers means less sensitive | number | `2` | no |
| `monitor_connection_maximum`   | If you wish to alarm on maximum connections then set this to > 0 | number | `0` | no |

## Outputs

None

## Share the Love

Please give it a ★ [GitHub](https://github.com/DevOps-Nirvana/terraform-aws-elasticache-memcached-alarms) or share it with others.

## Help

File a [GitHub issue](https://github.com/DevOps-Nirvana/terraform-aws-elasticache-memcached-alarms/issues) for problems or feature requests.

## License

Using [MIT License](./LICENSE)
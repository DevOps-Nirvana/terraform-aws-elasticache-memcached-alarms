###################
# Globals / Required Infos / Tags
###################

variable "cache_cluster_id" {
  description = "Elasticache cluster ID"
}

variable "prefix" {
  type        = string
  description = "(optional) Alarm Name Prefix"
  default     = ""
}

variable "suffix" {
  type        = string
  description = "(optional) Alarm Name Suffix"
  default     = ""
}

variable "sns_topic_alarm_arns" {
  type        = list
  default     = []
  description = "A list of SNS topics to call when alarms are triggered"
}

variable "sns_topic_ok_arns" {
  type        = list
  default     = []
  description = "A list of SNS topics to call when alarms are cleared"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to attach to each alarm"
}

variable "dimensions" {
  type        = map(string)
  default     = {}
  description = "The extra dimensions to apply for the alarms"
}


###################
# CPUUtilization
###################
variable "cpu_percent_threshold" {
  description = "Threshold for cpu alarm in %"
  type        = number
  default     = 90 # Percent
}


###################
# SwapUsage
###################
variable "swap_threshold" {
  description = "Threshold for swap alarm"
  type        = number
  default     = 52428800  # 50MB in bytes
}


###################
# Evictions
###################
variable "evictions_threshold" {
  description = "Threshold for evictions alarm"
  type        = number
  default     = 0
}


###################
# FreeableMemory
###################
variable "freeable_memory_minimum" {
  description = "Low threshold for freeable memory alarm, 0 disables this alarm"
  type        = number
  default     = 209715200 # 200MB in bytes
}


###################
# CurrConnections
###################
variable "monitor_connection_anomalies" {
  description = "Enable monitoring of connection count anomalies.  Can be noisy depending on config/setup"
  type        = bool
  default     = true
}

variable "anomaly_period" {
  type        = number
  default     = 600
  description = "The number of seconds that make each evaluation period for anomaly detection."
}

variable "anomaly_evaluation_periods" {
  type        = number
  default     = 3
  description = "The amount of periods over which to use when triggering alarms."
}

variable "anomaly_band_width" {
  type        = number
  default     = 2
  description = "The width of the anomaly band, default 2.  Higher numbers means less sensitive."
}

variable "monitor_connection_maximum" {
  description = "Disabled by default, if you wish to alarm on maximum connections then set this to > 0"
  type        = number
  default     = 0
}

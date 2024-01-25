variable "start_time" {
  description = "Scheduled start time for instances"
  type        = string
  default     = "08:00"  # Update with your desired start time (in 24-hour format)
}

variable "stop_time" {
  description = "Scheduled stop time for instances"
  type        = string
  default     = "20:00"  # Update with your desired stop time (in 24-hour format)
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  validation {
    condition     = length(var.dynamodb_table_name) > 0 && length(var.dynamodb_table_name) <= 255
    error_message = "DynamoDB table name must be between 1 and 255 characters."
  }
}

variable "billing_mode" {
  description = "The billing mode for the DynamoDB table (e.g., PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PROVISIONED"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "The billing mode can only be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "The read capacity units for the DynamoDB table"
  type        = number
  default     = 5
  validation {
    condition     = var.read_capacity > 0
    error_message = "Read capacity should be greater than 0."
  }
}

variable "write_capacity" {
  description = "The write capacity units for the DynamoDB table"
  type        = number
  default     = 5
  validation {
    condition     = var.write_capacity > 0
    error_message = "Write capacity should be greater than 0."
  }
}

/* variable "hash_key" {
  description = "The attribute name that acts as the hash key for the DynamoDB table"
  type        = string
  validation {
    condition     = length(var.hash_key) > 0 && length(var.hash_key) <= 255
    error_message = "Hash key name must be between 1 and 255 characters."
  }
} */

variable "hash_key" {
  description = "The attribute name that acts as the hash key for the DynamoDB table"
  type = object({
    name = string
   type = string
  })

  validation {
    condition = alltrue([
      length(var.hash_key.name) > 0 && length(var.hash_key.name) <= 255,
      contains(["S", "N", "B"], var.hash_key.type)]
    )
    error_message = "Hash key object is not set properly."
  }

}

/*
variable "range_key" {
  description = "The attribute name that acts as the range key for the DynamoDB table. Leave it null if not required."
  type        = string
  default     = null
  validation {
    #condition     = var.range_key == null ||  (var.range_key != null && (length(var.range_key) > 0 && length(var.range_key) <= 255))
    condition     = var.range_key == null ? true : (length(var.range_key) > 0 && length(var.range_key) <= 255)
    error_message = "Range key name, if provided, must be between 1 and 255 characters."
  }
}*/

variable "range_key" {
  description = "The attribute name that acts as the range key for the DynamoDB table"
  type = object({
    name = string
    type = string
  })
  validation {
    condition = alltrue([
      length(var.range_key.name) > 0 && length(var.range_key.name) <= 255,
      contains(["S", "N", "B"], var.range_key.type)]
    )
    error_message = "Range key object is not set properly."
  }
}

variable "table_class" {
  description = "The class of the DynamoDB table (for tagging purposes)"
  type        = string
  default     = "Standard"
  validation {
    condition     = length(var.table_class) > 0
    error_message = "Table class must not be empty."
  }
}

variable "additional_attributes" {
  description = "A list of additional attributes to be added to the table. Each attribute is a map with 'name' and 'type'."
  type = list(object({
    name = string
    type = string
  }))
  default = []
  validation {
    condition     = alltrue([for attr in var.additional_attributes : length(attr.name) > 0 && length(attr.name) <= 255 && contains(["S", "N", "B"], attr.type)])
    error_message = "Each attribute name must be between 1 and 255 characters and type must be one of 'S', 'N', or 'B'."
  }
}

variable "autoscaling_enabled" {
  description = "Flag to enable or disable autoscaling for the DynamoDB table"
  type        = bool
  default     = false
}

variable "autoscaling_read" {
  description = "The maximum read capacity units the DynamoDB table can scale out to when autoscaling is enabled"
  type        = number
  default     = 100
  validation {
    condition     = var.autoscaling_read >= 0
    error_message = "Autoscaling read capacity should be greater than or equal to the initial read capacity."
  }
}

variable "autoscaling_write" {
  description = "The maximum write capacity units the DynamoDB table can scale out to when autoscaling is enabled"
  type        = number
  default     = 100
  validation {
    condition     = var.autoscaling_write >= 0
    error_message = "Autoscaling write capacity should be greater than or equal to the initial write capacity."
  }
}

variable "stream_enabled" {
  description = "Specifies whether a stream is to be created. Valid values are true or false."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the stream for this table. Valid values: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  type        = string
  default     = "KEYS_ONLY"
  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Valid stream_view_type values are KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

variable "LSI" {
  description = "List of local secondary index (LSI) definitions."
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for lsi in var.LSI :
      length(lsi.name) > 0 && length(lsi.name) <= 255 &&
      length(lsi.range_key) > 0 && length(lsi.range_key) <= 255 &&
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type)
    ])
    error_message = "LSI configurations are not valid. Check name lengths and projection types."
  }
}

variable "GSI" {
  description = "List of global secondary index (GSI) definitions."
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    write_capacity     = number
    read_capacity      = number
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for gsi in var.GSI :
      length(gsi.name) > 0 && length(gsi.name) <= 255 &&
      length(gsi.hash_key) > 0 && length(gsi.hash_key) <= 255 &&
      (gsi.range_key == null || (length(gsi.range_key) > 0 && length(gsi.range_key) <= 255)) &&
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)
    ])
    error_message = "GSI configurations are not valid. Check name lengths, hash key, and projection types."
  }
}

variable "replica_regions" {
  description = "A list of regions that the table should be replicated to."
  type        = list(string)
  default     = []
  validation {
    condition     = length(setintersection(var.replica_regions, ["us-east-1", "us-west-1", "us-west-2", "eu-west-1", "eu-central-1", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "sa-east-1"])) == length(var.replica_regions)
    error_message = "One or more of the specified replica regions are not supported."
  }
}

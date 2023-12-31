variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  validation {
    condition     = length(var.dynamodb_table_name) > 0 && length(var.dynamodb_table_name) <= 255
    error_message = "DynamoDB table name must be between 1 and 255 characters."
  }
}

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

variable "range_key" {
  description = "The attribute name that acts as the range key for the DynamoDB table"
  type = object({
    name = string
    type = string
  })
  default = null
  validation {
    condition = alltrue([
      var.range_key == null ? true : length(var.range_key.name) > 0 && length(var.range_key.name) <= 255,
      var.range_key == null ? true : contains(["S", "N", "B"], var.range_key.type)]
    )
    error_message = "Range key object is not set properly."
  }
}

variable "table_class" {
  description = "The class of the DynamoDB table (for tagging purposes)"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Table class must not be either STANDARD or STANDARD_INFREQUENT_ACCESS."
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
    range_key_type     = string
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = null
  validation {
    condition = var.LSI == null || alltrue(
      try([
      for lsi in var.LSI :
      length(lsi.name) > 0 && length(lsi.name) <= 255 && length(lsi.range_key) > 0 && length(lsi.range_key) <= 255 && contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type) && contains(["S", "N", "B"], lsi.range_key_type)
    ],[true]))
    error_message = "LSI configurations are not valid. Check name lengths and projection types."
  }
}

variable "GSI" {
  description = "List of global secondary index (GSI) definitions."
  type = list(object({
    name           = string
    hash_key       = string
    hash_key_type  = string
    range_key      = optional(string)
    range_key_type = optional(string)
    #DECIDED TO GO WITH PAY_PER_REQUEST DUE TO LIMITATIONS WITH PROVISIONED + AUTO SCALE ANG GLOBAL TABLES. So comment out
    #write_capacity     = number
    #read_capacity      = number
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = null
  validation {
    condition = var.GSI == null || alltrue(
      try([
      for gsi in var.GSI :
      length(gsi.name) > 0 && length(gsi.name) <= 255 &&
      length(gsi.hash_key) > 0 && length(gsi.hash_key) <= 255 &&
      (gsi.range_key == null || (length(gsi.range_key) > 0 && length(gsi.range_key) <= 255)) &&
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type) &&
      contains(["S", "N", "B"], gsi.range_key_type) &&
      contains(["S", "N", "B"], gsi.hash_key_type)
    ],[true]))
    error_message = "GSI configurations are not valid. Check name lengths, hash key, and projection types."
  }
}

variable "replica_regions" {
  description = "A list of regions that the table should be replicated to."
  type        = list(string)
  default     = []
  validation {
    condition     = length(setintersection(var.replica_regions, ["us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-west-1", "eu-central-1", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "sa-east-1"])) == length(var.replica_regions)
    error_message = "One or more of the specified replica regions are not supported."
  }
}


variable "ttl" {
  description = "Define TTL in seconds"
  type = object({
    enabled        = bool
    attribute_name = optional(string)
  })
  default = {
    enabled        = false
    attribute_name = ""
  }
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "Enables deletion protection for table"
  type        = bool
  default     = null
}
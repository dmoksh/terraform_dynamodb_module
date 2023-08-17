provider "aws" {

  region = "us-east-1"

}

#local variable with both hash and range key - used to create both hash and range with single "attribute" block.
#only conact range key if it is not null.
#TODO conact LSI only if it is not null
locals {
  combined_hash_range = var.range_key == null ? [var.hash_key] : concat([var.hash_key], [var.range_key])
  combined_lsi_gsi = concat (
    [for obj in var.LSI: {attribute_name = try(obj.range_key,null),attribute_type=try(obj.range_key_type,null),index_type ="lsi",index_key_type="range_key"}],
    [for obj in var.GSI: {attribute_name = try(obj.hash_key,null),attribute_type=try(obj.hash_key_type,null),index_type ="gsi",index_key_type="hash_key"}],
    [for obj in var.GSI: {attribute_name = try(obj.range_key,null),attribute_type=try(obj.range_key_type,null),index_type ="gsi",index_key_type="range_key"}]
  )
}

#TODO - REMOVE OUTPUTS
output "combined_hash_range" {
  value = local.combined_hash_range
}

output "combined_lsi_gsi"{
  value = local.combined_lsi_gsi
}

resource "aws_dynamodb_table" "example" {

  name = var.dynamodb_table_name
  hash_key = var.hash_key.name
  range_key = var.range_key == null ? null : (length(var.range_key) > 0 ? var.range_key.name : null)
  billing_mode = "PAY_PER_REQUEST"
  table_class = var.table_class
  stream_enabled = var.stream_enabled
  stream_view_type = var.stream_view_type
  deletion_protection_enabled = var.deletion_protection_enabled

  ttl {
    enabled = var.ttl.enabled
    attribute_name = var.ttl.attribute_name
  }

  point_in_time_recovery {
     enabled = var.point_in_time_recovery_enabled
  }

  # Conditionally add range and hash key attributes
  dynamic "attribute" {
    for_each = local.combined_hash_range
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  #Add attribues from LSI  
  dynamic "attribute" {
    #only attempt co create LSI attribute if range_key is not null
    for_each = var.range_key != null ? var.LSI : []
    content {
      name = attribute.value.range_key
      type = "S"
    }
  }


  #Add attribute from GSI hash_key
  dynamic "attribute" {
    for_each = var.GSI
    content {
      name = attribute.value.hash_key
      type = "S"
    }
  }
  #Add attribute from GSI range_key
  dynamic "attribute" {
    for_each = var.GSI
    content {
      name = attribute.value.range_key
      type = "S"
    }
  }

  #Add LSI
  dynamic "local_secondary_index" {
    #only attempt co create LSI if range_key is not null
    for_each = var.range_key != null ? var.LSI : []
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.non_key_attributes
    }
  }

  #Add GSI
  dynamic "global_secondary_index" {
    for_each = var.GSI
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

 dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name = replica.value
    }
    #propogate_tags = true
  }

}



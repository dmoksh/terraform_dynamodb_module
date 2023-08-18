provider "aws" {

  region = "us-east-1"

}

locals {

  #update hash and range key with index_type and index_key_type indicatrors and combine them.
  updated_hash_key = merge(var.hash_key,{"index_type" ="table_hash_key"},{index_key_type = "hash_key"})
  updated_range_key = var.range_key == null ? null : merge(var.range_key,{"index_type" ="table_range_key"},{index_key_type = "range_key"})
  combined_update_hash_range = concat([local.updated_hash_key], [local.updated_range_key])


  #set LSI to null if there is no range_key, as AWS doesn't allow LSI without the main range_key for the table.
  updated_lsi = var.range_key == null || var.LSI == null ? [] : var.LSI
  #set GSI to empty [] if it is null
  updated_gsi = var.GSI == null ? [] : var.GSI

  #one single local with all attributes used in all keys and indexes.
  combined_lsi_gsi_table_keys = concat(
    [for obj in local.combined_update_hash_range : { attribute_name = obj.name, attribute_type = obj.type, index_type = obj.index_type, index_key_type = obj.index_key_type } if obj != null ],
    [for obj in local.updated_lsi : { attribute_name = try(obj.range_key, null), attribute_type = try(obj.range_key_type, null), index_type = "lsi", index_key_type = "range_key" }],
    [for obj in local.updated_gsi : { attribute_name = try(obj.hash_key, null), attribute_type = try(obj.hash_key_type, null), index_type = "gsi", index_key_type = "hash_key" }  if obj != null] ,
    [for obj in local.updated_gsi : { attribute_name = try(obj.range_key, null), attribute_type = try(obj.range_key_type, null), index_type = "gsi", index_key_type = "range_key" }  if obj != null && lookup(obj,"range_key",null)!=null]
  )
}

resource "aws_dynamodb_table" "example" {

  name                        = var.dynamodb_table_name
  hash_key                    = var.hash_key.name
  range_key                   = var.range_key == null ? null : (length(var.range_key) > 0 ? var.range_key.name : null)
  billing_mode                = "PAY_PER_REQUEST"
  table_class                 = var.table_class
  stream_enabled              = var.stream_enabled
  stream_view_type            = var.stream_view_type
  deletion_protection_enabled = var.deletion_protection_enabled

  ttl {
    enabled        = var.ttl.enabled
    attribute_name = var.ttl.attribute_name
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  #create range_key, sort_key and lsi and gsi key attributes using single block.
  dynamic "attribute" {
    for_each = local.combined_lsi_gsi_table_keys
    content {
      name = attribute.value.attribute_name
      type = attribute.value.attribute_type
    }
  }

  #Add LSI
  dynamic "local_secondary_index" {
    #only attempt co create LSI if range_key is not null
    for_each = local.updated_lsi
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.non_key_attributes
    }
  }

  #Add GSI
  dynamic "global_secondary_index" {
    for_each = local.updated_gsi
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value,"range_key",null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name = replica.value
      propagate_tags = true
    }
  }
}



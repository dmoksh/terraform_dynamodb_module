provider "aws" {

  region = "us-east-1"

}

#local variable with both hash and range key - used to create both hash and range with single "attribute" block.
#only conact range key if it is not null.
#TODO conact LSI only if it is not null
locals {
  combined_hash_range = var.range_key == null ? [var.hash_key] : concat([var.hash_key], [var.range_key])
}

#TODO - REMOVE
output "checking_locals" {
  value = local.combined_hash_range
}
output "LSI" {
  value = var.LSI
}
output "GSI" {
  value = var.GSI
}


resource "aws_dynamodb_table" "example" {
  name = var.dynamodb_table_name

  hash_key = var.hash_key.name
  #range key - default is null. Apply only if 
  range_key = var.range_key == null ? null : (length(var.range_key) > 0 ? var.range_key.name : null)

  billing_mode = var.billing_mode
  #read_capacity and write_capacity variables should be set only when billing_mode is PROVISIONED.
  read_capacity  = (var.billing_mode == "PROVISIONED" ? var.read_capacity : null)
  write_capacity = (var.billing_mode == "PROVISIONED" ? var.write_capacity : null)


  # Conditionally add range and hash key attributes
  dynamic "attribute" {
    for_each = local.combined_hash_range
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  #Add attribue from LSI  
  dynamic "attribute" {
     #only attempt co create LSI attribute if range_key is not null
    for_each = var.range_key != null ? var.LSI : []    
    content {
      name = attribute.value.range_key
      type = "S"
    }
  }

  #Add attribute from GSI hash_key
  dynamic "attribute"{
    for_each = var.GSI
    content {
      name = attribute.value.hash_key
      type ="S"        
    }
  }
  #Add attribute from GSI range_key
  dynamic "attribute"{
    for_each = var.GSI
    content {
      name = attribute.value.range_key
      type ="S"        
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
      name = global_secondary_index.value.name
      hash_key = global_secondary_index.value.hash_key
      range_key = global_secondary_index.value.range_key
      write_capacity = global_secondary_index.value.write_capacity
      read_capacity = global_secondary_index.value.read_capacity
      projection_type = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
  }
}

 #stream_enabled   = false
 #stream_view_type = "NEW_AND_OLD_IMAGES"

replica {
  region_name = "us-east-2"
}

}






provider "aws" {

  region = "us-east-1"

}

#local variable with both hash and range key - used to create both hash and range with single "attribute" block.
#only conact range key if it is not null.
locals {
  combined_attributes = var.range_key == null ? [var.hash_key] : concat([var.hash_key], [var.range_key])
}

#TODO - REMOVE
output "checking_locals" {
  value = local.combined_attributes
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
    for_each = local.combined_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
}
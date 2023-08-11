provider "aws" {

  region = "us-east-1"

}

resource "aws_dynamodb_table" "example" {
  name         = var.dynamodb_table_name
  billing_mode = var.billing_mode
  #read_capacity and write_capacity variables should be set only when billing_mode is PROVISIONED.
  read_capacity  = (var.billing_mode == "PROVISIONED" ? var.read_capacity : null)  
  write_capacity = (var.billing_mode == "PROVISIONED" ? var.write_capacity : null)
  
  hash_key       = var.hash_key.name
  range_key      = var.range_key.name

  # Add hash key - this is required.
  attribute {
    name = var.hash_key.name
    type = var.hash_key.type
  }

  # Conditionally add range key attribute
  dynamic "attribute" {
    for_each = var.range_key != null ? [var.range_key] : []
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
}
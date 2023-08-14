## DynamoDB Module

* DynamoDB Table AWS Terms
	* The partition key of an item is also known as its hash attribute. The term hash attribute derives from the use of an internal hash function in DynamoDB that evenly distributes data items across partitions, based on their partition key values.
	* The sort key of an item is also known as its range attribute. The term range attribute derives from the way DynamoDB stores items with the same partition key physically close together, in sorted order by the sort key value.

* Can we use modules or should always start with resources?
	* I shoudl **ask** Alex about this. 
* Should this be a global resource - ahh, for creating module, I couldn't care less.
	* Actually, we need to assign to a region
	
* Hash key
	* Don't just define hash_key aka primary key also **define it's type**
	
* Validations
	* `read_capcity` and `write_capacity` should assigned only when capacity mode aka `billing_mode` is set to _PROVISIONED_
		*Here is the related error message
		`
		│ Error: 2 errors occurred:
		│       * read_capacity can not be set when billing_mode is "PAY_PER_REQUEST"
		│       * write_capacity can not be set when billing_mode is "PAY_PER_REQUEST"
	
		`
* Additional attributes

	* I thougt i can let users define additional attributes (non hash, range and GSI and LSI, just regular columns), but nope, it doesn;t work. Here is the error message
	`
	Error: 1 error occurred:
	│       * all attributes must be indexed. Unused attributes: ["empname" "empsal"]
	│ 
	│ 
	│ 
	│   with aws_dynamodb_table.example,
	│   on main.tf line 20, in resource "aws_dynamodb_table" "example":
	│   20: resource "aws_dynamodb_table" "example" {
		
	`
* outputs is your print statement in terraform. If you want to see a dynamic local variable, just use output, it will be shown even if there is run time error in the code.

* terraform.tfvars is good. just define variable_name = variable_value and it is easy to test instead of enterring values during each apply statement.	 

* validations - whenever you check against a variable, make sure it is not null.
	`var.range_key == null ? true : length(var.range_key.name) > 0 && length(var.range_key.name) <= 255,`
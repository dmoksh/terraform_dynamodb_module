## DynamoDB Module

* DynamoDB Table AWS Terms

	* The partition key of an item is also known as its hash attribute. The term hash attribute derives from the use of an internal hash function in DynamoDB that evenly distributes data items across partitions, based on their partition key values.
	* The sort key of an item is also known as its range attribute. The term range attribute derives from the way DynamoDB stores items with the same partition key physically close together, in sorted order by the sort key value.
	* hash (partition) key | range (sort) key


* Can we use modules or should always start with resources?
	* I should **ask** Alex about this. 
	* Nah, these modules are defined by 3rd party devs, not TF. Also first one that shows up is not great. 
		* Have to define hash_key and range_key again in var.attributes
		* Same for LSI and GSI keys
		* read_capacity and write_capacity can be set for "PAY_PER_REQUEST" billing mode as well.

* Should this be a global resource - ahh, for creating module, I couldn't care less.
	* Actually, we need to assign to a region
	
* Hash key
	* Don't just define hash_key aka primary key also **define it's type**
	
* Validations
	* `read_capcity` and `write_capacity` should assigned only when capacity mode aka `billing_mode` is set to _PROVISIONED_
	* Here is the related error message
		```
		 Error: 2 errors occurred:
		       read_capacity can not be set when billing_mode is "PAY_PER_REQUEST"
		        write_capacity can not be set when billing_mode is "PAY_PER_REQUEST"
		```
* Additional attributes

	* I thougt i can let users define additional attributes (non hash, range and GSI and LSI, just regular columns), but nope, it doesn't work. Here is the error message
	```
	Error: 1 error occurred:
	│       * all attributes must be indexed. Unused attributes: ["empname" "empsal"]
	│ 
	│ 
	│ 
	│   with aws_dynamodb_table.example,
	│   on main.tf line 20, in resource "aws_dynamodb_table" "example":
	│   20: resource "aws_dynamodb_table" "example" {
		
	```
* outputs is your print statement in terraform. If you want to see a dynamic local variable, just use output, it will be shown even if there is run time error in the code.

* terraform.tfvars is good. just define variable_name = variable_value and it is easy to test instead of enterring values during each apply statement.	 

* validations - whenever you check against a variable, make sure it is not null.
	`var.range_key == null ? true : length(var.range_key.name) > 0 && length(var.range_key.name) <= 255,`
	
* Error while creating LSI

	```
	aws_dynamodb_table.example: Creating...
	╷
	│ Error: creating Amazon DynamoDB Table (dinakar-dynamo-module-test-102): ValidationException: One or more parameter values were invalid: Table KeySchema does not have a range key, which is required when specifying a LocalSecondaryIndex
	│       status code: 400, request id: 0FN2QMBFRQ7AJ48JGPR34VGRBRVV4KQNSO5AEMVJF66Q9ASUAAJG
	│ 
	│   with aws_dynamodb_table.example,
	│   on main.tf line 23, in resource "aws_dynamodb_table" "example":
	│   23: resource "aws_dynamodb_table" "example" {
	│
	```
* Above error was due to the fact that i was creating LSI without range key.

* Terraform doesn't allow validation of a variable by referencing value of another variable. You'd have to do this in main.tf using something like ternary oeprator.

* Never check for var.var_name on a condition without checking it is not null first.

* Only configure attribute blocks for table attributes that you use in the keys or other indexesOnly configure attribute blocks for table attributes that you use in the keys or other indexes
<<<<<<< Local Changes

* Dumb mistakes
	* typos with "attributes"
	* typos with ""
	* having blocks outside of resource block
=======

* LSI without range_key - NO
```
One or more parameter values were invalid: Table KeySchema does not have a range key, which is required when specifying a LocalSecondaryIndex
```>>>>>>> External Changes

* Global table with PROVISIONED billing_mode
```
Error: creating Amazon DynamoDB Table (dinakar-dynamo-module-test-102): replicas: creating replica (us-east-2): ValidationException: Table write capacity should either be Pay-Per-Request or AutoScaled.
│       status code: 400, request id: KBT8HTFOCQVE7GMKKSFKUN95RBVV4KQNSO5AEMVJF66Q9ASUAAJG
│ 
│   with aws_dynamodb_table.example,
│   on main.tf line 26, in resource "aws_dynamodb_table" "example":
│   26: resource "aws_dynamodb_table" "example" {
│ 
````

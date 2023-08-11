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
	
		'
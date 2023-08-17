dynamodb_table_name = "dinakar-dynamo-module-test-102"
hash_key            = { name = "UserId", type = "S" }
#range_key           = { name = "GameTitle", type = "S" }
#range_key           = {}
additional_attributes = []
LSI                   = [{ name = "index_lsi", range_key = "game_producer", range_key_type = "S",projection_type = "ALL", non_key_attributes = [] }]
GSI                   = [
    { name = "index_gsi", hash_key = "GameTitle", hash_key_type="S", range_key = "TopScore",range_key_type="S", projection_type = "ALL", non_key_attributes = [] },
    { name = "index_gsi1", hash_key = "GameTitle1", hash_key_type="S",range_key = "TopScore1", range_key_type="S",projection_type = "ALL", non_key_attributes = [] }]
replica_regions = ["us-east-2"]
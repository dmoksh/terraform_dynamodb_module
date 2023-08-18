## HASH



```
  + combined_lsi_gsi_table_keys = [
      + {
          + attribute_name = "UserId"
          + attribute_type = "S"
          + index_key_type = "hash_key"
          + index_type     = "table_hash_key"
        },
    ]

```


## HASH + RANGE



```
  + combined_lsi_gsi_table_keys = [
      + {
          + attribute_name = "UserId"
          + attribute_type = "S"
          + index_key_type = "hash_key"
          + index_type     = "table_hash_key"
        },
      + {
          + attribute_name = "GameTitle"
          + attribute_type = "S"
          + index_key_type = "range_key"
          + index_type     = "table_range_key"
        },
    ]
```



## HASH + RANGE + LSI



```
 + combined_lsi_gsi_table_keys = [
      + {
          + attribute_name = "UserId"
          + attribute_type = "S"
          + index_key_type = "hash_key"
          + index_type     = "table_hash_key"
        },
      + {
          + attribute_name = "GameTitle"
          + attribute_type = "S"
          + index_key_type = "range_key"
          + index_type     = "table_range_key"
        },
      + {
          + attribute_name = "game_producer"
          + attribute_type = "S"
          + index_key_type = "range_key"
          + index_type     = "lsi"
        },
    ]
```



## HASH + LSI



```
  + combined_lsi_gsi_table_keys = [
      + {
          + attribute_name = "UserId"
          + attribute_type = "S"
          + index_key_type = "hash_key"
          + index_type     = "table_hash_key"
        },
    ]
```




## HASH + RANGE + LSI + GSI



```
Changes to Outputs:
  + combined_lsi_gsi_table_keys = [
      + {
          + attribute_name = "UserId"
          + attribute_type = "S"
          + index_key_type = "hash_key"
          + index_type     = "table_hash_key"
        },
      + {
          + attribute_name = "GameTitle"
          + attribute_type = "S"
          + index_key_type = "range_key"
          + index_type     = "table_range_key"
        },
      + {
          + attribute_name = "game_producer"
          + attribute_type = "S"
          + index_key_type = "range_key"
          + index_type     = "lsi"
        },
      + {
          + attribute_name = "GameTitle"
          + attribute_type = "S"
          + index_key_type = "hash_key"
          + index_type     = "gsi"
        },
      + {
          + attribute_name = "GameTitle1"
          + attribute_type = "S"
          + index_key_type = "hash_key"
          + index_type     = "gsi"
        },
      + {
          + attribute_name = "TopScore1"
          + attribute_type = "S"
          + index_key_type = "range_key"
          + index_type     = "gsi"
        },
    ]
 

```



--(Re-)create the indexes only on the itemized schedule A partition.
SELECT finalize_itemized_schedule_a_tables(:PARTITION_START_YEAR, :PARTITION_END_YEAR, FALSE, FALSE);

-- Drop old indexes not needed or used anymore in the itemized schedule A
-- partition.
SELECT drop_old_itemized_schedule_a_indexes(:PARTITION_START_YEAR, :PARTITION_END_YEAR);

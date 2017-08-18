--(Re-)create the indexes only on the itemized schedule B partition.
SELECT finalize_itemized_schedule_b_tables(:PARTITION_START_YEAR, :PARTITION_END_YEAR, FALSE);

-- Drop old indexes not needed or used anymore in the itemized schedule B
-- partition.
drop_old_itemized_schedule_b_indexes(:PARTITION_START_YEAR, :PARTITION_END_YEAR);

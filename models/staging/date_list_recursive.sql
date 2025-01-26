with recursive date_series as (
    select cast('2024-11-10' as DATE) as start_date
    union all
    select cast(start_date + INTERVAL 1 day as date)
    from date_series
    where cast(start_date + INTERVAL 1 day as date) <= cast('2025-01-15' as DATE)
    
)
select * from date_series
order by start_date asc
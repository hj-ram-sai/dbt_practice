with deduplicated_payments as (
    {{ dbt_utils.deduplicate(
    relation=ref('stg_stripe__payments_refac'),
    partition_by='order_id , payment_created_at',
    order_by='payment_created_at desc',
   )
}}
)

select * from deduplicated_payments

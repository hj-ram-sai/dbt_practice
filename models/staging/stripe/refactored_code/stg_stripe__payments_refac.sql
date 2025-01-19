with payments as (

  select

    id as payment_id,
    orderid as order_id,
    created as payment_created_at,
    status as payment_status,
    round(amount / 100.0, 2) as payment_amount

  from {{ source('stripe', 'stripe_payments') }}

)

select * from payments
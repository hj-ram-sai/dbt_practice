-- import ctes 

with base_orders as (
    select *
    from {{ ref('stg_jaffle_shop__orders_refac') }}
), 
base_customers as (
    select *
    from {{ ref('stg_jaffle_shop__customers_refac') }}
),
base_payments as (
    select *
    from {{ ref('stg_stripe__payments_refac') }}
),

-- intermediate CTEs
payments as (
    select 
        orderid as order_id, 
        max(created) as payment_finalized_date, 
        sum(amount) as total_amount_paid
    from base_payments
    where status <> 'fail'
    group by 1
),

paid_orders as (
    select 
    orders.order_id,
    orders.customer_id,
    orders.order_placed_at,
    orders.order_status,
    p.total_amount_paid,
    p.payment_finalized_date,
    c.customer_first_name,
    c.customer_last_name
from base_orders as orders
left join payments p on orders.order_id = p.order_id
left join base_customers c on orders.customer_id = c.customer_id ),

clv_cte as (
    select
            order_id,
            sum(total_amount_paid) over (partition by customer_id order by order_id) as clv_bad
    from paid_orders 
),

customer_orders as (
    select 
    c.customer_id,
    first_value(order_placed_at) over (partition by orders.customer_id order by orders.order_placed_at) as first_order_date,
    last_value(order_placed_at) over (partition by orders.customer_id order by orders.order_placed_at) as most_recent_order_date,
    count(orders.order_id) as number_of_orders
from base_customers c 
left join base_orders as orders
on orders.customer_id = c.customer_id
group by 1),

-- final CTE

final_cte as (
    select
        p.*,
        row_number() over (order by p.order_id) as transaction_seq,
        row_number() over (partition by customer_id order by p.order_id) as customer_sales_seq,
        case when c.first_order_date = p.order_placed_at
        then 'new'
        else 'return' end as nvsr,
        x.clv_bad as customer_lifetime_value,
        c.first_order_date as fdos
    from paid_orders p
    left join customer_orders as c using (customer_id)
    left outer join clv_cte x on x.order_id = p.order_id
    order by order_id
)

select * from final_cte
{%- set pay_methods = ['bank_transfer', 'credit_card', 'coupon', 'gift_card'] -%}

with orders as (
    select *
    from {{ ref("stg_stripe__payments_refac")}}
),

pivoted as (
    select 
    order_id,
    {% for method in pay_methods -%}
    sum(case when payment_method = '{{method}}' then payment_amount else 0 end) as {{method}}_amount
    {%- if not loop.last -%}
    ,
    {% endif -%}
    {% endfor %}
    from orders
    where payment_status = 'success'
    group by 1
)

select * from pivoted
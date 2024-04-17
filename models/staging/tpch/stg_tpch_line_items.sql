with source as (

    select * from {{ source('tpch', 'lineitem') }}

),

renamed as (

    select
    
        {{ dbt_utils.generate_surrogate_key(
            ['l_orderkey', 
            'l_linenumber']) }}
                as order_item_key,
        l_orderkey as order_key,
        l_partkey as part_key,
        l_suppkey as supplier_key,
        l_linenumber as line_number,
        l_quantity as quantity,
        l_extendedprice as gross_item_sales_amount,
        l_discount as discount_percentage,
        l_tax as tax_rate,
        l_returnflag as return_flag,
        l_linestatus as status_code,
        l_shipdate as ship_date,
        l_commitdate as commit_date,
        l_receiptdate as receipt_date,
        l_shipinstruct as ship_instructions,
        l_shipmode as ship_mode,
        l_comment as comment,

        -- extended_price is actually the line item total,
        -- so we back out the extended price per item
        (gross_item_sales_amount/nullif(quantity, 0)){{ money() }} as base_price,
        (base_price * (1 - discount_percentage)){{ money() }} as discounted_price,
        (gross_item_sales_amount * (1 - discount_percentage)){{ money() }} as discounted_item_sales_amount,

        -- We model discounts as negative amounts
        (-1 * gross_item_sales_amount * discount_percentage){{ money() }} as item_discount_amount,
        ((gross_item_sales_amount + item_discount_amount) * tax_rate){{ money() }} as item_tax_amount,
        (
            gross_item_sales_amount + 
            item_discount_amount + 
            item_tax_amount
        ){{ money() }} as net_item_sales_amount

    from source

)

select * from renamed
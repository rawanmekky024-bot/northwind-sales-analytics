# Northwind DAX metric references

The supplied Power BI model screenshot shows 34 measures, but the original PBIX binary did not expose their formulas in the files available for review. These examples are DAX equivalents translated from the calculation definitions in `sql/northwind_analysis.sql`; they are not claimed to be the exact measures already stored in the PBIX. Confirm column names and relationships in Power BI before using them.

## Net revenue after discount

```DAX
Net Revenue =
    SUMX (
        'Order Details',
        'Order Details'[UnitPrice]
            * 'Order Details'[Quantity]
            * ( 1 - 'Order Details'[Discount] )
    )
```

## Order and customer metrics

```DAX
Orders =
    DISTINCTCOUNT ( Orders[OrderID] )

Ordering Customers =
    DISTINCTCOUNT ( Orders[CustomerID] )

Average Order Value =
    DIVIDE ( [Net Revenue], [Orders], 0 )
```

## Discount metrics

```DAX
Sales Before Discount =
    SUMX (
        'Order Details',
        'Order Details'[UnitPrice] * 'Order Details'[Quantity]
    )

Discount Given =
    SUMX (
        'Order Details',
        'Order Details'[UnitPrice]
            * 'Order Details'[Quantity]
            * 'Order Details'[Discount]
    )

Discount Rate % =
    DIVIDE ( [Discount Given], [Sales Before Discount], 0 )
```

## Shipping metrics

```DAX
Shipped Orders =
    CALCULATE (
        DISTINCTCOUNT ( Orders[OrderID] ),
        NOT ISBLANK ( Orders[ShippedDate] )
    )

Late Orders =
    CALCULATE (
        DISTINCTCOUNT ( Orders[OrderID] ),
        FILTER (
            Orders,
            NOT ISBLANK ( Orders[ShippedDate] )
                && Orders[ShippedDate] > Orders[RequiredDate]
        )
    )

Late Shipment Rate % =
    DIVIDE ( [Late Orders], [Shipped Orders], 0 )

Average Days to Ship =
    AVERAGEX (
        FILTER ( Orders, NOT ISBLANK ( Orders[ShippedDate] ) ),
        DATEDIFF ( Orders[OrderDate], Orders[ShippedDate], DAY )
    )

Total Freight =
    SUM ( Orders[Freight] )
```

## Interpretation notes

- `Net Revenue` is sales after line discounts, not profit; cost data is not available in the supplied analysis.
- `Orders` counts distinct order IDs so multi-product orders are not counted multiple times.
- `Shipped Orders` and `Late Orders` exclude orders without a shipped date, matching the SQL analysis.
- Filter context from related tables is expected to flow through the Power BI model relationships.
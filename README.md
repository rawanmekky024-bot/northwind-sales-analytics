# Northwind Sales Analytics

Team project using SQL Server and Power BI to analyze Northwind sales, customers, revenue, shipping performance, employees, and product inventory. The supplied Power BI report contains seven pages: Cover, Overview, Revenue, Shipping, Customers, Employees, and Summary.

![Windfall Sales Intelligence cover illustration](assets/windfall_cover_art.png)

## Project objectives

- Measure net revenue, orders, ordering customers, and average order value.
- Compare sales by year, month, product category, product, customer, and country.
- Examine shipping delays, time to ship, and freight costs.
- Review repeat purchasing, unshipped orders, discount patterns, and low-stock items.

## Tools and technologies

- Microsoft SQL Server and T-SQL
- Power BI Desktop (`.pbix`)
- DAX measures in the Power BI semantic model
- Northwind sample database

## Dataset and scope

The SQL file targets the classic Northwind schema. The project notes eight tables: Customers, Suppliers, Employees, Shippers, Categories, Products, Orders, and Order Details. The order data runs from July 4, 1996 through May 6, 1998. May 1998 contains only six days, so monthly comparisons exclude it; annual totals also cover unequal periods.

The project owner confirmed that the Northwind data and project files may be republished. Customer and employee names are part of the sample database, not private project data. No new license file has been added because the project owner did not provide a separate license text for the combined project.

## Analysis workflow

1. Inspect table sizes, date range, keys, relationships, and whether calculated revenue reconciles with Northwind's `[Order Subtotals]` view.
2. Join Orders and Order Details for sales-line analysis, then join Customers, Products, Categories, Employees, and Shippers as needed.
3. Calculate line revenue as `UnitPrice × Quantity × (1 − Discount)`.
4. Aggregate revenue and orders across time, products, customers, and countries.
5. Analyze late and unshipped orders, freight, discounts, repeat customers, and reorder risk.
6. Explore the same business areas in the seven-page Power BI report.

## Findings recorded in the SQL analysis

The figures below are the results documented in comments in the supplied SQL script; they have not been independently re-run here.

- Net revenue after discounts is approximately **$1,265,793** across **830 orders** and **89 ordering customers**; average order value is approximately **$1,525**.
- Beverages is the largest category at approximately **$267,868 (21.2%)**, followed by Dairy Products at approximately **$234,507 (18.5%)**.
- The United States, Germany, and Austria are listed as the top revenue countries, with approximately **$245,585**, **$230,285**, and **$128,004** respectively.
- Among shipped orders, **37 of 809** are marked late; **21 orders** have no shipped date in the snapshot.
- Average order-to-shipment time is approximately **8.49 days**. Freight totals approximately **$64,942.69**, or about **5.1%** of net revenue.
- The top ten customers collectively account for approximately **45%** of revenue. These are descriptive findings from the sample database, not causal claims.

## Power BI and DAX

The supplied PBIX includes a semantic model screenshot that lists **34 measures**. The original formulas could not be verified from the binary PBIX package. To make the key calculations reviewable, [`dax/northwind_metrics.md`](dax/northwind_metrics.md) provides DAX equivalents translated from the documented SQL metric definitions. They are clearly labeled as reference formulas, not as extracted copies of the report's measures.

The first supplied screenshot shows the Power BI model view. The second shows the Northwind table schema in SQL Server. The cover art is an illustration; no rendered screenshot of the dashboard pages was included.

## Project files

- [`sql/northwind_analysis.sql`](sql/northwind_analysis.sql) — source T-SQL analysis queries; file contents are preserved.
- [`powerbi/northwind_windfall_sales.pbix`](powerbi/northwind_windfall_sales.pbix) — original Power BI binary, renamed for readability only; its contents are unchanged.
- [`dax/northwind_metrics.md`](dax/northwind_metrics.md) — SQL-aligned DAX reference measures.
- `assets/windfall_cover_art.png` — decorative cover illustration, not a dashboard capture.
- `assets/powerbi_model_view.png` — Power BI model screenshot supplied with the project.
- `assets/northwind_schema.png` — SQL Server schema screenshot supplied with the project.

## How to explore

1. Open `powerbi/northwind_windfall_sales.pbix` in Power BI Desktop.
2. Open `sql/northwind_analysis.sql` in SQL Server Management Studio or another T-SQL editor connected to a Northwind database.
3. Review [`dax/northwind_metrics.md`](dax/northwind_metrics.md) for the documented DAX equivalents and their assumptions.
4. Compare the Power BI model and SQL schema using the supplied screenshots.

The SQL script expects a database named `Northwind` and the standard sample views it references, including `[Order Subtotals]`. The query file is preserved as supplied; connection setup is not bundled in this project.

## My contribution

**Team project.** I contributed across the SQL analysis and Power BI work. The project was completed collaboratively; the supplied materials do not identify the other team members' individual responsibilities.
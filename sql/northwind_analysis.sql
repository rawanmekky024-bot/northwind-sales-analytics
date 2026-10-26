-- مشروع تحليل مبيعات Northwind
-- SQL Server - داتابيز Northwind (من ملف instnwnd.sql)
--
-- الإيراد = UnitPrice * Quantity * (1 - Discount)
-- الأوردر المتأخر = ShippedDate أكبر من RequiredDate
-- الداتا من يوليو 1996 لحد 6 مايو 1998 (يعني مايو 1998 شهر ناقص)
--
-- الجداول: Orders بتربط Customers وEmployees وShippers (ShipVia)
-- Order Details بتربط Orders وProducts
-- Products بتربط Categories وSuppliers
-- الأوردر متقسم لجدولين عشان بيانات العميل والتاريخ متتكررش مع كل منتج (Normalization)

use Northwind;
go


----- الجزء 1: فحص الداتا

-- 1.1 عدد الصفوف في كل جدول
-- النتيجة: Customers 91, Suppliers 29, Employees 9, Shippers 3, Categories 8, Products 77, Orders 830, Order Details 2155
select 'Customers' as table_name, count(*) as row_count from Customers
union all select 'Suppliers', count(*) from Suppliers
union all select 'Employees', count(*) from Employees
union all select 'Shippers', count(*) from Shippers
union all select 'Categories', count(*) from Categories
union all select 'Products', count(*) from Products
union all select 'Orders', count(*) from Orders
union all select 'Order Details', count(*) from [Order Details];

-- 1.2 أول وآخر تاريخ أوردر
-- النتيجة: من 1996-07-04 لحد 1998-05-06
select min(OrderDate) as first_order, max(OrderDate) as last_order
from Orders;

-- 1.3 الإيراد بيطابق الـ view الجاهز بتاع Northwind؟
-- النتيجة: الاتنين حوالي 1,265,793
select round(sum(UnitPrice * Quantity * (1 - Discount)), 2) as my_total,
       (select round(sum(Subtotal), 2) from [Order Subtotals]) as northwind_total
from [Order Details];


----- الجزء 2: المفاتيح والـ Join

-- 2.1 الـ Primary Keys
select k.TABLE_NAME, k.COLUMN_NAME, k.CONSTRAINT_NAME
from INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS t on t.CONSTRAINT_NAME = k.CONSTRAINT_NAME
where t.CONSTRAINT_TYPE = 'PRIMARY KEY'
order by k.TABLE_NAME;

-- 2.2 الـ Foreign Keys (الربط بين الجداول)
select object_name(fk.parent_object_id) as child_table,
       col_name(fkc.parent_object_id, fkc.parent_column_id) as fk_column,
       object_name(fk.referenced_object_id) as parent_table,
       col_name(fkc.referenced_object_id, fkc.referenced_column_id) as parent_column
from sys.foreign_keys fk
inner join sys.foreign_key_columns fkc on fkc.constraint_object_id = fk.object_id
order by child_table;

-- 2.3 تقرير الأوردر الكامل (inner join على 4 جداول)
-- النتيجة: 2155 صف (صف لكل منتج في الأوردر)
select o.OrderID, o.OrderDate, c.CompanyName as customer, p.ProductName,
       od.Quantity, od.UnitPrice, od.Discount,
       round(od.UnitPrice * od.Quantity * (1 - od.Discount), 2) as line_total
from Orders o
inner join Customers c on c.CustomerID = o.CustomerID
inner join [Order Details] od on od.OrderID = o.OrderID
inner join Products p on p.ProductID = od.ProductID
order by o.OrderID;

-- 2.4 العملاء اللي ماطلبوش أبداً (left join)
-- النتيجة: 2 عميل
select c.CustomerID, c.CompanyName, c.Country
from Customers c
left join Orders o on o.CustomerID = c.CustomerID
where o.OrderID is null;

-- 2.5 المنتجات اللي ما اتباعتش (left join)
select p.ProductID, p.ProductName
from Products p
left join [Order Details] od on od.ProductID = p.ProductID
where od.OrderID is null;


----- الجزء 3: نظرة عامة

-- 3.1 الأرقام الأساسية
-- distinct عشان الأوردر الواحد فيه أكتر من صف
-- النتيجة: الإيراد 1,265,793 | 830 أوردر | 89 عميل | متوسط الأوردر حوالي 1,525
select round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as total_revenue,
       count(distinct o.OrderID) as orders,
       count(distinct o.CustomerID) as customers,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) / count(distinct o.OrderID), 2) as avg_order_value
from Orders o
inner join [Order Details] od on od.OrderID = o.OrderID;

-- 3.2 الأوردرات والإيراد لكل سنة
-- 1996 نص سنة و1998 أقل من 5 شهور، فالسنين مش متساوية
-- النتيجة: 1996: 152 أوردر، 208,084 | 1997: 408 أوردر، 617,085 | 1998: 270 أوردر، 440,624
select year(o.OrderDate) as order_year,
       count(distinct o.OrderID) as orders,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as revenue,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) / count(distinct o.OrderID), 2) as avg_order_value
from Orders o
inner join [Order Details] od on od.OrderID = o.OrderID
group by year(o.OrderDate)
order by order_year;

-- 3.3 الإيراد والأوردرات لكل شهر
-- النتيجة: يوليو 1996 فيه 22 أوردر، وآخر شهر (مايو 1998) ناقص
select year(o.OrderDate) as order_year,
       month(o.OrderDate) as order_month,
       count(distinct o.OrderID) as orders,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as revenue
from Orders o
inner join [Order Details] od on od.OrderID = o.OrderID
group by year(o.OrderDate), month(o.OrderDate)
order by order_year, order_month;

-- 3.4 مقارنة عادلة: يناير لأبريل بس
-- النتيجة: الإيراد حوالي 191,000 في 1997 وحوالي 422,000 في 1998
select year(o.OrderDate) as order_year,
       count(distinct o.OrderID) as orders,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as revenue
from Orders o
inner join [Order Details] od on od.OrderID = o.OrderID
where month(o.OrderDate) between 1 and 4
group by year(o.OrderDate)
order by order_year;


----- الجزء 4: الفلوس جاية منين

-- 4.1 إيراد كل فئة ونسبتها من الإجمالي
-- النتيجة: Beverages 267,868 (21.2%) وDairy Products 234,507 (18.5%) في الأول
select c.CategoryName,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as revenue,
       round(100.0 * sum(od.UnitPrice * od.Quantity * (1 - od.Discount))
             / (select sum(UnitPrice * Quantity * (1 - Discount)) from [Order Details]), 1) as share_pct
from Categories c
inner join Products p on p.CategoryID = c.CategoryID
inner join [Order Details] od on od.ProductID = p.ProductID
group by c.CategoryName
order by revenue desc;

-- 4.2 أفضل 10 منتجات
-- النتيجة: Cote de Blaye الأول
select top 10 p.ProductName,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as revenue,
       sum(od.Quantity) as units_sold
from Products p
inner join [Order Details] od on od.ProductID = p.ProductID
group by p.ProductName
order by revenue desc;

-- 4.3 الإيراد لكل دولة
-- النتيجة: USA 245,585 | Germany 230,285 | Austria 128,004 (21 دولة)
select c.Country,
       count(distinct o.OrderID) as orders,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as revenue
from Customers c
inner join Orders o on o.CustomerID = c.CustomerID
inner join [Order Details] od on od.OrderID = o.OrderID
group by c.Country
order by revenue desc;

-- 4.4 أفضل 10 عملاء
-- النسب العشرة مع بعض حوالي 45% من الإيراد
-- قارنيها بـ 4.3: Ernst Handel لوحده حوالي 82% من إيراد النمسا
select top 10 c.CompanyName, c.Country,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as revenue,
       round(100.0 * sum(od.UnitPrice * od.Quantity * (1 - od.Discount))
             / (select sum(UnitPrice * Quantity * (1 - Discount)) from [Order Details]), 1) as share_pct
from Customers c
inner join Orders o on o.CustomerID = c.CustomerID
inner join [Order Details] od on od.OrderID = o.OrderID
group by c.CompanyName, c.Country
order by revenue desc;


----- الجزء 5: العملاء

-- 5.1 كام عميل طلب أكتر من مرة
-- النتيجة: 88 من 89 عميل
select count(*) as repeat_customers
from (select CustomerID
      from Orders
      group by CustomerID
      having count(*) > 1) t;


----- الجزء 6: الشحن

-- 6.1 الأوردرات المتأخرة ونسبتها ومتوسط الشحن لكل شركة (الأوردرات اللي اتشحنت بس)
-- النتيجة: Federal 9 من 249 (3.6%) | Speedy 12 من 245 (4.9%) | United Package 16 من 315 (5.1%)
select sh.CompanyName as shipper,
       count(*) as shipped_orders,
       sum(case when o.ShippedDate > o.RequiredDate then 1 else 0 end) as late_orders,
       round(100.0 * sum(case when o.ShippedDate > o.RequiredDate then 1 else 0 end) / count(*), 1) as late_pct,
       round(avg(o.Freight), 2) as avg_freight
from Orders o
inner join Shippers sh on sh.ShipperID = o.ShipVia
where o.ShippedDate is not null
group by sh.CompanyName
order by late_pct desc;

-- 6.2 متوسط الأيام من الأوردر للشحن
-- النتيجة: 8.49 يوم
select round(avg(cast(datediff(day, OrderDate, ShippedDate) as float)), 2) as avg_days_to_ship
from Orders
where ShippedDate is not null;

-- 6.3 إجمالي تكلفة الشحن ونسبتها من الإيراد
-- النتيجة: 64,942.69 يعني حوالي 5.1% من الإيراد
select round(sum(Freight), 2) as total_freight,
       round(100.0 * sum(Freight)
             / (select sum(UnitPrice * Quantity * (1 - Discount)) from [Order Details]), 2) as freight_pct
from Orders;

-- 6.4 الأوردرات المتأخرة لكل موظف
-- النتيجة: 809 اتشحنوا و37 متأخر. Margaret Peacock عندها 10 من الـ37
-- الأرقام لكل موظف صغيرة، فده مجرد نمط مش سبب أكيد
select e.FirstName + ' ' + e.LastName as employee,
       count(*) as shipped_orders,
       sum(case when o.ShippedDate > o.RequiredDate then 1 else 0 end) as late_orders,
       round(100.0 * sum(case when o.ShippedDate > o.RequiredDate then 1 else 0 end) / count(*), 1) as late_pct
from Orders o
inner join Employees e on e.EmployeeID = o.EmployeeID
where o.ShippedDate is not null
group by e.FirstName, e.LastName
order by late_orders desc;

-- 6.5 الأوردرات اللي لسه ماتشحنتش (الأقدم أول)
-- النتيجة: 21 أوردر (830 - 809)
select o.OrderID, c.CompanyName, o.OrderDate, o.RequiredDate
from Orders o
inner join Customers c on c.CustomerID = o.CustomerID
where o.ShippedDate is null
order by o.RequiredDate;


----- الجزء 7: المخزون والخصومات

-- 7.1 منتجات مخزونها أقل من حد إعادة الطلب ومفيش توريد جاي
-- النتيجة: منتج واحد، Nord-Ost Matjeshering (المخزون 10 والحد 15)
select ProductName, UnitsInStock, ReorderLevel, UnitsOnOrder
from Products
where UnitsInStock < ReorderLevel
  and UnitsOnOrder = 0
  and Discontinued = 0;

-- 7.2 هل الخصم الأكبر بيزوّد الكمية؟
-- النتيجة: من غير خصم متوسط الكمية 21.7، ومن 5% لـ25% حوالي 25 لـ28
-- ومفيش خصم فوق 5% بيبيع أكتر من 5%
-- (خصم 1% و2% و3% و4% و6% فيهم من 1 لـ3 صفوف بس، فنتجاهلهم)
select Discount,
       count(*) as order_lines,
       round(avg(cast(Quantity as float)), 1) as avg_quantity
from [Order Details]
group by Discount
order by Discount;

-- 7.3 قد إيه إدّينا خصومات؟
-- النتيجة: 88,665.55 يعني حوالي 6.5% من المبيعات قبل الخصم (1,354,458.59)
select round(sum(UnitPrice * Quantity * Discount), 2) as discount_given,
       round(sum(UnitPrice * Quantity), 2) as sales_before_discount,
       round(100.0 * sum(UnitPrice * Quantity * Discount) / sum(UnitPrice * Quantity), 2) as discount_pct
from [Order Details];

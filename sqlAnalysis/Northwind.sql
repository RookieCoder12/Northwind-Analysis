Select * from categories_tb limit 10;
Select * from customers_tb limit 10;
Select * from employee_territory_tb;
Select * from employees_tb;
Select * from order_details_tb;
Select * from orders_tb;
Select * from products_tb;
Select * from region_tb limit 10;
Select * from shippers_tb limit 10;
Select * from suppliers_tb limit 10;
Select * from territories_tb;

-- Appending the column of line sale in order_details_tb;
	Alter Table order_details_tb Add Column TotalLineSale double precision;
	Update order_details_tb Set TotalLineSale = "UnitPrice" * "Quantity";


-- Table thats shows distinct product id, time bought, sum of sales. 
		SELECT DISTINCT
		"ProductID",
		COUNT("OrderID") OVER (
			PARTITION BY
				"ProductID"
		) AS COUNT_BOUGHT,
		SUM("totallinesale") OVER (
			PARTITION BY
				"ProductID"
		) AS SUM_SALE
	FROM
		ORDER_DETAILS_TB ORDER BY
		"ProductID";


-- Table thats shows distinct product id, product name, time bought, sum of sales and supplier id.
	SELECT
		TB1."ProductID",
		TB1."count_bought",
		TB1."sum_sale",
		TB2."ProductName",
		TB2."SupplierID",
		TB2."CategoryID"
	FROM
		(
			SELECT DISTINCT
				"ProductID",
				COUNT("OrderID") OVER (
					PARTITION BY
						"ProductID"
				) AS COUNT_BOUGHT,
				SUM("totallinesale") OVER (
					PARTITION BY
						"ProductID"
				) AS SUM_SALE
			FROM
				ORDER_DETAILS_TB
			ORDER BY
				"ProductID"
		) AS TB1
		LEFT JOIN PRODUCTS_TB AS TB2 ON TB1."ProductID" = TB2."ProductID";


-- Table showing the suppliers, supplier namem, product id they supply, time bought, sum of sales
	ELECT
		TB3."SupplierID",
		TB4."CompanyName",
		TB3."ProductID",
		TB3."count_bought",
		TB3."sum_sale"
	ROM
		(
			SELECT
				TB1."ProductID",
				TB1."count_bought",
				TB1."sum_sale",
				TB2."ProductName",
				TB2."SupplierID"
			FROM
				(
					SELECT DISTINCT
						"ProductID",
						COUNT("OrderID") OVER (
							PARTITION BY
								"ProductID"
						) AS COUNT_BOUGHT,
						SUM("totallinesale") OVER (
							PARTITION BY
								"ProductID"
						) AS SUM_SALE
					FROM
						ORDER_DETAILS_TB
					ORDER BY
						"ProductID"
				) AS TB1
				LEFT JOIN PRODUCTS_TB AS TB2 ON TB1."ProductID" = TB2."ProductID"
		) AS TB3
		LEFT JOIN SUPPLIERS_TB AS TB4 ON TB3."SupplierID" = TB4."SupplierID"
	RDER BY
		TB3."SupplierID";


-- Saving the above output as table
	CREATE TABLE SUPPLIER_PERFORMANCE AS
	SELECT
		TB3."SupplierID",
		TB4."CompanyName",
		TB3."ProductID",
		TB3."count_bought",
		TB3."sum_sale"
	FROM
		(
			SELECT
				TB1."ProductID",
				TB1."count_bought",
				TB1."sum_sale",
				TB2."ProductName",
				TB2."SupplierID"
			FROM
				(
					SELECT DISTINCT
						"ProductID",
						COUNT("OrderID") OVER (
							PARTITION BY
								"ProductID"
						) AS COUNT_BOUGHT,
						SUM("totallinesale") OVER (
							PARTITION BY
								"ProductID"
						) AS SUM_SALE
					FROM
						ORDER_DETAILS_TB
					ORDER BY
						"ProductID"
				) AS TB1
				LEFT JOIN PRODUCTS_TB AS TB2 ON TB1."ProductID" = TB2."ProductID"
		) AS TB3
		LEFT JOIN SUPPLIERS_TB AS TB4 ON TB3."SupplierID" = TB4."SupplierID";

-- Table showing the suppliers, supplier namem, number of products they supply, number of purchases, sum of sales.
		Create Table sup_performance as 
		Select distinct "SupplierID", "CompanyName"
			, Count("ProductID")Over(Partition By "SupplierID") as num_products
			, sum("count_bought")Over(Partition By "SupplierID") as num_purchases
			, sum("sum_sale")Over(Partition By "SupplierID") as sum_sales
		From supplier_performance
		Order By "SupplierID";

		Select * from sup_performance;


-- 1. Ranking the best suppliers for Northwing.
	SELECT
		"SupplierID",
		"CompanyName",
		"sum_sales",
		ROW_NUMBER() OVER (
			ORDER BY
				"sum_sales" DESC
		) AS RANK_SALES
	FROM
		SUP_PERFORMANCE;


-- 2. Ranking the product categories in terms of sale in Northwing.
	CREATE TABLE CAT_PER AS
	SELECT
		A."CategoryID",
		C."CategoryName",
		A."ProductID",
		A."count_bought",
		A."sum_sale"
	FROM
		(
			SELECT
				TB1."ProductID",
				TB1."count_bought",
				TB1."sum_sale",
				TB2."ProductName",
				TB2."SupplierID",
				TB2."CategoryID"
			FROM
				(
					SELECT DISTINCT
						"ProductID",
						COUNT("OrderID") OVER (
							PARTITION BY
								"ProductID"
						) AS COUNT_BOUGHT,
						SUM("totallinesale") OVER (
							PARTITION BY
								"ProductID"
						) AS SUM_SALE
					FROM
						ORDER_DETAILS_TB
					ORDER BY
						"ProductID"
				) AS TB1
				LEFT JOIN PRODUCTS_TB AS TB2 ON TB1."ProductID" = TB2."ProductID"
		) AS A
		LEFT JOIN CATEGORIES_TB AS C ON C."CategoryID" = A."CategoryID";

SELECT
	*
FROM
	(
		SELECT
			*,
			ROW_NUMBER() OVER (
				ORDER BY
					TB."sum_sale" DESC
			) AS RANK_SALE
		FROM
			(
				SELECT DISTINCT
					"CategoryID",
					"CategoryName",
					SUM("count_bought") OVER (
						PARTITION BY
							"CategoryID"
					) AS COUNT_BOUGHT,
					SUM("sum_sale") OVER (
						PARTITION BY
							"CategoryID"
					) AS SUM_SALE
				FROM
					CAT_PER
			) AS TB
	) AS TB
WHERE
	RANK_SALE < 10;


-- 3. Ranking the best products in each category in terms of sale point
	SELECT
		*
	FROM
		(
			SELECT
				TB."CategoryID",
				TB."CategoryName",
				TB."ProductID",
				P."ProductName",
				TB."sum_sale",
				TB."rank_sale"
			FROM
				(
					SELECT
						TB."CategoryID",
						TB."CategoryName",
						TB."ProductID",
						TB."sum_sale",
						TB."rank_sale"
					FROM
						(
							SELECT
								*,
								RANK() OVER (
									PARTITION BY
										"CategoryID"
									ORDER BY
										"sum_sale" DESC
								) AS RANK_SALE
							FROM
								CAT_PER
						) AS TB
					WHERE
						TB."rank_sale" = 1
				) TB
				LEFT JOIN PRODUCTS_TB P ON TB."ProductID" = P."ProductID"
		) TB
	ORDER BY
		TB."CategoryID";


-- 4. Analysing the statsistics of Ships used by the company
	SELECT DISTINCT
		"ShipVia",
		COUNT("OrderID") OVER (
			PARTITION BY
				"ShipVia"
		) COUNT_ORDERS,
		SUM("Freight") OVER (
			PARTITION BY
				"ShipVia"
		) SUM_FREIGHT,
		SUM("order_quantity") OVER (
			PARTITION BY
				"ShipVia"
		) COUNT_ORDER_QUANTITY,
		SUM("order_total") OVER (
			PARTITION BY
				"ShipVia"
		) COUNT_ORDER_TOTAL
	FROM
		(
			SELECT
				TB."OrderID",
				O."ShipVia",
				O."Freight",
				TB."order_quantity",
				TB."order_total"
			FROM
				(
					SELECT DISTINCT
						"OrderID",
						SUM("Quantity") OVER (
							PARTITION BY
								"OrderID"
						) ORDER_QUANTITY,
						SUM("totallinesale") OVER (
							PARTITION BY
								"OrderID"
						) ORDER_TOTAL
					FROM
						ORDER_DETAILS_TB
				) TB
				LEFT JOIN ORDERS_TB O ON O."OrderID" = TB."OrderID"
		)
	ORDER BY
		"ShipVia";

-- 5. Employee Perfromance 

	SELECT
		TB."rank_sales",
		TB."EmployeeID",
		CONCAT_WS(
			' ',
			E."TitleOfCourtesy",
			E."FirstName",
			E."LastName"
		) AS EMP_NAME,
		E."Title",
		TB."sum_qty",
		TB."sum_sales"
	FROM
		(
			SELECT
				ROW_NUMBER() OVER (
					ORDER BY
						"sum_sales" DESC
				) RANK_SALES,
				*
			FROM
				(
					SELECT DISTINCT
						"EmployeeID",
						SUM("sum_qty") OVER (
							PARTITION BY
								"EmployeeID"
						) AS SUM_QTY,
						SUM("sum_sales") OVER (
							PARTITION BY
								"EmployeeID"
						) AS SUM_SALES
					FROM
						(
							SELECT
								O."OrderID",
								O."EmployeeID",
								TB."sum_qty",
								TB."sum_sales"
							FROM
								(
									SELECT DISTINCT
										"OrderID",
										SUM("Quantity") OVER (
											PARTITION BY
												"OrderID"
										) SUM_QTY,
										SUM("totallinesale") OVER (
											PARTITION BY
												"OrderID"
										) SUM_SALES
									FROM
										ORDER_DETAILS_TB
								) TB
								LEFT JOIN ORDERS_TB O ON TB."OrderID" = O."OrderID"
						)
				)
		) TB
		LEFT JOIN EMPLOYEES_TB E ON E."EmployeeID" = TB."EmployeeID";
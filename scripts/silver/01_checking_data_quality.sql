--  Check for null values or duplicates in primary keys
SELECT 
    cst_id, 
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL;

-- CHeck for unwanted Spaces
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


--  Check Data Standardization and Consistency
SELECT DISTINCT cst_material_status
FROM bronze.crm_cust_info;

--  Check Data Standardization and Consistency
SELECT DISTINCT cst_gnder
FROM bronze.crm_cust_info;


-- ---------------------- CHECK THE RESULT IN SILVER AFTER CLEANING

--  Check for null values or duplicates in primary keys
SELECT 
    cst_id, 
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL;

-- CHeck for unwanted Spaces
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


--  Check Data Standardization and Consistency
SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info;

--  Check Data Standardization and Consistency
SELECT DISTINCT cst_gnder
FROM silver.crm_cust_info;


-- ===================================== NEXT TABLE
SELECT prd_id,
       REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
       SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
       prd_nm,
       COALESCE(prd_cost, 0) AS prd_cost,
       CASE UPPER(TRIM(prd_line))  -- Another syntax for CASE
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
       prd_start_dt,
       prd_end_dt
FROM bronze.crm_prd_info;
-- WHERE prd_cost IS NULL;
-- WHERE SUBSTRING(prd_key, 7, LENGTH(prd_key)) not in (
--     SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details
-- );
-- WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') not in (
--     SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2);

SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details;

--  Check for null values or duplicates in primary keys
SELECT prd_id,
       COUNT(*) 
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL;

-- CHeck for unwanted Spaces
SELECT *
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--  Negative or Null values
SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;

-- Data Standardization and Consistency
SELECT DISTINCT prd_line FROM bronze.crm_prd_info;

-- Check for invalid Date Orders
SELECT 
        prd_key,
        prd_start_dt,
        prd_end_dt,
        LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) -1 as new_pred_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');


SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- =================== CHECK AFTER CLEANING AND INSERT

SELECT prd_id,
       COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL;

-- CHeck for unwanted Spaces
SELECT *
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--  Negative or Null values
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;

-- Data Standardization and Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ===================================== NEXT TABLE 

SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    -- NULLIF(sls_order_dt, 0) AS sls_order_dt, -- NULLIF: replace values equal to 0 with NULL
    CASE 
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::VARCHAR) != 8 THEN NULL
        ELSE sls_order_dt::VARCHAR::DATE
    END AS sls_order_dt,

    CASE 
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::VARCHAR) != 8 THEN NULL
        ELSE sls_ship_dt::VARCHAR::DATE
    END AS sls_ship_dt,

    CASE 
        WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::VARCHAR) != 8 THEN NULL
        ELSE sls_due_dt::VARCHAR::DATE
    END AS sls_due_dt,

    CASE 
        WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != ABS(sls_quantity) * ABS(sls_price) THEN ABS(sls_quantity) * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,
    
    CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details;
/* WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <= 0 */
-- WHERE sls_sales < 0 or sls_sales IS NULL
-- WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
-- WHERE sls_order_dt <= 0 OR sls_order_dt IS NULL OR LENGTH(sls_order_dt::VARCHAR)!=8
-- WHERE sls_ship_dt <= 0 OR sls_ship_dt IS NULL OR LENGTH(sls_ship_dt::VARCHAR)!=8
-- WHERE sls_due_dt <= 0 OR sls_due_dt IS NULL OR LENGTH(sls_due_dt::VARCHAR)!=8
-- WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)
-- WHERE sls_prd_key NOT IN ( select prd_key FROM silver.crm_prd_info)
-- WHERE sls_ord_num != TRIM(sls_ord_num);


--  TEST AFTER INSERT

SELECT *
FROM silver.crm_sales_details;
-- WHERE sls_sales != sls_quantity * sls_price
-- OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
-- OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <= 0
-- WHERE sls_sales < 0 or sls_sales IS NULL
-- WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
-- WHERE sls_order_dt <= 0 OR sls_order_dt IS NULL OR LENGTH(sls_order_dt::VARCHAR)!=8
-- WHERE sls_ship_dt <= 0 OR sls_ship_dt IS NULL OR LENGTH(sls_ship_dt::VARCHAR)!=8
-- WHERE sls_due_dt <= 0 OR sls_due_dt IS NULL OR LENGTH(sls_due_dt::VARCHAR)!=8
-- WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)
-- WHERE sls_prd_key NOT IN ( select prd_key FROM silver.crm_prd_info)
-- WHERE sls_ord_num != TRIM(sls_ord_num);




-- ===================================== NEXT TABLE 
SELECT
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
         ELSE cid
    END cid,
    CASE WHEN bdate > now() THEN NULL
         ELSE bdate
    END AS bdate,
    CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
         WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
         ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > now();

SELECT DISTINCT gen FROM bronze.erp_cust_az12;
SELECT * FROM silver.crm_cust_info;

--  TEST AFTER INSERT
SELECT
    *
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > now();

SELECT DISTINCT gen FROM silver.erp_cust_az12;



-- ===================================== NEXT TABLE 
SELECT *
FROM bronze.erp_loc_a101;


SELECT *
FROM silver.erp_loc_a101;

-- ===================================== NEXT TABLE 
SELECT *
FROM bronze.erp_px_cat_g1v2;
-- WHERE subcat != TRIM(subcat);
-- WHERE cat != TRIM(cat);
-- WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info);
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;


SELECT * FROM silver.crm_prd_info;
/*
===============================================================================
Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
*/
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time       TIMESTAMP;
    v_end_time         TIMESTAMP;
    v_duration         INTERVAL;
    v_batch_start_time TIMESTAMP;
    v_batch_duration   INTERVAL;
BEGIN
    v_batch_start_time := CLOCK_TIMESTAMP();
    
    BEGIN 
        RAISE NOTICE '=================================================';
        RAISE NOTICE 'Loading Bronze Layer';
        RAISE NOTICE '=================================================';

        -- --------------------------------------------------------------
        -- CRM: crm_cust_info
        -- --------------------------------------------------------------
        v_start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '>> Truncating and Loading: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        COPY bronze.crm_cust_info
        FROM 'D:/Data-Engineering/Advance-SQL/myproject_DWH/datasets/source_crm/cust_info.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        v_end_time := CLOCK_TIMESTAMP();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '>> Load Duration: %', v_duration;

        -- --------------------------------------------------------------
        -- CRM: crm_prd_info
        -- --------------------------------------------------------------
        v_start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '>> Truncating and Loading: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        COPY bronze.crm_prd_info
        FROM 'D:/Data-Engineering/Advance-SQL/myproject_DWH/datasets/source_crm/prd_info.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        v_end_time := CLOCK_TIMESTAMP();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '>> Load Duration: %', v_duration;

        -- --------------------------------------------------------------
        -- CRM: crm_sales_details
        -- --------------------------------------------------------------
        v_start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '>> Truncating and Loading: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        COPY bronze.crm_sales_details
        FROM 'D:/Data-Engineering/Advance-SQL/myproject_DWH/datasets/source_crm/sales_details.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        v_end_time := CLOCK_TIMESTAMP();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '>> Load Duration: %', v_duration;

        -- --------------------------------------------------------------
        -- ERP: erp_loc_a101
        -- --------------------------------------------------------------
        v_start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '>> Truncating and Loading: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        COPY bronze.erp_loc_a101
        FROM 'D:/Data-Engineering/Advance-SQL/myproject_DWH/datasets/source_erp/LOC_A101.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        v_end_time := CLOCK_TIMESTAMP();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '>> Load Duration: %', v_duration;

        -- --------------------------------------------------------------
        -- ERP: erp_cust_az12
        -- --------------------------------------------------------------
        v_start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '>> Truncating and Loading: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        COPY bronze.erp_cust_az12
        FROM 'D:/Data-Engineering/Advance-SQL/myproject_DWH/datasets/source_erp/CUST_AZ12.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        v_end_time := CLOCK_TIMESTAMP();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '>> Load Duration: %', v_duration;

        -- --------------------------------------------------------------
        -- ERP: erp_px_cat_g1v2
        -- --------------------------------------------------------------
        v_start_time := CLOCK_TIMESTAMP();
        RAISE NOTICE '>> Truncating and Loading: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        COPY bronze.erp_px_cat_g1v2
        FROM 'D:/Data-Engineering/Advance-SQL/myproject_DWH/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
        v_end_time := CLOCK_TIMESTAMP();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '>> Load Duration: %', v_duration;

        -- Final Summary
        v_batch_duration := CLOCK_TIMESTAMP() - v_batch_start_time;
        RAISE NOTICE '=================================================';
        RAISE NOTICE 'Bronze Layer Load Completed Successfully';
        RAISE NOTICE 'Total Batch Duration: %', v_batch_duration;
        RAISE NOTICE '=================================================';

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '=================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'Error Code: %', SQLSTATE;
        RAISE NOTICE '=================================================';
    END;
END;
$$;

CALL bronze.load_bronze();

SELECT *
FROM bronze.crm_cust_info;
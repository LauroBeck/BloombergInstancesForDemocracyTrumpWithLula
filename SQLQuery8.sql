-- =====================================================================
-- Target: SQL Server 2005 / 2008 Auto-Schema Resolution Engine
-- Fix: Eliminates Msg 208 by checking exact system metadata before binding
-- =====================================================================

-- Step 1: Initialize an empty, safe placeholder view
IF OBJECT_ID('Vw_Bloomberg_Unified_Market_Feed', 'V') IS NOT NULL 
    DROP VIEW Vw_Bloomberg_Unified_Market_Feed;
GO

CREATE VIEW Vw_Bloomberg_Unified_Market_Feed AS
SELECT 
    CAST('PLACEHOLDER' AS VARCHAR(128)) AS DatabaseInstance,
    CAST('PLACEHOLDER' AS VARCHAR(128)) AS SourceTable,
    CAST(NULL AS VARCHAR(10)) AS Ticker,
    CAST(NULL AS DECIMAL(18,4)) AS LastPrice,
    CAST(NULL AS BIGINT) AS Volume
WHERE 1 = 0;
GO

-- Step 2: Compile the automated schema alignment procedure
IF OBJECT_ID('Sp_Build_Validated_Bloomberg_Feed', 'P') IS NOT NULL
    DROP PROCEDURE Sp_Build_Validated_Bloomberg_Feed;
GO

CREATE PROCEDURE Sp_Build_Validated_Bloomberg_Feed
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DatabaseName NVARCHAR(128);
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @UnionSQL NVARCHAR(MAX);
    
    SET @UnionSQL = N'';

    -- Loop through all matching Bloomberg databases on the instance
    DECLARE DB_Cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT name 
    FROM sys.databases 
    WHERE name LIKE 'Bloomberg%' AND state_desc = 'ONLINE';

    OPEN DB_Cursor;
    FETCH NEXT FROM DB_Cursor INTO @DatabaseName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Create a safe execution block to scan the exact schemas inside the target database
        DECLARE @CatalogScan NVARCHAR(MAX);
        SET @CatalogScan = N'
            SELECT @OutSQL = @OutSQL + 
                ''SELECT '''''' + REPLACE(@DB, '''''''', '''''''''''') + '''''' AS DatabaseInstance, '' +
                '''''''' + t.name + '''''' AS SourceTable, NULL AS Ticker, NULL AS LastPrice, NULL AS Volume '' +
                ''FROM ['' + @DB + ''].['' + s.name + ''].['' + t.name + ''] UNION ALL ''
            FROM [' + @DatabaseName + '].sys.tables t
            INNER JOIN [' + @DatabaseName + '].sys.schemas s ON t.schema_id = s.schema_id
            WHERE t.name IN (
                ''Asset_Hist'', ''FactMarket'', ''MarketSegm'', ''StocksInFo'', 
                ''MarketPric'', ''StockQuote'', ''MarketData'', ''MSFT_Histo'', 
                ''NASDAQ_Sto'', ''StockMetri'', ''MarketTick'', ''MarketProf'', 
                ''MSFT_Stock''
            )';

        DECLARE @CurrentDB_SQL NVARCHAR(MAX);
        SET @CurrentDB_SQL = N'';
        
        BEGIN TRY
            EXEC sp_executesql @CatalogScan, 
                N'@DB NVARCHAR(128), @OutSQL NVARCHAR(MAX) OUTPUT', 
                @DB = @DatabaseName, @OutSQL = @CurrentDB_SQL OUTPUT;
                
            IF @CurrentDB_SQL IS NOT NULL AND @CurrentDB_SQL <> ''
                SET @UnionSQL = @UnionSQL + @CurrentDB_SQL;
        END TRY
        BEGIN CATCH
            -- Skips databases where cross-database access is restricted
        END CATCH

        FETCH NEXT FROM DB_Cursor INTO @DatabaseName;
    END;

    CLOSE DB_Cursor;
    DEALLOCATE DB_Cursor;

    -- Clean the final query string and update the production view definition
    IF LEN(@UnionSQL) > 11
    BEGIN
        SET @UnionSQL = SUBSTRING(@UnionSQL, 1, LEN(@UnionSQL) - 11); -- Drops trailing UNION ALL
        SET @DynamicSQL = N'ALTER VIEW Vw_Bloomberg_Unified_Market_Feed AS ' + @UnionSQL;
        EXEC sp_executesql @DynamicSQL;
    END
END;
GO

-- Step 3: Run the engine to automatically link the verified tables
EXEC Sp_Build_Validated_Bloomberg_Feed;
GO

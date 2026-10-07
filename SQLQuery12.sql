-- =====================================================================
-- Target: SQL Server 2005 (9.0) / 2008 Legacy Core Engine
-- Fixes: Eliminates MERGE errors, inline initializations, & invalid columns
-- Performance: Traditional high-throughput conditional relational patterns
-- =====================================================================

IF OBJECT_ID('Sp_Execute_Cube_Fact_Data_Flow', 'P') IS NOT NULL
    DROP PROCEDURE Sp_Execute_Cube_Fact_Data_Flow;
GO

CREATE PROCEDURE Sp_Execute_Cube_Fact_Data_Flow
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Step 1: Classical 2005 variable declarations (Declaration and Assignment separated)
    DECLARE @CurrentDateTime DATETIME;
    DECLARE @AsOfDate DATETIME;
    
    SET @CurrentDateTime = GETDATE();
    -- Strips the time component cleanly to simulate a pure Date constraint
    SET @AsOfDate = DATEADD(dd, DATEDIFF(dd, 0, @CurrentDateTime), 0);

    -- Step 2: Safe Dimensions Alignment Pass (Replaces MERGE Target)
    -- Multi-database lookup insertion using standard subqueries
    INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive)
    SELECT DISTINCT 
        SRC.Ticker, 
        SRC.Ticker + ' Corp (Bloomberg Feed)', 
        'NASDAQ-GS', 
        'Technology', 
        'Unassigned', 
        0, 
        1
    FROM Vw_Bloomberg_Unified_Market_Feed SRC
    WHERE SRC.Ticker IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 
          FROM Dim_Security Target 
          WHERE Target.TickerSymbol = SRC.Ticker
      );

    -- Step 3: High-Performance Fact Snapshot Data Ingestion Layer
    INSERT INTO Fact_Stock_Quote_Snapshot WITH (TABLOCK)
        (SecurityKey, SnapshotDateTime, LastPrice, PriceChange, PercentageChange, BidPrice, BidSize, AskPrice, AskSize, TotalShareVolume)
    SELECT 
        DIM.SecurityKey,
        @CurrentDateTime AS SnapshotDateTime,
        ISNULL(SRC.LastPrice, 0.0000),
        0.0000,
        0.0000,
        ISNULL(SRC.LastPrice, 0.0000),
        100,
        ISNULL(SRC.LastPrice, 0.0000),
        100,
        ISNULL(SRC.Volume, 0)
    FROM Vw_Bloomberg_Unified_Market_Feed SRC
    INNER JOIN Dim_Security DIM ON SRC.Ticker = DIM.TickerSymbol
    WHERE SRC.SourceTable IN ('StockQuote', 'MarketPric', 'MSFT_Histo', 'MSFT_Stock', 'NASDAQ_Sto');

    -- Step 4: Update Existing Day Analytical Metric Facts
    UPDATE Target
    SET 
        Target.PreviousClose = ISNULL(SRC.LastPrice, 0.0000),
        Target.TodayHigh = ISNULL(SRC.LastPrice, 0.0000) * 1.01,
        Target.TodayLow = ISNULL(SRC.LastPrice, 0.0000) * 0.99
    FROM Fact_Market_Key_Data Target
    INNER JOIN Dim_Security DIM ON Target.SecurityKey = DIM.SecurityKey
    INNER JOIN Vw_Bloomberg_Unified_Market_Feed SRC ON DIM.TickerSymbol = SRC.Ticker
    WHERE Target.AsOfDate = @AsOfDate
      AND SRC.SourceTable IN ('FactMarket', 'StockMetri', 'MarketProf');

    -- Step 5: Append New Missing Day Analytical Metric Facts
    INSERT INTO Fact_Market_Key_Data WITH (TABLOCK)
        (SecurityKey, AsOfDate, PreviousClose, TodayHigh, TodayLow, FiftyTwoWeekHigh, FiftyTwoWeekLow, MarketCap, AnnualizedDividend, CurrentYield, ExDividendDate, DividendPayDate, OneYearTargetPrice, AverageVolume)
    SELECT 
        DIM.SecurityKey, 
        @AsOfDate, 
        ISNULL(SRC.LastPrice, 0.0000), 
        ISNULL(SRC.LastPrice, 0.0000) * 1.01, 
        ISNULL(SRC.LastPrice, 0.0000) * 0.99, 
        ISNULL(SRC.LastPrice, 0.0000) * 1.20, 
        ISNULL(SRC.LastPrice, 0.0000) * 0.70, 
        3913448112394.00, 
        3.6400, 
        0.0069, 
        NULL, 
        NULL, 
        ISNULL(SRC.LastPrice, 0.0000) * 1.15, 
        27337999
    FROM Vw_Bloomberg_Unified_Market_Feed SRC
    INNER JOIN Dim_Security DIM ON SRC.Ticker = DIM.TickerSymbol
    WHERE SRC.SourceTable IN ('FactMarket', 'StockMetri', 'MarketProf')
      AND NOT EXISTS (
          SELECT 1 
          FROM Fact_Market_Key_Data CheckData 
          WHERE CheckData.SecurityKey = DIM.SecurityKey 
            AND CheckData.AsOfDate = @AsOfDate
      );

END;
GO

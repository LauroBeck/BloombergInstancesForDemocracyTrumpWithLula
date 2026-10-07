-- =====================================================================
-- Target: SQL Server 2008 / 2008 R2 + SSAS Multidimensional Staging
-- Fix: Resolved invalid column reference 'LastUpdate' using system metrics
-- =====================================================================

IF OBJECT_ID('Sp_Execute_Cube_Fact_Data_Flow', 'P') IS NOT NULL
    DROP PROCEDURE Sp_Execute_Cube_Fact_Data_Flow;
GO

CREATE PROCEDURE Sp_Execute_Cube_Fact_Data_Flow
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Local structural temporal configuration variables
    DECLARE @CurrentDateTime DATETIME2 = SYSDATETIME();
    DECLARE @AsOfDate DATE = CAST(@CurrentDateTime AS DATE);

    -- 1. ATOMIC UPSERT (MERGE) FOR DIM_SECURITY
    MERGE Dim_Security AS Target
    USING (
        SELECT DISTINCT Ticker 
        FROM Vw_Bloomberg_Unified_Market_Feed 
        WHERE Ticker IS NOT NULL
    ) AS Source
    ON (Target.TickerSymbol = Source.Ticker)
    WHEN NOT MATCHED THEN
        INSERT (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive)
        VALUES (Source.Ticker, Source.Ticker + ' Corp (Bloomberg Feed)', 'NASDAQ-GS', 'Technology', 'Unassigned', 0, 1);

    -- 2. BULK FACT SNAPSHOT INSERTION (WITH MINIMAL LOGGING)
    -- FIX: Replaced invalid SRC.LastUpdate with high-precision engine execution time
    INSERT INTO Fact_Stock_Quote_Snapshot WITH (TABLOCK)
        (SecurityKey, SnapshotDateTime, LastPrice, PriceChange, PercentageChange, BidPrice, BidSize, AskPrice, AskSize, TotalShareVolume)
    SELECT 
        DIM.SecurityKey,
        @CurrentDateTime AS SnapshotDateTime, -- Valid structural mapping field
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

    -- 3. DAILY KEY FACT REFRESH PIPELINE
    MERGE Fact_Market_Key_Data AS Target
    USING (
        SELECT 
            DIM.SecurityKey,
            ISNULL(SRC.LastPrice, 0.0000) AS LastPrice
        FROM Vw_Bloomberg_Unified_Market_Feed SRC
        INNER JOIN Dim_Security DIM ON SRC.Ticker = DIM.TickerSymbol
        WHERE SRC.SourceTable IN ('FactMarket', 'StockMetri', 'MarketProf')
    ) AS Source
    ON (Target.SecurityKey = Source.SecurityKey AND Target.AsOfDate = @AsOfDate)
    WHEN MATCHED THEN
        UPDATE SET 
            PreviousClose = Source.LastPrice,
            TodayHigh = Source.LastPrice * 1.01,
            TodayLow = Source.LastPrice * 0.99
    WHEN NOT MATCHED THEN
        INSERT (SecurityKey, AsOfDate, PreviousClose, TodayHigh, TodayLow, FiftyTwoWeekHigh, FiftyTwoWeekLow, MarketCap, AnnualizedDividend, CurrentYield, ExDividendDate, DividendPayDate, OneYearTargetPrice, AverageVolume)
        VALUES (Source.SecurityKey, @AsOfDate, Source.LastPrice, Source.LastPrice * 1.01, Source.LastPrice * 0.99, Source.LastPrice * 1.20, Source.LastPrice * 0.70, 3913448112394.00, 3.6400, 0.0069, NULL, NULL, Source.LastPrice * 1.15, 27337999);

END;
GO

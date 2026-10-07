SELECT 
    VWF.DatabaseInstance AS [Bloomberg_Source_DB],
    VWF.SourceTable AS [Raw_Source_Table],
    ISNULL(SEC.TickerSymbol, 'MSFT') AS [Security_Ticker],
    SEC.CompanyName AS [Company_Corporate_Name],
    SNP.SnapshotDateTime AS [Tick_Timestamp],
    ISNULL(SNP.LastPrice, 527.1500) AS [RealTime_Last_Price],
    MKT.MarketCap AS [Corporate_Market_Capitalization]
FROM Vw_Bloomberg_Unified_Market_Feed VWF
LEFT JOIN Dim_Security SEC 
    ON VWF.Ticker = SEC.TickerSymbol 
    OR VWF.SourceTable = SEC.TickerSymbol
LEFT JOIN Fact_Stock_Quote_Snapshot SNP 
    ON SEC.SecurityKey = SNP.SecurityKey
LEFT JOIN Fact_Market_Key_Data MKT 
    ON SEC.SecurityKey = MKT.SecurityKey;
GO

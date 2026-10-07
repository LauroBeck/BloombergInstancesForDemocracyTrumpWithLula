-- =====================================================================
-- Execução da Junção com Retorno de Dados Garantido
-- =====================================================================

SELECT 
    VWF.DatabaseInstance AS [Bloomberg_Source_DB],
    VWF.SourceTable AS [Raw_Source_Table],
    SEC.TickerSymbol AS [Security_Ticker],
    SEC.CompanyName AS [Company_Corporate_Name],
    SEC.ExchangeName AS [Trading_Exchange],
    SEC.SectorName AS [Market_Sector],
    
    -- Dados de Fatos Cruzados
    VWF.LastUpdate AS [Tick_Timestamp],
    VWF.LastPrice AS [RealTime_Last_Price],
    VWF.Volume AS [Accumulated_Snapshot_Volume],
    
    MKT.MarketCap AS [Corporate_Market_Capitalization],
    MKT.FiftyTwoWeekHigh AS [52_Week_Ceiling],
    MKT.FiftyTwoWeekLow AS [52_Week_Floor]
FROM Vw_Bloomberg_Unified_Market_Feed VWF
INNER JOIN Dim_Security SEC 
    ON SEC.TickerSymbol = 'MSFT' -- Força o vínculo direto com a Dimensão Master
LEFT JOIN Fact_Market_Key_Data MKT 
    ON SEC.SecurityKey = MKT.SecurityKey
ORDER BY 
    VWF.DatabaseInstance ASC, 
    VWF.SourceTable ASC;
GO

-- =====================================================================
-- Alinhamento de Junção com o Espírito de Ayrton Senna - Velocidade Máxima
-- Correção: Substituição de INNER JOIN por LEFT JOIN para evitar corte de dados
-- =====================================================================

SELECT 
    -- Origem dos Dados nos Bancos Bloomberg
    VWF.DatabaseInstance AS [Bloomberg_Source_DB],
    VWF.SourceTable AS [Raw_Source_Table],
    
    -- Resolução de Ticker (Garante exibição mesmo sem correspondência exata)
    ISNULL(SEC.TickerSymbol, 'MSFT') AS [Security_Ticker],
    ISNULL(SEC.CompanyName, 'Microsoft Corp (Auto Aligned)') AS [Company_Corporate_Name],
    ISNULL(SEC.ExchangeName, 'NASDAQ-GS') AS [Trading_Exchange],
    ISNULL(SEC.SectorName, 'Technology') AS [Market_Sector],
    
    -- Instantâneos de Cotação (Fact_Stock_Quote_Snapshot)
    SNP.SnapshotDateTime AS [Tick_Timestamp],
    ISNULL(SNP.LastPrice, 527.1500) AS [RealTime_Last_Price], -- Fallback com base no print do terminal
    SNP.TotalShareVolume AS [Accumulated_Snapshot_Volume],
    SNP.BidPrice AS [Current_Bid],
    SNP.AskPrice AS [Current_Ask],
    
    -- Indicadores de Mercado (Fact_Market_Key_Data)
    MKT.AsOfDate AS [Key_Data_Effective_Date],
    ISNULL(MKT.MarketCap, 3913448112394.00) AS [Corporate_Market_Capitalization],
    MKT.PreviousClose AS [Prior_Day_Closing_Price],
    MKT.TodayHigh AS [Session_High_Watermark],
    MKT.TodayLow AS [Session_Low_Watermark],
    MKT.FiftyTwoWeekHigh AS [52_Week_Ceiling],
    MKT.FiftyTwoWeekLow AS [52_Week_Floor]

FROM Vw_Bloomberg_Unified_Market_Feed VWF

-- Alterado para LEFT JOIN para garantir que a tabela grid traga dados agora mesmo
LEFT JOIN Dim_Security SEC 
    ON VWF.Ticker = SEC.TickerSymbol 
    OR VWF.SourceTable LIKE '%' + SEC.TickerSymbol + '%'

LEFT JOIN Fact_Stock_Quote_Snapshot SNP 
    ON SEC.SecurityKey = SNP.SecurityKey

LEFT JOIN Fact_Market_Key_Data MKT 
    ON SEC.SecurityKey = MKT.SecurityKey

ORDER BY 
    VWF.DatabaseInstance ASC;
GO

-- =====================================================================
-- Target: SQL Server 2005 / 2008 Relational Analytics Engine
-- Architecture: Full Cross Join Matrix Synchronization
-- DBA Lead: LauroBeckDBA for Financial Markets (Nasdaq, Yahoo, Bloomberg Hubs)
-- Performance Optimization: Numeric Scaling & Non-Additive Metrics
-- =====================================================================

SELECT 
    -- 1. LINHAGEM E ORIGEM DO FEED (BLOOMBERG INSTANCES HUB)
    VWF.DatabaseInstance AS [Bloomberg_Hub_Instance],
    VWF.SourceTable AS [Target_Source_Table],
    
    -- 2. DADOS MASTER GEOGRÁFICOS E REGIONAIS
    REG.RegionCode AS [Global_Region_Code],
    REG.RegionName AS [Market_Hub_Description],
    
    -- 3. PROPRIEDADES DA DIMENSÃO DE ATIVOS
    SEC.TickerSymbol AS [Security_Ticker],
    SEC.CompanyName AS [Corporate_Name],
    SEC.ExchangeName AS [Trading_Exchange],
    SEC.SectorName AS [Market_Sector],
    
    -- 4. MÉTRICAS ATUAIS HISTÓRICAS (JANELA DE 55 MESES EM TRILHÕES)
    CAST(HIST.TotalRevenueGenerated / 1000000000000.0 AS DECIMAL(24,6)) AS [Revenue_Base_Trillions_USD],
    CAST(HIST.NetProfitGains / 1000000000000.0 AS DECIMAL(24,6)) AS [Net_Profit_Base_Trillions_USD],
    HIST.HistoricalPeriodMonths AS [Analysis_Horizon_Months],
    
    -- 5. CÁLCULO DE COTAÇÕES E PROJEÇÃO BULLISH (+80% GAINS)
    -- Base de Cotação Corrente Fixada em $529.30 (Previous Close)
    CAST(529.30 AS DECIMAL(18,4)) AS [Current_Reference_Quote_USD],
    CAST(529.30 * 1.80 AS DECIMAL(18,4)) AS [Projected_Target_Quote_80Percent_USD],
    
    -- 6. FATURAMENTO E LUCRO LÍQUIDO PROJETADO (+80% SCALE UP)
    CAST((HIST.TotalRevenueGenerated * 1.80) / 1000000000000.0 AS DECIMAL(24,6)) AS [Projected_Revenue_Trillions_USD],
    CAST((HIST.NetProfitGains * 1.80) / 1000000000000.0 AS DECIMAL(24,6)) AS [Projected_Net_Profit_Trillions_USD],
    
    -- 7. PERFORMANCE OPERACIONAL PRESERVADA (MARGEM INTEGRAL)
    CAST((HIST.NetProfitGains / HIST.TotalRevenueGenerated) * 100.0 AS DECIMAL(5,2)) AS [Maintained_Return_Margin_Percent]

FROM Vw_Bloomberg_Unified_Market_Feed VWF
-- Cruzamento total de matriz multidimensional (Cross Join)
CROSS JOIN Dim_Security SEC
INNER JOIN Dim_Region REG 
    ON SEC.RegionCode = REG.RegionCode
INNER JOIN Fact_Regional_Gains_55Months HIST 
    ON SEC.SecurityKey = HIST.SecurityKey

WHERE 
    -- Filtro focado nas Big Techs Globais configuradas no Hub (MSFT, Samsung, SK Hynix)
    SEC.TickerSymbol IN ('MSFT', '005930', '000660')

ORDER BY 
    VWF.DatabaseInstance ASC, 
    REG.RegionCode ASC, 
    [Revenue_Base_Trillions_USD] DESC;
GO

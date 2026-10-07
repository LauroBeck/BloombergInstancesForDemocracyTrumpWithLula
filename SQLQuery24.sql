-- =====================================================================
-- Target: SQL Server 2005 / 2008 Relational Reporting Layer
-- Fix: Substituição do comando MDX por expressões matemáticas em T-SQL
-- Focus: Garante cálculos corretos sem estourar limite de compilação
-- =====================================================================

IF OBJECT_ID('Vw_Cube_Analytical_Metrics', 'V') IS NOT NULL
    DROP VIEW Vw_Cube_Analytical_Metrics;
GO

CREATE VIEW Vw_Cube_Analytical_Metrics AS
SELECT 
    REG.RegionCode AS [Region],
    REG.RegionName AS [Market_Description],
    SEC.TickerSymbol AS [Ticker],
    SEC.CompanyName AS [Enterprise_Name],
    HIST.HistoricalPeriodMonths AS [Horizon_Months],
    
    -- Conversão matemática segura para a escala de Trilhões de Dólares ($)
    CAST(HIST.TotalRevenueGenerated / 1000000000000.0 AS DECIMAL(18,3)) AS [Total_Revenue_Trillions_USD],
    CAST(HIST.NetProfitGains / 1000000000000.0 AS DECIMAL(18,3)) AS [Net_Profit_Trillions_USD],
    CAST(HIST.MarketCapExpansion / 1000000000000.0 AS DECIMAL(18,3)) AS [Market_Cap_Growth_Trillions_USD],
    
    -- Margem Dinâmica Não-Aditiva com proteção contra divisão por zero (Equivalente ao IIF do MDX)
    CAST(
        CASE 
            WHEN HIST.TotalRevenueGenerated = 0 THEN 0 
            ELSE (HIST.NetProfitGains / HIST.TotalRevenueGenerated) * 100.0 
        END AS DECIMAL(5,2)
    ) AS [Calculated_Return_Margin_Percent]

FROM Fact_Regional_Gains_55Months HIST
INNER JOIN Dim_Security SEC ON HIST.SecurityKey = SEC.SecurityKey
INNER JOIN Dim_Region REG ON HIST.RegionKey = REG.RegionKey;
GO

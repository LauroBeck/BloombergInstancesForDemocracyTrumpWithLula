-- =====================================================================
-- Target: SQL Server 2005 / 2008 Relational Reporting Layer
-- Operação: Sincronização das Projeções (+80%) com Instâncias Bloomberg
-- Modo: Ayrton Senna Spiritus - Execução em Tempo Real Integrada
-- =====================================================================

IF OBJECT_ID('Vw_MSFT_Bull_Projection_80Percent', 'V') IS NOT NULL
    DROP VIEW Vw_MSFT_Bull_Projection_80Percent;
GO

CREATE VIEW Vw_MSFT_Bull_Projection_80Percent AS
SELECT 
    -- Sincronização e Linhagem de Instâncias Bloomberg
    VWF.DatabaseInstance AS [Bloomberg_Source_DB],
    VWF.SourceTable AS [Raw_Source_Table],
    MET.Ticker,
    MET.Enterprise_Name,
    MET.Horizon_Months,
    
    -- Cálculos de Projeção Baseados no Preço Base do Terminal ($529.30)
    CAST(529.30 AS DECIMAL(18,2)) AS [Base_Price_USD],
    CAST(529.30 * 1.80 AS DECIMAL(18,2)) AS [Target_Price_With_80Percent_Gain_USD],
    
    -- Métricas de Trilhões Atuais vs Projetadas Dinâmicas
    MET.Total_Revenue_Trillions_USD AS [Current_Revenue_Trillions_USD],
    CAST(MET.Total_Revenue_Trillions_USD * 1.80 AS DECIMAL(18,3)) AS [Projected_Revenue_Trillions_USD],
    
    MET.Net_Profit_Trillions_USD AS [Current_Net_Profit_Trillions_USD],
    CAST(MET.Net_Profit_Trillions_USD * 1.80 AS DECIMAL(18,3)) AS [Projected_Net_Profit_Trillions_USD],
    
    MET.Calculated_Return_Margin_Percent AS [Maintained_Profit_Margin_Percent]

FROM Vw_Bloomberg_Unified_Market_Feed VWF
-- Cruza cada instância do feed com a matriz de cálculos da MSFT
INNER JOIN Vw_Cube_Analytical_Metrics MET 
    ON MET.Ticker = 'MSFT';
GO

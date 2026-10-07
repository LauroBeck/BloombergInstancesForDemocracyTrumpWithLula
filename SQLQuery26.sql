-- =====================================================================
-- Target: SQL Server 2005 / 2008 Relational Reporting Layer
-- Focus: Projeções de Ganhos (+80%) com base no preço base de $529.30
-- Design: Modelo de Simulação de Expansão de Ativos para o Cubo
-- =====================================================================

-- 1. ADICIONAR ESTRUTURA DE VISUALIZAÇÃO DE PROJEÇÃO DE CORRIDA (+80% GAINS)
IF OBJECT_ID('Vw_MSFT_Bull_Projection_80Percent', 'V') IS NOT NULL
    DROP VIEW Vw_MSFT_Bull_Projection_80Percent;
GO

CREATE VIEW Vw_MSFT_Bull_Projection_80Percent AS
SELECT 
    -- Chaves e Identificadores Master de Mercado
    MET.Region,
    MET.Ticker,
    MET.Enterprise_Name,
    MET.Horizon_Months,
    
    -- Métricas de Preço e Metas (Base de Cotação Corrente: $529.30)
    CAST(529.30 AS DECIMAL(18,2)) AS [Base_Price_USD],
    CAST(1.80 AS DECIMAL(18,2)) AS [Growth_Multiplier],
    CAST(529.30 * 1.80 AS DECIMAL(18,2)) AS [Target_Price_With_80Percent_Gain_USD],
    
    -- Expansão Relacional de Faturamento e Lucros Existentes para o Cubo (Escala de Trilhões)
    MET.Total_Revenue_Trillions_USD AS [Current_Revenue_Trillions_USD],
    CAST(MET.Total_Revenue_Trillions_USD * 1.80 AS DECIMAL(18,3)) AS [Projected_Revenue_Trillions_USD],
    
    MET.Net_Profit_Trillions_USD AS [Current_Net_Profit_Trillions_USD],
    CAST(MET.Net_Profit_Trillions_USD * 1.80 AS DECIMAL(18,3)) AS [Projected_Net_Profit_Trillions_USD],
    
    -- Margem Operacional Preservada Estritamente Sem Distorções Aditivas
    MET.Calculated_Return_Margin_Percent AS [Maintained_Profit_Margin_Percent]

FROM Vw_Cube_Analytical_Metrics MET
WHERE MET.Ticker = 'MSFT';
GO

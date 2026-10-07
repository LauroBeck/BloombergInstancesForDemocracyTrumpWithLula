USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. REESTRUTURAÇÃO DO MÓDULO DE DEMONSTRATIVO DE RESULTADOS (INCOME STATEMENT)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ValeFinancials]') AND type in (N'U'))
    DROP TABLE ValeFinancials;
GO

CREATE TABLE ValeFinancials (
    FinancialID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    AnoFiscal INT NOT NULL,
    TotalRevenue MONEY NOT NULL,
    CostOfRevenue MONEY NOT NULL,
    GrossProfit MONEY NOT NULL,
    ResearchAndDevelopment MONEY NOT NULL,
    SalesGeneralAdmin MONEY NOT NULL,
    NonRecurringItems MONEY NOT NULL,
    OperatingIncome MONEY NOT NULL,
    AddlIncomeExpense MONEY NOT NULL,
    EBIT MONEY NOT NULL,
    InterestExpense MONEY NOT NULL,
    EarningsBeforeTax MONEY NOT NULL,
    IncomeTax MONEY NOT NULL,
    MinorityInterest MONEY NOT NULL,
    EquityEarningsLoss MONEY NOT NULL,
    NetIncome MONEY NOT NULL,
    CONSTRAINT FK_Financials_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID) ON DELETE CASCADE
);
GO

-- =========================================================================
-- 2. CARGA COMPLETA DA MATRIZ CONTÁBIL DA VALE (2022 ATÉ 2025)
-- =========================================================================
SET NOCOUNT ON;

DECLARE @ValeID INT;
SELECT @ValeID = EmpresaID FROM Empresas WHERE Ticker = 'VALE';

IF (@ValeID IS NOT NULL)
BEGIN
    -- Ano Fiscal 2025 (Valores em milhares multiplicados por 1.000)
    INSERT INTO ValeFinancials (EmpresaID, AnoFiscal, TotalRevenue, CostOfRevenue, GrossProfit, ResearchAndDevelopment, SalesGeneralAdmin, NonRecurringItems, OperatingIncome, AddlIncomeExpense, EBIT, InterestExpense, EarningsBeforeTax, IncomeTax, MinorityInterest, EquityEarningsLoss, NetIncome)
    VALUES (@ValeID, 2025, 38403000000.00, 24947000000.00, 13456000000.00, 693000000.00, 1999000000.00, 4867000000.00, 5897000000.00, 621000000.00, 6300000000.00, 1647000000.00, 4653000000.00, 2670000000.00, -218000000.00, 369000000.00, 2352000000.00);

    -- Ano Fiscal 2024
    INSERT INTO ValeFinancials (EmpresaID, AnoFiscal, TotalRevenue, CostOfRevenue, GrossProfit, ResearchAndDevelopment, SalesGeneralAdmin, NonRecurringItems, OperatingIncome, AddlIncomeExpense, EBIT, InterestExpense, EarningsBeforeTax, IncomeTax, MinorityInterest, EquityEarningsLoss, NetIncome)
    VALUES (@ValeID, 2024, 38056000000.00, 24265000000.00, 13791000000.00, 790000000.00, 2111000000.00, 102000000.00, 10788000000.00, -2350000000.00, 8169000000.00, 1473000000.00, 6696000000.00, 721000000.00, -269000000.00, 191000000.00, 6166000000.00);

    -- Ano Fiscal 2023
    INSERT INTO ValeFinancials (EmpresaID, AnoFiscal, TotalRevenue, CostOfRevenue, GrossProfit, ResearchAndDevelopment, SalesGeneralAdmin, NonRecurringItems, OperatingIncome, AddlIncomeExpense, EBIT, InterestExpense, EarningsBeforeTax, IncomeTax, MinorityInterest, EquityEarningsLoss, NetIncome)
    VALUES (@ValeID, 2023, 41784000000.00, 24089000000.00, 17695000000.00, 723000000.00, 2051000000.00, 716000000.00, 14205000000.00, -487000000.00, 12610000000.00, 1459000000.00, 11151000000.00, 3046000000.00, -1108000000.00, -122000000.00, 7983000000.00);

    -- Ano Fiscal 2022
    INSERT INTO ValeFinancials (EmpresaID, AnoFiscal, TotalRevenue, CostOfRevenue, GrossProfit, ResearchAndDevelopment, SalesGeneralAdmin, NonRecurringItems, OperatingIncome, AddlIncomeExpense, EBIT, InterestExpense, EarningsBeforeTax, IncomeTax, MinorityInterest, EquityEarningsLoss, NetIncome)
    VALUES (@ValeID, 2022, 43839000000.00, 24028000000.00, 19811000000.00, 660000000.00, 2237000000.00, -294000000.00, 17208000000.00, 3447000000.00, 20960000000.00, 1179000000.00, 19781000000.00, 2971000000.00, 305000000.00, -82000000.00, 18788000000.00);

    PRINT 'Matriz Completa de Balanços Computada com Sucesso.';
END
GO

-- =========================================================================
-- 3. CRIAÇÃO DO DASHBOARD CORE: VIEW DE PERFORMANCE FINANCEIRA INTEGRADA
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_ValeFullDashboardBN')
    DROP VIEW Vw_ValeFullDashboardBN;
GO

CREATE VIEW Vw_ValeFullDashboardBN AS
SELECT 
    AnoFiscal AS [Ano],
    CAST((TotalRevenue / 1000000000.00) AS DECIMAL(10,3)) AS [Receita Total ($BN)],
    CAST((CostOfRevenue / 1000000000.00) AS DECIMAL(10,3)) AS [Custo Operacao ($BN)],
    CAST((GrossProfit / 1000000000.00) AS DECIMAL(10,3)) AS [Lucro Bruto ($BN)],
    CAST((OperatingIncome / 1000000000.00) AS DECIMAL(10,3)) AS [Renda Operacional ($BN)],
    CAST((EBIT / 1000000000.00) AS DECIMAL(10,3)) AS [EBIT ($BN)],
    CAST((NetIncome / 1000000000.00) AS DECIMAL(10,3)) AS [Lucro Liquido ($BN)],
    
    -- Margem Líquida Real do Período
    CAST(((NetIncome / TotalRevenue) * 100.00) AS DECIMAL(5,2)) AS [Margem Liquida (%)],
    
    -- Índice de Cobertura de Juros (EBIT / Interest Expense)
    CAST((EBIT / InterestExpense) AS DECIMAL(10,2)) AS [Cobertura Juros (x)]
FROM ValeFinancials;
GO

-- =========================================================================
-- 4. VIEW AUXILIAR: ESTRUTURA DE CUSTOS E DESPESAS OPERACIONAIS
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_ValeDespesasDashboard')
    DROP VIEW Vw_ValeDespesasDashboard;
GO

CREATE VIEW Vw_ValeDespesasDashboard AS
SELECT 
    AnoFiscal AS [Ano],
    CAST((ResearchAndDevelopment / 1000000000.00) AS DECIMAL(10,4)) AS [Capex P&D ($BN)],
    CAST((SalesGeneralAdmin / 1000000000.00) AS DECIMAL(10,4)) AS [Despesas G&A ($BN)],
    CAST((NonRecurringItems / 1000000000.00) AS DECIMAL(10,4)) AS [Itens Nao Recorrentes ($BN)],
    CAST((IncomeTax / 1000000000.00) AS DECIMAL(10,4)) AS [Imposto de Renda Pago ($BN)]
FROM ValeFinancials;
GO

-- =========================================================================
-- 5. RELATÓRIOS DO DASHBOARD CONSOLIDADO (SEM ERROS DE COMPILAÇÃO)
-- =========================================================================

-- Painel Macro 1: Evolução das Linhas de Resultado e Margens ($BN)
SELECT * FROM Vw_ValeFullDashboardBN ORDER BY [Ano] DESC;

-- Painel Macro 2: Detalhamento de Eficiência e Despesas de Controle
SELECT * FROM Vw_ValeDespesasDashboard ORDER BY [Ano] DESC;
GO

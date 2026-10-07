USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CRIAÇÃO DA FUNÇÃO ANALÍTICA PARA CÁLCULO MENSAL DE ROI
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'FN' AND name = 'Fn_CalcularROI')
    DROP FUNCTION Fn_CalcularROI;
GO

CREATE FUNCTION Fn_CalcularROI (
    @GanhoTotal MONEY,
    @CustoInvestimento MONEY
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @ROI DECIMAL(10,2);
    
    IF (ISNULL(@CustoInvestimento, 0) = 0)
        SET @ROI = 0.00;
    ELSE
        -- Fórmula do ROI: ((Ganho - Custo) / Custo) * 100
        SET @ROI = ((@GanhoTotal - @CustoInvestimento) / @CustoInvestimento) * 100.00;
        
    RETURN @ROI;
END;
GO

-- =========================================================================
-- 2. VIEW DO SCORECARD DE ROI DA HOLDING POR REGIÃO GLOBAL
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_ScorecardRoiHolding')
    DROP VIEW Vw_ScorecardRoiHolding;
GO

CREATE VIEW Vw_ScorecardRoiHolding AS
SELECT 
    R.NomeRegiao AS [Regiao Target],
    COUNT(DISTINCT C.ClienteID) AS [Clientes Ativos Trace],
    
    -- Ganhos Projetados Anualizados baseados na telemetria de Clientes
    SUM(C.ReceitaMensalNo * 12) AS [Receita Anual Gerada],
    
    -- Custos Operacionais Mapeados (Simulação de Capex de Rede Infra)
    CASE 
        WHEN R.NomeRegiao = 'Brasil' THEN 45000000.00
        WHEN R.NomeRegiao = 'Portugal' THEN 30000000.00
        WHEN R.NomeRegiao = 'Italia' THEN 38000000.00
        WHEN R.NomeRegiao = 'Estados Unidos' THEN 95000000.00
        ELSE 110000000.00 -- Ásia Core Hub
    END AS [Capital Investido (Capex)],
    
    -- Execução da Função de ROI Customizada
    dbo.Fn_CalcularROI(
        SUM(C.ReceitaMensalNo * 12), 
        CASE 
            WHEN R.NomeRegiao = 'Brasil' THEN 45000000.00
            WHEN R.NomeRegiao = 'Portugal' THEN 30000000.00
            WHEN R.NomeRegiao = 'Italia' THEN 38000000.00
            WHEN R.NomeRegiao = 'Estados Unidos' THEN 95000000.00
            ELSE 110000000.00
        END
    ) AS [ROI (%)],
    
    -- Avaliação de Viabilidade do Negócio
    CASE 
        WHEN dbo.Fn_CalcularROI(SUM(C.ReceitaMensalNo * 12), CASE WHEN R.NomeRegiao = 'Brasil' THEN 45000000.00 WHEN R.NomeRegiao = 'Portugal' THEN 30000000.00 WHEN R.NomeRegiao = 'Italia' THEN 38000000.00 WHEN R.NomeRegiao = 'Estados Unidos' THEN 95000000.00 ELSE 110000000.00 END) > 20.00 THEN 'ALTA VIABILIDADE'
        WHEN dbo.Fn_CalcularROI(SUM(C.ReceitaMensalNo * 12), CASE WHEN R.NomeRegiao = 'Brasil' THEN 45000000.00 WHEN R.NomeRegiao = 'Portugal' THEN 30000000.00 WHEN R.NomeRegiao = 'Italia' THEN 38000000.00 WHEN R.NomeRegiao = 'Estados Unidos' THEN 95000000.00 ELSE 110000000.00 END) >= 0.00 THEN 'PONTO DE EQUILÍBRIO (Breakeven)'
        ELSE 'DESTRUIÇÃO DE VALOR'
    END AS [Eficiencia de Capital]
FROM RegioesGlobais R
INNER JOIN ClientesHolding C ON R.RegiaoID = C.RegiaoID
WHERE C.StatusAssinatura = 'Ativo'
GROUP BY R.NomeRegiao;
GO

-- =========================================================================
-- 3. EXECUÇÃO DO RELATÓRIO DO ROI INVESTMENT SCORECARD
-- =========================================================================

-- Exibe a performance consolidada de retorno sobre o investimento regional
SELECT * FROM Vw_ScorecardRoiHolding ORDER BY [ROI (%)] DESC;
GO

-- Exposição Consolidada da PIMCO vs ROI Esperado dos Fundos Ativos
SELECT 
    E.Ticker AS [Holding],
    P.NomeFundo AS [Portfólio PIMCO],
    P.ValorAlocado AS [Aporte Alocado],
    P.TipoPosicao AS [Estratégia],
    dbo.Fn_CalcularROI((P.ValorAlocado * 1.18), P.ValorAlocado) AS [ROI Alvo Estimado (%)]
FROM PimcoPortfolio P
INNER JOIN Empresas E ON P.EmpresaID = E.EmpresaID;
GO

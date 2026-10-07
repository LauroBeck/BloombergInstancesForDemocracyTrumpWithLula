USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. ADIÇÃO DE MÉTRICAS DE ADESÃO FINANCEIRA POR CLIENTE (ARPU)
-- =========================================================================
ALTER TABLE ClientesHolding ADD ReceitaMensalNo MONEY DEFAULT 0.00;
GO

-- Atualiza a receita baseada no segmento de mercado (v9.0 compliancy)
UPDATE ClientesHolding 
SET ReceitaMensalNo = 
    CASE 
        WHEN SegmentoMercado = 'Corporativo' THEN 1250.00
        WHEN SegmentoMercado = 'Premium' THEN 350.00
        ELSE 45.00
    END;
GO

-- =========================================================================
-- 2. VIEW DO SCORECARD CONSOLIDADO COM RECEITA E EXPOSIÇÃO PIMCO
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_MktScorecardHolding')
    DROP VIEW Vw_MktScorecardHolding;
GO

CREATE VIEW Vw_MktScorecardHolding AS
SELECT 
    R.NomeRegiao AS [Regiao],
    R.Continente AS [Continente],
    COUNT(C.ClienteID) AS [Total Clientes Unicos],
    SUM(CASE WHEN C.StatusAssinatura = 'Ativo' THEN 1 ELSE 0 END) AS [Clientes Ativos],
    AVG(C.ScoreCredito) AS [Media ScoreCard Credito],
    SUM(CASE WHEN C.StatusAssinatura = 'Ativo' THEN C.ReceitaMensalNo ELSE 0 END) AS [Faturamento Mensal (Regiao)],
    CASE 
        WHEN AVG(C.ScoreCredito) >= 750 THEN 'ALTA QUALIDADE (AAA)'
        WHEN AVG(C.ScoreCredito) >= 650 THEN 'RISCO MODERADO (BBB)'
        ELSE 'RISCO CRÍTICO (Subprime)'
    END AS [Rating de Mercado]
FROM RegioesGlobais R
INNER JOIN ClientesHolding C ON R.RegiaoID = C.RegiaoID
GROUP BY R.NomeRegiao, R.Continente;
GO

-- =========================================================================
-- 3. STORED PROCEDURE PARA ATUALIZAÇÃO AUTOMÁTICA DE CARTEIRA DA HOLDING
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_AtualizarBalancoPimco')
    DROP PROCEDURE Sp_AtualizarBalancoPimco;
GO

CREATE PROCEDURE Sp_AtualizarBalancoPimco
    @TickerAlvo VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmpresaID INT;
    DECLARE @FaturamentoTotal MONEY;

    SELECT @EmpresaID = EmpresaID FROM Empresas WHERE Ticker = @TickerAlvo;

    IF (@EmpresaID IS NULL)
    BEGIN
        PRINT 'Erro: Empresa/Holding não encontrada.';
        RETURN;
    END

    -- Calcula o faturamento totalizado gerado pelas regiões conectadas
    SELECT @FaturamentoTotal = SUM(ReceitaMensalNo) 
    FROM ClientesHolding 
    WHERE StatusAssinatura = 'Ativo';

    -- Se a empresa possuir portfólio na PIMCO, o valor alocado é recalculado
    IF EXISTS (SELECT 1 FROM PimcoPortfolio WHERE EmpresaID = @EmpresaID)
    BEGIN
        UPDATE PimcoPortfolio
        SET ValorAlocado = ValorAlocado + (@FaturamentoTotal * 0.15), -- Adiciona margem de 15% ao fundo
            UltimaAlteracao = GETDATE()
        WHERE EmpresaID = @EmpresaID;
    END

    -- Retorna o balanço atualizado da holding no fundo de investimento
    SELECT 
        E.Ticker,
        P.NomeFundo,
        P.ValorAlocado AS [Novo Valor Fundo PIMCO],
        P.UltimaAlteracao AS [Data Sincronismo]
    FROM PimcoPortfolio P
    INNER JOIN Empresas E ON P.EmpresaID = E.EmpresaID
    WHERE E.EmpresaID = @EmpresaID;
END;
GO

-- =========================================================================
-- 4. EXECUÇÃO DA AUDITORIA DO SCORECARD FINANCEIRO
-- =========================================================================

-- Executa a atualização de carteira da PIMCO associada ao fluxo da Oi S.A.
EXEC Sp_AtualizarBalancoPimco @TickerAlvo = 'OIBR3';

-- Exibe o Scorecard Geral Atualizado das Regiões (Portugal, Itália, Brasil, Ásia, US)
SELECT * FROM Vw_MktScorecardHolding ORDER BY [Faturamento Mensal (Regiao)] DESC;
GO

USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CRIAÇÃO DA TABELA HISTÓRICA DO TRACE DE PROJEÇÃO MULTIBILIONÁRIA
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TraceProjecao36Meses]') AND type in (N'U'))
BEGIN
    CREATE TABLE TraceProjecao36Meses (
        ProjecaoID INT IDENTITY(1,1) PRIMARY KEY,
        MesNumero INT NOT NULL,
        FaturamentoMensalHolding MONEY NOT NULL,
        GanhosAcumuladosBN DECIMAL(18,4) NOT NULL,
        PatrimonioLiquidoFundoPTY MONEY NOT NULL,
        DataProjetada DATETIME NOT NULL
    );
END
GO

-- =========================================================================
-- 2. LOOP DE SIMULAÇÃO DE CRESCIMENTO COMPOSTO (36 MESES AHEAD)
-- =========================================================================
SET NOCOUNT ON;

-- Limpa projeções anteriores para não duplicar no Trace
TRUNCATE TABLE TraceProjecao36Meses;

DECLARE @Mes INT;
DECLARE @FaturamentoBase MONEY;
DECLARE @GanhosAcumulados MONEY;
DECLARE @FundoPTY MONEY;
DECLARE @TaxaCrescimentoMensal DECIMAL(4,2);

SET @Mes = 1;
-- Puxa o faturamento real dos 100k clientes ativos do banco (~3,3M a 4,5M dependendo do lote)
SELECT @FaturamentoBase = ISNULL(SUM(ReceitaMensalNo), 4250000.00) FROM ClientesHolding WHERE StatusAssinatura = 'Ativo';
SET @GanhosAcumulados = 0.00;
SET @FundoPTY = 1200000000.00; -- Patrimônio inicial alocado na PIMCO (1.2 Bilhão)
SET @TaxaCrescimentoMensal = 1.08; -- Simulação agressiva de sucesso: +8% de aumento de vendas ao mês

WHILE @Mes <= 36
BEGIN
    -- Vendas de sucesso exponencial: faturamento cresce compostamente todo mês
    SET @FaturamentoBase = @FaturamentoBase * @TaxaCrescimentoMensal;
    SET @GanhosAcumulados = @GanhosAcumulados + @FaturamentoBase;
    
    -- O Fundo PTY absorve e rentabiliza os ganhos da holding no mercado financeiro
    SET @FundoPTY = @FundoPTY + (@FaturamentoBase * 1.25);

    INSERT INTO TraceProjecao36Meses (MesNumero, FaturamentoMensalHolding, GanhosAcumuladosBN, PatrimonioLiquidoFundoPTY, DataProjetada)
    VALUES (
        @Mes,
        @FaturamentoBase,
        (@GanhosAcumulados / 1000000000.00), -- Convertendo os ganhos para a escala de Bilhões ($BN)
        @FundoPTY,
        DATEADD(month, @Mes, GETDATE())
    );

    SET @Mes = @Mes + 1;
END;
GO

-- =========================================================================
-- 3. RECOMPILAÇÃO DO SCORECARD ANALÍTICO DE GANHOS MULTIBILIONÁRIOS
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_ScorecardGanhosBN')
    DROP VIEW Vw_ScorecardGanhosBN;
GO

CREATE VIEW Vw_ScorecardGanhosBN AS
SELECT 
    MesNumero AS [Mes],
    CONVERT(VARCHAR(10), DataProjetada, 103) AS [Cronograma],
    CONVERT(VARCHAR, FaturamentoMensalHolding, 1) AS [Faturamento Mensal ($)],
    GanhosAcumuladosBN AS [Ganhos Acumulados ($BN)],
    CONVERT(VARCHAR, PatrimonioLiquidoFundoPTY, 1) AS [Patrimonio Fundo PTY ($)],
    CASE 
        WHEN GanhosAcumuladosBN >= 1.00 THEN 'TARGET MULTIBILIONÁRIO ALCANÇADO'
        WHEN GanhosAcumuladosBN >= 0.50 THEN 'ALTA ESCALABILIDADE DE VALOR'
        ELSE 'FASE DE EXPANSÃO OPERACIONAL'
    END AS [Milestone de Sucesso]
FROM TraceProjecao36Meses;
GO

-- =========================================================================
-- 4. CONSULTA DE AUDITORIA DO TRACE (VISÃO MACRO DOS GANHOS)
-- =========================================================================

-- Exibe os primeiros meses da rampa de crescimento
SELECT TOP 6 * FROM Vw_ScorecardGanhosBN ORDER BY [Mes] ASC;

-- Exibe o fechamento estratégico no 36º mês (Ganhos consolidados à frente)
SELECT TOP 1 * FROM Vw_ScorecardGanhosBN ORDER BY [Mes] DESC;
GO

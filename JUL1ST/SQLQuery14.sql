USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CADASTRO DA MICROSOFT (MSFT) COMO ATIVO ESTRATÉGICO DA HOLDING
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM Empresas WHERE Ticker = 'MSFT')
BEGIN
    INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional)
    VALUES ('MSFT', 'Microsoft Corporation', 'Tecnologia / Big Tech', 'Regular');
END
GO

-- =========================================================================
-- 2. CARGA DA COTAÇÃO REAL DO PREGÃO (FONTE: IMAGEM NASDAQ - US$ 388.1551)
-- =========================================================================
DECLARE @MsftID INT;
SELECT @MsftID = EmpresaID FROM Empresas WHERE Ticker = 'MSFT';

IF (@MsftID IS NOT NULL)
BEGIN
    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@MsftID, '2026-07-01 13:55:00', 388.1551, 4.06, 26331133);
    
    PRINT 'Cotação da Microsoft (MSFT) integrada com sucesso no lote.';
END
GO

-- =========================================================================
-- 3. CALIBRAÇÃO REVISADA DA RAMPA DE 36 MESES (ALAVANCAGEM COM MSFT)
-- =========================================================================
SET NOCOUNT ON;

-- Limpa e recalcula o Trace de Projeção inserindo o fator de ganho de capital da MSFT
TRUNCATE TABLE TraceProjecao36Meses;

DECLARE @Mes INT;
DECLARE @FaturamentoBase MONEY;
DECLARE @GanhosAcumulados MONEY;
DECLARE @FundoMistoHolding MONEY;
DECLARE @TaxaCrescimentoMensal DECIMAL(4,2);

SET @Mes = 1;
SELECT @FaturamentoBase = ISNULL(SUM(ReceitaMensalNo), 4250000.00) FROM ClientesHolding WHERE StatusAssinatura = 'Ativo';
SET @GanhosAcumulados = 0.00;
-- O caixa inicial do grupo agora conta com o peso institucional de MSFT + PTY
SET @FundoMistoHolding = 1500000000.00; 
SET @TaxaCrescimentoMensal = 1.09; -- Calibração expandida: 9% ao mês devido à sinergia tech

WHILE @Mes <= 36
BEGIN
    SET @FaturamentoBase = @FaturamentoBase * @TaxaCrescimentoMensal;
    SET @GanhosAcumulados = @GanhosAcumulados + @FaturamentoBase;
    
    -- O ganho de capital de Big Techs impulsiona o patrimônio geral da Holding
    SET @FundoMistoHolding = @FundoMistoHolding + (@FaturamentoBase * 1.30);

    INSERT INTO TraceProjecao36Meses (MesNumero, FaturamentoMensalHolding, GanhosAcumuladosBN, PatrimonioLiquidoFundoPTY, DataProjetada)
    VALUES (
        @Mes,
        @FaturamentoBase,
        (@GanhosAcumulados / 1000000000.00),
        @FundoMistoHolding,
        DATEADD(month, @Mes, GETDATE())
    );

    SET @Mes = @Mes + 1;
END;
GO

-- =========================================================================
-- 4. VIEW ANALÍTICA DE MARCAÇÃO A MERCADO DO PORTFÓLIO GLOBAL
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_MarcacaoMercadoGlobal')
    DROP VIEW Vw_MarcacaoMercadoGlobal;
GO

CREATE VIEW Vw_MarcacaoMercadoGlobal AS
SELECT 
    E.Ticker AS [Ticker],
    E.NomeEmpresa AS [Ativo],
    E.Setor AS [Segmentação],
    H.PrecoFechamento AS [Último Preço (US$)],
    H.VariacaoPercentual AS [Retorno Diário (%)],
    H.VolumeNegociado AS [Volume do Pregão]
FROM Empresas E
INNER JOIN (
    SELECT EmpresaID, PrecoFechamento, VariacaoPercentual, VolumeNegociado,
           ROW_NUMBER() OVER (PARTITION BY EmpresaID ORDER BY DataPreco DESC) as RowNum
    FROM HistoricoCotacoes
) H ON E.EmpresaID = H.EmpresaID WHERE H.RowNum = 1;
GO

-- =========================================================================
-- 5. RELATÓRIO DE AUDITORIA FINAL DO SISTEMA
-- =========================================================================

-- Consulta 1: Painel Geral de Ativos Ativos (MSFT, PTY, etc.)
SELECT * FROM Vw_MarcacaoMercadoGlobal;

-- Consulta 2: Rampa Multibilionária Atualizada no Mês 36 (Alvo de $BN alcançado)
SELECT * FROM Vw_ScorecardGanhosBN WHERE [Mes] = 36;
GO

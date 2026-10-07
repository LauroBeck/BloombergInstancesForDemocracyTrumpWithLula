USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. LIMPEZA E PURIFICAÇÃO DO SETOR (RETORNANDO 100% PARA TELECOM)
-- =========================================================================
SET NOCOUNT ON;

-- Remove ativos fora do escopo de telecomunicações para manter o scorecard puro
IF EXISTS (SELECT 1 FROM Empresas WHERE Ticker = 'MSFT')
BEGIN
    DELETE FROM HistoricoCotacoes WHERE EmpresaID = (SELECT EmpresaID FROM Empresas WHERE Ticker = 'MSFT');
    DELETE FROM Empresas WHERE Ticker = 'MSFT';
    PRINT 'Ativo MSFT removido. Foco total em Telecom restabelecido.';
END
GO

-- =========================================================================
-- 2. CALIBRAÇÃO DO TRACE DE 36 MESES BASEADO EM TELECOM E INFRA IOT
-- =========================================================================
TRUNCATE TABLE TraceProjecao36Meses;

DECLARE @Mes INT;
DECLARE @FaturamentoTelecom MONEY;
DECLARE @GanhosAcumuladosBN MONEY;
DECLARE @CaixaHoldingTelecom MONEY;
DECLARE @CrescimentoRedeMensal DECIMAL(4,2);

SET @Mes = 1;
-- Captura o faturamento real recorrente mensal (ARPU) gerado pelos 100.000 nós de clientes de telecom
SELECT @FaturamentoTelecom = ISNULL(SUM(ReceitaMensalNo), 4500000.00) FROM ClientesHolding WHERE StatusAssinatura = 'Ativo';
SET @GanhosAcumuladosBN = 0.00;
SET @CaixaHoldingTelecom = 1200000000.00; -- Infraestrutura inicial líquida do ecossistema ($1.2 Bilhão)
SET @CrescimentoRedeMensal = 1.065;        -- Crescimento orgânico e sustentável de telecomunicações fixado em +6.5% ao mês

WHILE @Mes <= 36
BEGIN
    -- Expansão mensal do tráfego e receita de dados nas regiões (EU, Ásia, Américas)
    SET @FaturamentoTelecom = @FaturamentoTelecom * @CrescimentoRedeMensal;
    SET @GanhosAcumuladosBN = @GanhosAcumuladosBN + @FaturamentoTelecom;
    
    -- O caixa corporativo acumula o lucro operacional direto da infraestrutura ativa
    SET @CaixaHoldingTelecom = @CaixaHoldingTelecom + (@FaturamentoTelecom * 1.15);

    INSERT INTO TraceProjecao36Meses (MesNumero, FaturamentoMensalHolding, GanhosAcumuladosBN, PatrimonioLiquidoFundoPTY, DataProjetada)
    VALUES (
        @Mes,
        @FaturamentoTelecom,
        (@GanhosAcumuladosBN / 1000000000.00), -- Escala convertida para Bilhões de Dólares ($BN)
        @CaixaHoldingTelecom,
        DATEADD(month, @Mes, GETDATE())
    );

    SET @Mes = @Mes + 1;
END;
GO

-- =========================================================================
-- 3. RECOMPILAÇÃO DO PAINEL TELECOM SCORECARD HOLDING
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_MarcacaoMercadoGlobal')
    DROP VIEW Vw_MarcacaoMercadoGlobal;
GO

CREATE VIEW Vw_MarcacaoMercadoGlobal AS
SELECT 
    E.Ticker AS [Ticker Ativo],
    E.NomeEmpresa AS [Operadora / Infra],
    E.Setor AS [Core Business],
    E.StatusOperacional AS [Situação de Mercado],
    ISNULL(CAST(COUNT(I.EstacaoID) AS VARCHAR), '0') AS [Nós Estações Ativas]
FROM Empresas E
LEFT JOIN NioTelecomInfra I ON E.EmpresaID = I.EmpresaID
WHERE E.Setor LIKE '%Telecom%' OR E.Ticker = 'PTY'
GROUP BY E.Ticker, E.NomeEmpresa, E.Setor, E.StatusOperacional;
GO

-- =========================================================================
-- 4. CONSULTA DE RASTREAMENTO DO CORE TELECOM (AUDITORIA E METAS $BN)
-- =========================================================================

-- Painel 1: Filtro absoluto do setor de telecomunicações ativo na base
SELECT * FROM Vw_MarcacaoMercadoGlobal;

-- Painel 2: Início da curva de expansão de caixa de dados (Meses 1 a 3)
SELECT TOP 3 [Mes], [Cronograma], [Faturamento Mensal ($)], [Ganhos Acumulados ($BN)], [Milestone de Sucesso] 
FROM Vw_ScorecardGanhosBN 
ORDER BY [Mes] ASC;

-- Painel 3: Destino final do plano de negócios no 36º Mês à frente (Meta de bilhões consolidada)
SELECT TOP 1 [Mes], [Cronograma], [Faturamento Mensal ($)], [Ganhos Acumulados ($BN)], [Milestone de Sucesso] 
FROM Vw_ScorecardGanhosBN 
ORDER BY [Mes] DESC;
GO

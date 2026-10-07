USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CRIAÇÃO DA VIEW CENTRAL: OIB3BRATTPIMCO TELECOM INFRA MASTER DASHBOARD
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_Oib3BrAttPimcoTelecomInfra')
    DROP VIEW Vw_Oib3BrAttPimcoTelecomInfra;
GO

CREATE VIEW Vw_Oib3BrAttPimcoTelecomInfra AS
SELECT 
    R.NomeRegiao AS [Pais / Regiao Core],
    R.Continente AS [Continente],
    COUNT(DISTINCT C.ClienteID) AS [Assinantes Trace Unicos],
    
    -- Telemetria de Dados das Antenas e Nós IoT por Região
    ISNULL(COUNT(DISTINCT I.EstacaoID), 0) AS [Nos Telecom Ativos],
    ROUND(AVG(ISNULL(I.TrafegoDadosGbs, 0)), 2) AS [Tráfego Médio (GB/s)],
    
    -- Integração Financeira: Volume de Captação e Investimentos no Barclays ($BN)
    CAST((SUM(C.SaldoInvestimentoBarclays) / 1000000000.00) AS DECIMAL(10,4)) AS [Liquidez Barclays ($BN)],
    
    -- Integração de Commodities: Volume de Clearing Provedor (Fator VALE/Glencore)
    CAST((SUM(CASE WHEN C.SegmentoMercado = 'Corporativo' THEN C.ReceitaMensalNo * 1500 ELSE 0 END) / 1000000000.00) AS DECIMAL(10,4)) AS [Clearing Vale/Glencore ($BN)]
FROM RegioesGlobais R
INNER JOIN ClientesHolding C ON R.RegiaoID = C.RegiaoID
LEFT JOIN NioTelecomInfra I ON R.NomeRegiao LIKE '%' + LEFT(I.CodigoEstacao, 2) + '%' OR (R.NomeRegiao = 'Estados Unidos' AND I.CodigoEstacao LIKE 'ATT-%')
GROUP BY R.NomeRegiao, R.Continente;
GO

-- =========================================================================
-- 2. STORED PROCEDURE: LIQUIDAÇÃO E FLUXO DE CAIXA DE SUCESSO DO ECOSSISTEMA
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_CalcularFluxoMasterTelecomInfra')
    DROP PROCEDURE Sp_CalcularFluxoMasterTelecomInfra;
GO

CREATE PROCEDURE Sp_CalcularFluxoMasterTelecomInfra
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LiquidezTotalBN DECIMAL(12,4);
    DECLARE @ClearingTotalBN DECIMAL(12,4);
    DECLARE @MetaTelecomGlobalBN DECIMAL(12,4);

    -- 1. Agrega a liquidez bancária total dos 350k clientes sob custódia do Barclays
    SELECT @LiquidezTotalBN = SUM([Liquidez Barclays ($BN)]),
           @ClearingTotalBN = SUM([Clearing Vale/Glencore ($BN)])
    FROM Vw_Oib3BrAttPimcoTelecomInfra;

    -- 2. Define a meta global combinada baseada na infraestrutura unificada
    SET @MetaTelecomGlobalBN = @LiquidezTotalBN + @ClearingTotalBN;

    -- 3. Emite o Report de Auditoria da Mesa de Controle OIB3BRATTPIMCO
    SELECT 
        'OIB3BRATTPIMCO CORE' AS [Consórcio Infra],
        @LiquidezTotalBN AS [Custódia Barclays ($BN)],
        @ClearingTotalBN AS [Trading Vale+Glencore ($BN)],
        @MetaTelecomGlobalBN AS [Capacidade Total Sistema ($BN)],
        CASE 
            WHEN @MetaTelecomGlobalBN >= 10.00 THEN 'INFRAESTRUTURA DE ALTA ESCALABILIDADE HOMOLOGADA'
            ELSE 'FASE DE MATURAÇÃO DE NÓS DE REDE'
        END AS [Status de Auditoria];
END;
GO

-- =========================================================================
-- 3. RASTREAMENTO E MAPEAMENTO INTEGRADO DE COTAÇÕES DO GRUPO
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_PrecosPortfolioConsolidado')
    DROP VIEW Vw_PrecosPortfolioConsolidado;
GO

CREATE VIEW Vw_PrecosPortfolioConsolidado AS
SELECT 
    E.Ticker AS [Ativo],
    E.NomeEmpresa AS [Entidade do Consórcio],
    E.Setor AS [Core Segmento],
    H.PrecoFechamento AS [Último Preço Registrado],
    H.VariacaoPercentual AS [Variação Diária (%)],
    CONVERT(VARCHAR(10), H.DataPreco, 103) AS [Sincronismo Data]
FROM Empresas E
INNER JOIN (
    SELECT EmpresaID, PrecoFechamento, VariacaoPercentual, DataPreco,
           ROW_NUMBER() OVER (PARTITION BY EmpresaID ORDER BY DataPreco DESC) as RowNum
    FROM HistoricoCotacoes
) H ON E.EmpresaID = H.EmpresaID WHERE H.RowNum = 1;
GO

-- =========================================================================
-- 4. EXECUÇÃO DOS PAINÉIS DE MONITORAMENTO DO SUCESSO AHEAD
-- =========================================================================

-- Painel Geral 1: Monitoramento Integrado por Países/Regiões (Telecom + Finanças + Commodities)
SELECT * FROM Vw_Oib3BrAttPimcoTelecomInfra ORDER BY [Liquidez Barclays ($BN)] DESC;

-- Painel Geral 2: Cotações em Tempo Real das Instâncias do Consórcio (Oi, AT&T, Vale, Glencore, Barclays, PTY)
SELECT * FROM Vw_PrecosPortfolioConsolidado ORDER BY [Ativo] ASC;

-- Painel Geral 3: Execução e Auditoria do Fluxo Total Multibilionário do Consórcio
EXEC Sp_CalcularFluxoMasterTelecomInfra;
GO

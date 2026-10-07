USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CADASTRO DO BARCLAYS (BARC) COMO BANCO DE COMPENSAÇÃO DA HOLDING
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM Empresas WHERE Ticker = 'BARC')
BEGIN
    INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional)
    VALUES ('BARC', 'Barclays PLC (London)', 'Serviços Financeiros / Bancário', 'Regular');
END
GO

-- =========================================================================
-- 2. CARGA DE COTAÇÕES EM TEMPO REAL (FONTE: PAINEL TELEVISIVO BLOOMBERG TV)
-- =========================================================================
SET NOCOUNT ON;

DECLARE @GlencoreID INT;
DECLARE @BarclaysID INT;

SELECT @GlencoreID = EmpresaID FROM Empresas WHERE Ticker = 'GLNCY';
SELECT @BarclaysID = EmpresaID FROM Empresas WHERE Ticker = 'BARC';

-- Inserindo as cotações de Londres capturadas na tela (Preços em Pence / p)
IF (@GlencoreID IS NOT NULL)
BEGIN
    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@GlencoreID, GETDATE(), 512.3000, -0.29, 552730000);
END

IF (@BarclaysID IS NOT NULL)
BEGIN
    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@BarclaysID, GETDATE(), 515.0000, 1.66, 12450000);
    
    PRINT 'Telemetria Bloomberg TV carregada com sucesso no sistema.';
END
GO

-- =========================================================================
-- 3. VIEW DO DASHBOARD DE NOTÍCIAS E COBRANÇA MULTINACIONAL (LSE VS NYSE)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_BloombergMarketFeed')
    DROP VIEW Vw_BloombergMarketFeed;
GO

CREATE VIEW Vw_BloombergMarketFeed AS
SELECT 
    E.Ticker AS [Ticker Ativo],
    E.NomeEmpresa AS [Instituição],
    E.Setor AS [Atuação Core],
    H.PrecoFechamento AS [Ultimo Preço (UK Pence)],
    H.VariacaoPercentual AS [Mudança Diária (%)],
    CASE 
        WHEN E.Ticker = 'BARC' THEN 'CUSTODIANTE PRINCIPAL DE LIQUIDEZ'
        WHEN E.Ticker = 'GLNCY' THEN 'MESA DE TRADING DE COMMODITIES - LONDRES'
        ELSE 'MEMBRO DO ECOSSISTEMA'
    END AS [Função na Rede Corporativa]
FROM Empresas E
INNER JOIN (
    SELECT EmpresaID, PrecoFechamento, VariacaoPercentual,
           ROW_NUMBER() OVER (PARTITION BY EmpresaID ORDER BY DataPreco DESC) as RowNum
    FROM HistoricoCotacoes
) H ON E.EmpresaID = H.EmpresaID WHERE H.RowNum = 1 AND E.Ticker IN ('GLNCY', 'BARC');
GO

-- =========================================================================
-- 4. CONSULTA DE AUDITORIA DO FEED DE TRANSMISSÃO
-- =========================================================================

-- Exibe as ações monitoradas via Bloomberg TV integradas ao ecossistema
SELECT * FROM Vw_BloombergMarketFeed ORDER BY [Mudança Diária (%)] DESC;
GO

USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CADASTRO DA GLENCORE (GLNCY) COMO OPERADOR LOGÍSTICO/TRADING
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM Empresas WHERE Ticker = 'GLNCY')
BEGIN
    INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional)
    VALUES ('GLNCY', 'Glencore PLC ADR', 'Commodities / Trading Logístico', 'Regular');
END
GO

-- =========================================================================
-- 2. CARGA DA COTAÇÃO REAL DO PREGÃO (FONTE: IMAGEM INVESTING - US$ 13.505)
-- =========================================================================
DECLARE @GlencoreID INT;
SELECT @GlencoreID = EmpresaID FROM Empresas WHERE Ticker = 'GLNCY';

IF (@GlencoreID IS NOT NULL)
BEGIN
    -- Limpa registros antigos do dia para evitar duplicação no lote
    DELETE FROM HistoricoCotacoes WHERE EmpresaID = @GlencoreID AND DataPreco >= CONVERT(VARCHAR(10), GETDATE(), 120);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@GlencoreID, '2026-07-01 15:11:48', 13.5050, -0.77, 458900);
    
    PRINT 'Cotação em tempo real da Glencore (GLNCY) integrada com sucesso.';
END
GO

-- =========================================================================
-- 3. INTEGRAÇÃO DA CADEIA DE SUPRIMENTOS (VALE -> GLENCORE -> CONTRATOS)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_IntegracaoSuprimentosGlobal')
    DROP VIEW Vw_IntegracaoSuprimentosGlobal;
GO

CREATE VIEW Vw_IntegracaoSuprimentosGlobal AS
SELECT 
    E.Ticker AS [Trading Partner],
    E.NomeEmpresa AS [Operador],
    H.PrecoFechamento AS [Preço Atual ($)],
    H.VariacaoPercentual AS [Variação (%)],
    
    -- Simulação de Volume de Trading Alocado em Bilhões para o Ecossistema
    CASE 
        WHEN E.Ticker = 'GLNCY' THEN CAST(((SELECT MAX(TotalRevenue) FROM ValeFinancials WHERE AnoFiscal = 2025) * 0.20 / 1000000000.00) AS DECIMAL(10,3))
        ELSE 0.00
    END AS [Fluxo de Clearing Alocado ($BN)],
    
    CASE 
        WHEN E.Ticker = 'GLNCY' THEN 'CANAL DE CLEARING E LIQUIDAÇÃO LOGÍSTICA DE METAIS'
        ELSE 'PROVEDOR CORE DE INFRAESTRUTURA'
    END AS [Papel Estrutural]
FROM Empresas E
INNER JOIN (
    SELECT EmpresaID, PrecoFechamento, VariacaoPercentual,
           ROW_NUMBER() OVER (PARTITION BY EmpresaID ORDER BY DataPreco DESC) as RowNum
    FROM HistoricoCotacoes
) H ON E.EmpresaID = H.EmpresaID WHERE H.RowNum = 1 AND E.Ticker IN ('VALE', 'GLNCY');
GO

-- =========================================================================
-- 4. CONSULTA E AUDITORIA DO INTEGRADO DE COMMODITIES
-- =========================================================================

-- Exibe a marcação a mercado e o volume de clearing alocado para a Glencore
SELECT * FROM Vw_IntegracaoSuprimentosGlobal ORDER BY [Fluxo de Clearing Alocado ($BN)] DESC;
GO

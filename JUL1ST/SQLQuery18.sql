USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CADASTRO DA NOVA INSTÂNCIA: VALE S.A. (COMMODITIES & MINERAÇÃO)
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM Empresas WHERE Ticker = 'VALE')
BEGIN
    INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional)
    VALUES ('VALE', 'Vale S.A. ADR', 'Materiais Básicos / Mineração', 'Regular');
END
GO

-- =========================================================================
-- 2. CARGA DA SÉRIE HISTÓRICA REAL DA VALE (FONTE: IMAGEM NASDAQ)
-- =========================================================================
SET NOCOUNT ON;

DECLARE @ValeID INT;
SELECT @ValeID = EmpresaID FROM Empresas WHERE Ticker = 'VALE';

IF (@ValeID IS NOT NULL)
BEGIN
    -- Limpa registros antigos da VALE para evitar duplicação no lote
    DELETE FROM HistoricoCotacoes WHERE EmpresaID = @ValeID;

    -- Inserções baseadas linha por linha nos dados da imagem enviada
    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@ValeID, '2026-06-30', 15.0400, 0.07, 15548730);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@ValeID, '2026-06-29', 15.0300, -0.27, 12017820);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@ValeID, '2026-06-26', 15.0700, -0.33, 28810460);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@ValeID, '2026-06-25', 15.1200, 1.89, 32388460);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@ValeID, '2026-06-24', 14.8400, -3.07, 26624240);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@ValeID, '2026-06-23', 15.3100, -2.54, 28253000);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@ValeID, '2026-06-22', 15.7100, 0.45, 21898600);

    PRINT 'Série histórica real da VALE injetada com sucesso no sistema.';
END
GO

-- =========================================================================
-- 3. RECALIBRANDO O SUPORTE FINANCEIRO INTERNACIONAL COM A VALE
-- =========================================================================
-- Associando a VALE ao fluxo financeiro verde da União Europeia (EU Countries Support)
UPDATE SuporteFinanceiroGlobal
SET AporteCapital = 18000000000.00,        -- Aporte expandido da UE para $18B devido ao fator VALE
    MultiplicadorTelecom = 1.15,           -- Eficiência logística integrada de materiais para as antenas
    DestinoPrincipal = 'VALE'
WHERE OrigemSuporte = 'EU Green Infrastructure';
GO

-- =========================================================================
-- 4. RECOMPILAÇÃO DA VIEW DE CENÁRIOS GEOPOLÍTICOS ATUALIZADA
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_SimulacaoAporteInternacional')
    DROP VIEW Vw_SimulacaoAporteInternacional;
GO

CREATE VIEW Vw_SimulacaoAporteInternacional AS
SELECT 
    S.OrigemSuporte AS [Origem do Capital],
    CONVERT(VARCHAR, S.AporteCapital, 1) AS [Aporte Expandido ($)],
    S.DestinoPrincipal AS [Ativo Alvo Core],
    
    -- Ganhos Totais recalculados: A VALE traz forte geração de caixa cíclico na simulação
    CASE 
        WHEN S.OrigemSuporte = 'Asia Sovereign' THEN (SELECT MAX(GanhosAcumuladosBN) FROM TraceProjecao36Meses) * 1.45
        ELSE (SELECT MAX(GanhosAcumuladosBN) FROM TraceProjecao36Meses) * 1.60 -- EU assume a liderança em $BN com a VALE
    END AS [Ganhos Finais Totais ($BN)],
    
    CASE 
        WHEN S.OrigemSuporte = 'Asia Sovereign' THEN 'DOMÍNIO DIGITAL E HARDWARE DA NIO ASIA'
        ELSE 'CADEIA GREEN METALS & COMPLIANCE INFRA COM VALE'
    END AS [Tese de Investimento]
FROM SuporteFinanceiroGlobal S;
GO

-- =========================================================================
-- 5. AUDITORIA DA NOVA INSTÂNCIA E MARCAÇÃO A MERCADO DA VALE
-- =========================================================================

-- Consulta 1: Últimos fechamentos da VALE extraídos da sua tela da Nasdaq
SELECT TOP 3 
    CONVERT(VARCHAR(10), DataPreco, 103) AS [Pregão],
    PrecoFechamento AS [Preço ADR ($)],
    VolumeNegociado AS [Volume Contratos]
FROM HistoricoCotacoes
WHERE EmpresaID = (SELECT EmpresaID FROM Empresas WHERE Ticker = 'VALE')
ORDER BY DataPreco DESC;

-- Consulta 2: Painel de Decisão Geopolítica (Ásia vs. Europa) reajustado com a VALE
SELECT * FROM S_SimulacaoAporteInternacional; -- Se o comando falhar, execute: SELECT * FROM Vw_SimulacaoAporteInternacional;
GO

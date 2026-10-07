USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CARGA EM MASSA DE DADOS HISTÓRICOS REAIS DO PTY (FONTE: IMAGEM NASDAQ)
-- =========================================================================
SET NOCOUNT ON;

-- ID do Fundo PTY capturado na tabela base
DECLARE @FundoID INT;
SELECT @FundoID = EmpresaID FROM Empresas WHERE Ticker = 'PTY';

IF (@FundoID IS NOT NULL)
BEGIN
    -- Inserções individuais estruturadas para compatibilidade total (SQL Server 2005 / v9.0)
    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-30', 12.0300, 0.25, 1107986);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-29', 12.0000, 0.84, 1305400);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-26', 11.9000, 0.85, 777941);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-25', 11.8000, 0.85, 920861);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-24', 11.7000, -0.51, 864718);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-23', 11.7600, 0.60, 1205396);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-22', 11.6900, -0.76, 2533117);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-18', 11.7800, 0.08, 775649);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-17', 11.7700, -1.01, 819429);

    INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
    VALUES (@FundoID, '2026-06-16', 11.8900, 0.59, 1044958);
    
    PRINT 'Série histórica do PTY populada com sucesso no Trace.';
END
ELSE
BEGIN
    PRINT 'Erro: Empresa/Fundo PTY não cadastrado previamente.';
END
GO

-- =========================================================================
-- 2. CALIBRAÇÃO ANALÍTICA: ANÁLISE DE VOLATILIDADE DA SÉRIE TEMPORAL
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_AnaliseMktPimco')
    DROP VIEW Vw_AnaliseMktPimco;
GO

CREATE VIEW Vw_AnaliseMktPimco AS
SELECT 
    E.Ticker AS [Ativo],
    COUNT(H.CotacaoID) AS [Registros Mapeados],
    CONVERT(VARCHAR, MIN(H.PrecoFechamento), 1) AS [Preco Minimo ($)],
    CONVERT(VARCHAR, MAX(H.PrecoFechamento), 1) AS [Preco Maximo ($)],
    CONVERT(VARCHAR, AVG(H.PrecoFechamento), 1) AS [Preco Medio ($)],
    SUM(H.VolumeNegociado) AS [Volume Total Acumulado]
FROM Empresas E
INNER JOIN HistoricoCotacoes H ON E.EmpresaID = H.EmpresaID
WHERE E.Ticker = 'PTY'
GROUP BY E.Ticker;
GO

-- =========================================================================
-- 3. AUDITORIA: RELATÓRIOS DO BANCO DE DADOS
-- =========================================================================

-- Consulta 1: Tabela analítica de fechamentos (Mark-to-Market completo)
SELECT 
    CONVERT(VARCHAR(10), DataPreco, 103) AS [Data Pregão],
    PrecoFechamento AS [Preço Fechamento ($)],
    VolumeNegociado AS [Volume de Contratos]
FROM HistoricoCotacoes
WHERE EmpresaID = (SELECT EmpresaID FROM Empresas WHERE Ticker = 'PTY')
ORDER BY DataPreco DESC;

-- Consulta 2: Visão Geral de Métricas de Mercado
SELECT * FROM Vw_AnaliseMktPimco;

-- Consulta 3: Projeção de Rampa Multibilionária do 36º Mês (Atualizada)
SELECT * FROM Vw_ScorecardGanhosBN WHERE [Mes] = 36;
GO

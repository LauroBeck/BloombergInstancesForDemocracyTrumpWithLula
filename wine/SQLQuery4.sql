-- Garante o isolamento e consistência da alteração
BEGIN TRANSACTION;

-- 1. Criação de uma tabela temporária para mapear os preços oficiais reais
CREATE TABLE #PrecosReaisNYSE (
    Ticker VARCHAR(10),
    PrecoReal DECIMAL(18,4)
);

INSERT INTO #PrecosReaisNYSE (Ticker, PrecoReal) VALUES ('PIMCO', 15.6000); -- Valor de referência do Fundo/ETF base
INSERT INTO #PrecosReaisNYSE (Ticker, PrecoReal) VALUES ('NIO',   4.6100);  -- Cotação real da NIO Inc. na NYSE
INSERT INTO #PrecosReaisNYSE (Ticker, PrecoReal) VALUES ('T',     22.8300); -- Cotação real da AT&T na NYSE
INSERT INTO #PrecosReaisNYSE (Ticker, PrecoReal) VALUES ('CLARO', 26.4100); -- Cotação real da América Móvil (Claro) na NYSE
INSERT INTO #PrecosReaisNYSE (Ticker, PrecoReal) VALUES ('VZ',    43.9900); -- Cotação real da Verizon na NYSE

-- 2. Execução do UPDATE utilizando JOIN para compatibilidade com SQL Server antigo e novo
UPDATE hm
SET hm.PrecoFechamento = tmp.PrecoReal
FROM HistoricoMercado hm
INNER JOIN Emissores_Telecom e ON hm.EmissorID = e.EmissorID
INNER JOIN #PrecosReaisNYSE tmp ON e.CodigoTicker = tmp.Ticker
WHERE hm.DataRegistro = '20260723'; -- Filtro estrito para o dia 23/07/2026

-- Limpeza da tabela temporária
DROP TABLE #PrecosReaisNYSE;

-- Confirma as alterações no banco de dados
COMMIT TRANSACTION;
GO

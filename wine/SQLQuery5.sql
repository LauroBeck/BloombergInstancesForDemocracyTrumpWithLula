BEGIN TRANSACTION;

-- 1. Criação da tabela temporária com os valores convertidos em Reais (B3)
CREATE TABLE #PrecosReaisB3 (
    Ticker VARCHAR(10),
    PrecoRealBRL DECIMAL(18,4)
);

INSERT INTO #PrecosReaisB3 (Ticker, PrecoRealBRL) VALUES ('PIMCO', 87.3600);  -- Estimativa indexada ao câmbio comercial
INSERT INTO #PrecosReaisB3 (Ticker, PrecoRealBRL) VALUES ('NIO',   25.8000);  -- BDR NIOC34 na B3
INSERT INTO #PrecosReaisB3 (Ticker, PrecoRealBRL) VALUES ('T',     127.8500); -- BDR ATTB34 na B3
INSERT INTO #PrecosReaisB3 (Ticker, PrecoRealBRL) VALUES ('CLARO', 147.9000); -- Equivalente América Móvil na B3
INSERT INTO #PrecosReaisB3 (Ticker, PrecoRealBRL) VALUES ('VZ',    246.3500); -- BDR VERZ34 na B3

-- 2. Execução do UPDATE na base de dados
UPDATE hm
SET hm.PrecoFechamento = tmp.PrecoRealBRL
FROM HistoricoMercado hm
INNER JOIN Emissores_Telecom e ON hm.EmissorID = e.EmissorID
INNER JOIN #PrecosReaisB3 tmp ON e.CodigoTicker = tmp.Ticker
WHERE hm.DataRegistro = '20260723';

DROP TABLE #PrecosReaisB3;

COMMIT TRANSACTION;
GO

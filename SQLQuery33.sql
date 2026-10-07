USE CorporateFinance_DW;
GO

------------------------------------------------------------------------
-- 1. ADICIONANDO STANDARD CHARTERED À DIMENSÃO DE INSTITUIÇÕES
------------------------------------------------------------------------
-- Remove restrições de chaves se necessário para reinserção limpa de dados de teste
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.DimInstituicaoFinanceira') AND last_value IS NOT NULL)
BEGIN
    TRUNCATE TABLE dbo.DimInstituicaoFinanceira;
END

-- Inserção do Consórcio Bancário Completo incluindo o Standard Chartered Bank
INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('JPMORGAN', 'JPMorgan Chase & Co.', 'Investment Banking / Commercial', 4200000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('BOFA', 'Bank of America Corporation', 'Investment Banking (Global)', 3200000000000.0000);

-- NOVO INTEGRANTE DO CONSÓRCIO: Standard Chartered Bank (Apoio Estratégico Horizons)
INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('STAN_CHART', 'Standard Chartered Bank plc', 'Global Banking / Emerging Markets', 820000000000.0000); -- ~ $0.82 Trilhão em Ativos

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('SANTANDER', 'Banco Santander Group', 'Comercial (Global)', 1950000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('WELLS_FARGO', 'Wells Fargo & Company', 'Comercial (Global)', 1900000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('SOC_GEN', 'Societe Generale', 'Comercial (Internacional)', 1600000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('MORGAN_STANLEY', 'Morgan Stanley', 'Investment Banking (Global)', 1200000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('ABN_AMRO', 'ABN AMRO Bank N.V.', 'Comercial (Internacional)', 430000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('BB', 'Banco do Brasil S.A.', 'Comercial (Estatal)', 410000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('BACEN', 'Banco Central do Brasil', 'Regulador / Reservas Internacionais', 355000000000.0000);

INSERT INTO dbo.DimInstituicaoFinanceira (CodigoBanco, NomeInstituicao, TipoClassificacao, AtivosValuacaoUSD) 
VALUES ('BNDES', 'Banco Nacional de Desenvolvimento Economico e Social', 'Desenvolvimento', 130000000000.0000);
GO

------------------------------------------------------------------------
-- 2. CRIAÇÃO DA TABELA DE CAPTURA DE TELEMETRIA DE TÍTULOS (MARKET CHECK)
------------------------------------------------------------------------
IF OBJECT_ID('dbo.FactMarketCheckBonds', 'U') IS NOT NULL DROP TABLE dbo.FactMarketCheckBonds;
CREATE TABLE dbo.FactMarketCheckBonds (
    BondCheckID INT IDENTITY(1,1) PRIMARY KEY,
    TickerContrato VARCHAR(20) NOT NULL,       -- e.g., 'TUZ6', 'FVZ6', 'TYZ6', 'USZ6'
    NomeIndicador VARCHAR(100) NOT NULL,      -- e.g., 'US 2Y BOND FUTURE', 'US 10Y BOND FUTURE'
    PrecoFechamento DECIMAL(18,4) NOT NULL,   -- Valor nominal do contrato
    VariacaoAbsoluta DECIMAL(18,4) NOT NULL,  -- Mudança de ticks na sessão
    VariacaoPercentual DECIMAL(5,4) NOT NULL, -- Variação percentual intraday
    EstrategistaAtribuido VARCHAR(100) NOT NULL
);
GO

-- Carga dos dados reais exibidos no painel Bloomberg Intraday (Eric Robertsen Horizons Analysis)
INSERT INTO dbo.FactMarketCheckBonds (TickerContrato, NomeIndicador, PrecoFechamento, VariacaoAbsoluta, VariacaoPercentual, EstrategistaAtribuido)
VALUES ('TUZ6', 'US 2Y BOND FUTURE', 101.8984, 0.0195, 0.0002, 'Eric Robertsen');

INSERT INTO dbo.FactMarketCheckBonds (TickerContrato, NomeIndicador, PrecoFechamento, VariacaoAbsoluta, VariacaoPercentual, EstrategistaAtribuido)
VALUES ('FVZ6', 'US 5Y BOND FUTURE', 104.2578, 0.0781, 0.0007, 'Eric Robertsen');

INSERT INTO dbo.FactMarketCheckBonds (TickerContrato, NomeIndicador, PrecoFechamento, VariacaoAbsoluta, VariacaoPercentual, EstrategistaAtribuido)
VALUES ('TYZ6', 'US 10Y BOND FUTURE', 106.0000, 0.1719, 0.0016, 'Eric Robertsen');

INSERT INTO dbo.FactMarketCheckBonds (TickerContrato, NomeIndicador, PrecoFechamento, VariacaoAbsoluta, VariacaoPercentual, EstrategistaAtribuido)
VALUES ('USZ6', 'US 20Y BOND FUTURE', 107.4375, 0.4063, 0.0038, 'Eric Robertsen');
GO

------------------------------------------------------------------------
-- 3. EXECUÇÃO DA CONSULTA UNIFICADA DO FLUXO DE DADOS (DATA FLOW SNAPSHOT)
------------------------------------------------------------------------
PRINT '========================================================================================================================================================';
PRINT '                                       BLOOMBERG SURVEILLANCE & HORIZONS: TELEMETRIA DE TÍTULOS SOBERANOS (US BOND FUTURES)                             ';
PRINT '========================================================================================================================================================';

-- Grid 1: Monitoramento de Curva de Juros e Contratos Futuros de Longo Prazo
SELECT 
    f.TickerContrato AS [Ticker Symbol],
    f.NomeIndicador AS [Benchmark Contract Asset],
    CAST(f.PrecoFechamento AS DECIMAL(10,4)) AS [Intraday Price],
    '+' + CAST(CAST(f.VariacaoAbsoluta AS DECIMAL(10,4)) AS VARCHAR(15)) AS [Net Change],
    CAST(CAST(f.VariacaoPercentual * 100.0 AS DECIMAL(10,2)) AS VARCHAR(10)) + '%' AS [Session %],
    f.EstrategistaAtribuido AS [Chief Strategist Analysis]
FROM dbo.FactMarketCheckBonds f;

PRINT '========================================================================================================================================================';
PRINT '                                       CONSELHO DE AUDITORIA MONETÁRIA GLOBAL: ADIÇÃO DO STANDARD CHARTERED RANKING                                     ';
PRINT '========================================================================================================================================================';

-- Grid 2: Ledger de Instituições Atualizado com o Novo Posição Trilionária/Bilionária
SELECT 
    b.InstituicaoID AS [ID],
    b.CodigoBanco AS [Sigla],
    b.NomeInstituicao AS [Nome da Entidade Financeira],
    CASE 
        WHEN b.AtivosValuacaoUSD >= 1000000000000.0000 
             THEN '$' + CAST(CAST(b.AtivosValuacaoUSD / 1000000000000.0000 AS DECIMAL(10,2)) AS VARCHAR(20)) + ' Trilhão(ões)'
        ELSE '$' + CAST(CAST(b.AtivosValuacaoUSD / 1000000000.0000 AS DECIMAL(10,2)) AS VARCHAR(20)) + ' Bilhão(ões)'
    END AS [Classe de Escala Macro (USD Assets)]
FROM dbo.DimInstituicaoFinanceira b
ORDER BY b.AtivosValuacaoUSD DESC;
GO

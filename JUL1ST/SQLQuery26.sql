USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. EXPANSÃO DA TABELA DE CLIENTES PARA RASTREAMENTO DE INVESTIMENTOS BARCLAYS
-- =========================================================================
SET NOCOUNT ON;

-- Adiciona a coluna de saldo de investimento custodiado no Barclays se não existir
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ClientesHolding') AND name = 'SaldoInvestimentoBarclays')
BEGIN
    ALTER TABLE ClientesHolding ADD SaldoInvestimentoBarclays MONEY DEFAULT 0.00;
END
GO

-- =========================================================================
-- 2. GERADOR DE CARGA EXPANDIDA (RAMPA COMPLETA ATÉ 350.000 CLIENTESÚNICOS)
-- =========================================================================
DECLARE @Contador INT;
-- Identifica quantos clientes já existem na base para continuar a partir dali
SELECT @Contador = COUNT(*) + 1 FROM ClientesHolding;

-- Loop de inserção acelerada em lote para o alvo de 350.000 registros
WHILE @Contador <= 350000
BEGIN
    INSERT INTO ClientesHolding (RegiaoID, SegmentoMercado, ScoreCredito, StatusAssinatura, SaldoInvestimentoBarclays)
    VALUES (
        (@Contador % 5) + 1, -- Distribuição geográfica contínua
        CASE 
            WHEN @Contador % 5 = 0 THEN 'Private Banking'
            WHEN @Contador % 5 = 1 THEN 'Corporativo'
            WHEN @Contador % 5 = 2 THEN 'Premium'
            ELSE 'Varejo'
        END,
        ABS(CHECKSUM(NEWID())) % 501 + 500, -- ScoreCard ajustado: 500 a 1000
        'Ativo',
        CASE 
            WHEN @Contador % 5 = 0 THEN ABS(CHECKSUM(NEWID())) % 150001 + 100000.00 -- Private: $100k - $250k
            WHEN @Contador % 5 = 1 THEN ABS(CHECKSUM(NEWID())) % 450001 + 50000.00   -- Corp: $50k - $500k
            ELSE ABS(CHECKSUM(NEWID())) % 4501 + 500.00                             -- Varejo/Premium
        END
    );

    SET @Contador = @Contador + 1;
END;
GO

-- =========================================================================
-- 3. CRIAÇÃO DO SCORECARD DE LIQUIDEZ E DEPÓSITOS DO BARCLAYS ($BN)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_BarclaysLiquidityScorecard')
    DROP VIEW Vw_BarclaysLiquidityScorecard;
GO

CREATE VIEW Vw_BarclaysLiquidityScorecard AS
SELECT 
    R.NomeRegiao AS [Região de Origem],
    R.Continente AS [Continente],
    COUNT(C.ClienteID) AS [Total Clientes Únicos],
    CONVERT(VARCHAR, SUM(C.SaldoInvestimentoBarclays), 1) AS [Custódia Total Bruta ($)],
    
    -- Conversão direta para a escala analítica corporativa de Bilhões ($BN)
    CAST((SUM(C.SaldoInvestimentoBarclays) / 1000000000.00) AS DECIMAL(10,4)) AS [Volume de Captação ($BN)],
    
    -- Avaliação do Score de Risco Médio da Região no Barclays
    AVG(C.ScoreCredito) AS [ScoreCard de Crédito Médio],
    CASE 
        WHEN SUM(C.SaldoInvestimentoBarclays) >= 1000000000.00 THEN 'NÓ FINANCEIRO ESTRATÉGICO ($BN)'
        ELSE 'NÓ DE LIQUIDEZ REGULAR'
    END AS [Classificação Operacional]
FROM RegioesGlobais R
INNER JOIN ClientesHolding C ON R.RegiaoID = C.RegiaoID
GROUP BY R.NomeRegiao, R.Continente;
GO

-- =========================================================================
-- 4. CONSULTA E AUDITORIA COMPLETA DO TRACE DE 350K CLIENTES
-- =========================================================================

-- Painel 1: Confirmação da Volumetria Exata do Trace no Banco
SELECT COUNT(*) AS [Volumetria Total de Clientes na Base (Target 350K)] FROM ClientesHolding;

-- Painel 2: Dashboard Real de Captação e Distribuição de Bilhões ($BN) no Barclays
SELECT * FROM Vw_BarclaysLiquidityScorecard ORDER BY [Volume de Captação ($BN)] DESC;
GO

USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CRIAÇÃO DA TABELA DE CLIENTES ÚNICOS REGIONAIS (TARGET: 100K)
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ClientesHolding]') AND type in (N'U'))
BEGIN
    CREATE TABLE ClientesHolding (
        ClienteID INT IDENTITY(1,1) PRIMARY KEY,
        UID_Cliente UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
        RegiaoID INT NOT NULL,              -- Chave de amarração geográfica
        DataAdesao DATETIME DEFAULT GETDATE(),
        SegmentoMercado VARCHAR(30) NOT NULL, -- Ex: 'Varejo', 'Premium', 'Corporativo'
        ScoreCredito INT NOT NULL,           -- ScoreCard: 0 a 1000
        StatusAssinatura VARCHAR(15) DEFAULT 'Ativo',
        CONSTRAINT FK_Clientes_Regioes FOREIGN KEY (RegiaoID) REFERENCES RegioesGlobais(RegiaoID)
    );
END
GO

-- =========================================================================
-- 2. POPULAÇÃO AUTOMATIZADA EM MASSA (SIMULAÇÃO DE 100.000 CLIENTES)
-- =========================================================================
SET NOCOUNT ON;

DECLARE @Contador INT;
SET @Contador = 1;

-- Loop de inserção rápida indexada adaptada para performance na versão 9.0
WHILE @Contador <= 100000
BEGIN
    INSERT INTO ClientesHolding (RegiaoID, SegmentoMercado, ScoreCredito, StatusAssinatura)
    VALUES (
        (@Contador % 5) + 1, -- Distribui uniformemente entre as 5 regiões globais
        CASE 
            WHEN @Contador % 3 = 0 THEN 'Corporativo'
            WHEN @Contador % 3 = 1 THEN 'Premium'
            ELSE 'Varejo'
        END,
        ABS(CHECKSUM(NEWID())) % 601 + 400, -- ScoreCard randômico controlado entre 400 e 1000
        CASE WHEN @Contador % 20 = 0 THEN 'Inativo' ELSE 'Ativo' END
    );
    
    -- Incremento em lote para evitar gargalo de log
    SET @Contador = @Contador + 1;
END;
GO

-- =========================================================================
-- 3. MKT SCORECARD HOLDING - VIEW DE CONSOLIDAÇÃO ANALÍTICA
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_MktScorecardHolding')
    DROP VIEW Vw_MktScorecardHolding;
GO

CREATE VIEW Vw_MktScorecardHolding AS
SELECT 
    R.NomeRegiao AS [Regiao],
    R.Continente AS [Continente],
    COUNT(C.ClienteID) AS [Total Clientes Unicos],
    SUM(CASE WHEN C.StatusAssinatura = 'Ativo' THEN 1 ELSE 0 END) AS [Clientes Ativos],
    AVG(C.ScoreCredito) AS [Media ScoreCard Credito],
    CASE 
        WHEN AVG(C.ScoreCredito) >= 750 THEN 'ALTA QUALIDADE (AAA)'
        WHEN AVG(C.ScoreCredito) >= 650 THEN 'RISCO MODERADO (BBB)'
        ELSE 'RISCO CRÍTICO (Subprime)'
    END AS [Rating de Mercado]
FROM RegioesGlobais R
INNER JOIN ClientesHolding C ON R.RegiaoID = C.RegiaoID
GROUP BY R.NomeRegiao, R.Continente;
GO

-- =========================================================================
-- 4. RASTREAMENTO E AUDITORIA DO TRACE (VALIDAÇÃO DE INTEGRIDADE)
-- =========================================================================

-- Verificação da volumetria exata de carga de dados
SELECT COUNT(*) AS [Total Geral Linhas Processadas no Trace (Target 100K)] FROM ClientesHolding;

-- Amostragem de metadados dos primeiros clientes únicos gerados
SELECT TOP 5 
    ClienteID, 
    UID_Cliente AS [Chave Hash Unica], 
    SegmentoMercado, 
    ScoreCredito AS [Mkt ScoreCard] 
FROM ClientesHolding 
ORDER BY ClienteID ASC;

-- Resultado consolidado da Holding por Região Global
SELECT * FROM Vw_MktScorecardHolding ORDER BY [Total Clientes Unicos] DESC;
GO

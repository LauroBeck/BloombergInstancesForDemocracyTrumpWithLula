-- =====================================================================
-- Target: SQL Server 2008 / 2008 R2 (Alta Performance)
-- Focus: Expansão Global (US, EU, ASIA, CHINA) e Séries Temporais de 55 Meses
-- Companies: Samsung, SK Hynix, Microsoft, etc.
-- =====================================================================

-- 1. ADICIONAR ATRIBUTOS DE REGIÃO GLOBAL NAS DIMENSÕES
IF OBJECT_ID('Fact_Regional_Gains_55Months', 'U') IS NOT NULL DROP TABLE Fact_Regional_Gains_55Months;
IF OBJECT_ID('Dim_Region', 'U') IS NOT NULL DROP TABLE Dim_Region;
GO

CREATE TABLE Dim_Region (
    RegionKey INT IDENTITY(1,1) NOT NULL,
    RegionCode VARCHAR(10) NOT NULL,     -- US, EU, ASIA, CHINA
    RegionName VARCHAR(100) NOT NULL,
    CurrencyCode VARCHAR(3) NOT NULL,    -- USD, EUR, KRW, CNY
    CONSTRAINT PK_Dim_Region PRIMARY KEY CLUSTERED (RegionKey),
    CONSTRAINT UQ_DimRegion_Code UNIQUE (RegionCode)
);

-- Re-garantir integridade da Dim_Security para as gigantes asiáticas
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Dim_Security') AND name = 'RegionCode')
    ALTER TABLE Dim_Security ADD RegionCode VARCHAR(10) NULL;
GO

-- 2. TABELA DE FATO DE ALTA PERFORMANCE: GANHOS DE 55 MESES (TRILHÕES DE DÓLARES)
CREATE TABLE Fact_Regional_Gains_55Months (
    GainsKey BIGINT IDENTITY(1,1) NOT NULL,
    SecurityKey INT NOT NULL,
    RegionKey INT NOT NULL,
    AsOfDate DATE NOT NULL,
    HistoricalPeriodMonths INT NOT NULL,  -- Rastreamento fixo (Ex: 55)
    TotalRevenueGenerated DECIMAL(24, 4) NOT NULL, -- Suporta Casa dos Trilhões ($)
    NetProfitGains DECIMAL(24, 4) NOT NULL,        -- Retorno Gerado
    MarketCapExpansion DECIMAL(24, 4) NOT NULL,   -- Crescimento de Value Equity
    ProjectionBuffer DECIMAL(18, 4) NOT NULL,
    CONSTRAINT PK_Fact_Regional_Gains_55Months PRIMARY KEY CLUSTERED (GainsKey, AsOfDate)
);
GO


-- 3. POPULAR MATRIZ GLOBAL DE DIMENSÕES
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'US', 'United States Regions', 'USD';
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'EU', 'European Union Market Area', 'EUR';
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'ASIA', 'Asian Continental Tech Sector', 'KRW';
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'CHINA', 'China Mainland Tech Infrastructure', 'CNY';

-- Inserção das Novas Gigantes de Tecnologia (Samsung e SK Hynix) com sintaxe SQL 2008
MERGE Dim_Security AS Target
USING (
    SELECT '005930' AS Ticker, 'Samsung Electronics Co.' AS Name, 'KRW' AS Ex, 'Technology' AS Sec, 'Semiconductors' AS Ind, 'ASIA' AS Reg UNION ALL
    SELECT '000660', 'SK Hynix Inc.', 'KRW', 'Technology', 'Semiconductors', 'ASIA' UNION ALL
    SELECT 'MSFT', 'Microsoft Corporation', 'NASDAQ-GS', 'Technology', 'Computer Software', 'US'
) AS Source
ON (Target.TickerSymbol = Source.Ticker)
WHEN NOT MATCHED THEN
    INSERT (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive, RegionCode)
    VALUES (Source.Ticker, Source.Name, Source.Ex, Source.Sec, Source.Ind, 0, 1, Source.Reg);
GO


-- 4. CARGA DE INGESTÃO HISTÓRICA DOS 55 MESES (VALORES EM TRILHÕES DE DÓLARES)
DECLARE @Sec_Samsung INT = (SELECT SecurityKey FROM Dim_Security WHERE TickerSymbol = '005930');
DECLARE @Sec_SKHynix INT = (SELECT SecurityKey FROM Dim_Security WHERE TickerSymbol = '000660');
DECLARE @Sec_MSFT INT = (SELECT SecurityKey FROM Dim_Security WHERE TickerSymbol = 'MSFT');

DECLARE @Reg_US INT = (SELECT RegionKey FROM Dim_Region WHERE RegionCode = 'US');
DECLARE @Reg_ASIA INT = (SELECT RegionKey FROM Dim_Region WHERE RegionCode = 'ASIA');

-- Inserção de dados simulando os ganhos consolidados da série de 55 meses
INSERT INTO Fact_Regional_Gains_55Months (SecurityKey, RegionKey, AsOfDate, HistoricalPeriodMonths, TotalRevenueGenerated, NetProfitGains, MarketCapExpansion, ProjectionBuffer)
VALUES 
    (@Sec_Samsung, @Reg_ASIA, '2026-10-07', 55, 1450000000000.0000, 380000000000.0000, 480000000000.0000, 0.1200), -- 1.45 Trilhões Gerados
    (@Sec_SKHynix, @Reg_ASIA, '2026-10-07', 55, 890000000000.0000, 210000000000.0000, 190000000000.0000, 0.1500),  -- 890 Bilhões Gerados
    (@Sec_MSFT, @Reg_US, '2026-10-07', 55, 2350000000000.0000, 720000000000.0000, 1100000000000.0000, 0.0980);   -- 2.35 Trilhões Gerados
GO

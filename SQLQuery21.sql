-- =====================================================================
-- Target: SQL Server 2005 / 2008 Engine (Foco em Compatibilidade)
-- Fixes: Substituído DATE por DATETIME, MERGE por IF NOT EXISTS e removido declarações inline
-- Multi-Regiões: US, EU, ASIA, CHINA (Microsoft, Samsung, SK Hynix)
-- =====================================================================

-- 1. ESTRUTURA DE TABELAS COMPATÍVEIS
IF OBJECT_ID('Fact_Regional_Gains_55Months', 'U') IS NOT NULL DROP TABLE Fact_Regional_Gains_55Months;
IF OBJECT_ID('Dim_Region', 'U') IS NOT NULL DROP TABLE Dim_Region;
GO

CREATE TABLE Dim_Region (
    RegionKey INT IDENTITY(1,1) NOT NULL,
    RegionCode VARCHAR(10) NOT NULL,     
    RegionName VARCHAR(100) NOT NULL,
    CurrencyCode VARCHAR(3) NOT NULL,    
    CONSTRAINT PK_Dim_Region PRIMARY KEY CLUSTERED (RegionKey),
    CONSTRAINT UQ_DimRegion_Code UNIQUE (RegionCode)
);
GO

-- Garante coluna de Região na Dim_Security de forma segura
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Dim_Security') AND name = 'RegionCode')
BEGIN
    ALTER TABLE Dim_Security ADD RegionCode VARCHAR(10) NULL;
END;
GO

CREATE TABLE Fact_Regional_Gains_55Months (
    GainsKey BIGINT IDENTITY(1,1) NOT NULL,
    SecurityKey INT NOT NULL,
    RegionKey INT NOT NULL,
    AsOfDate DATETIME NOT NULL,           -- Corrigido de DATE para DATETIME para rodar no SQL 2005
    HistoricalPeriodMonths INT NOT NULL,  
    TotalRevenueGenerated DECIMAL(24, 4) NOT NULL, 
    NetProfitGains DECIMAL(24, 4) NOT NULL,        
    MarketCapExpansion DECIMAL(24, 4) NOT NULL,   
    ProjectionBuffer DECIMAL(18, 4) NOT NULL,
    CONSTRAINT PK_Fact_Regional_Gains_55Months PRIMARY KEY CLUSTERED (GainsKey, AsOfDate)
);
GO

-- 2. POPULAR DIMENSÕES DE REGIÃO
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'US', 'United States Regions', 'USD';
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'EU', 'European Union Market Area', 'EUR';
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'ASIA', 'Asian Continental Tech Sector', 'KRW';
INSERT INTO Dim_Region (RegionCode, RegionName, CurrencyCode) SELECT 'CHINA', 'China Mainland Tech Infrastructure', 'CNY';
GO

-- 3. INSERÇÃO DAS GIGANTES ASIÁTICAS SEM USAR A SINTAXE MERGE
IF NOT EXISTS (SELECT 1 FROM Dim_Security WHERE TickerSymbol = '005930')
    INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive, RegionCode)
    VALUES ('005930', 'Samsung Electronics Co.', 'KRW', 'Technology', 'Semiconductors', 0, 1, 'ASIA');

IF NOT EXISTS (SELECT 1 FROM Dim_Security WHERE TickerSymbol = '000660')
    INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive, RegionCode)
    VALUES ('000660', 'SK Hynix Inc.', 'KRW', 'Technology', 'Semiconductors', 0, 1, 'ASIA');

IF NOT EXISTS (SELECT 1 FROM Dim_Security WHERE TickerSymbol = 'MSFT')
    INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive, RegionCode)
    VALUES ('MSFT', 'Microsoft Corporation', 'NASDAQ-GS', 'Technology', 'Computer Software', 1, 1, 'US');
GO

-- 4. INGESTÃO DOS FATOS DE GANHOS DOS 55 MESES (TRILHÕES DE DÓLARES)
-- Separação estrita de DECLARE e SET para compatibilidade com o motor antigo
DECLARE @Sec_Samsung INT;
DECLARE @Sec_SKHynix INT;
DECLARE @Sec_MSFT INT;
DECLARE @Reg_US INT;
DECLARE @Reg_ASIA INT;

SELECT @Sec_Samsung = SecurityKey FROM Dim_Security WHERE TickerSymbol = '005930';
SELECT @Sec_SKHynix = SecurityKey FROM Dim_Security WHERE TickerSymbol = '000660';
SELECT @Sec_MSFT = SecurityKey FROM Dim_Security WHERE TickerSymbol = 'MSFT';
SELECT @Reg_US = RegionKey FROM Dim_Region WHERE RegionCode = 'US';
SELECT @Reg_ASIA = RegionKey FROM Dim_Region WHERE RegionCode = 'ASIA';

INSERT INTO Fact_Regional_Gains_55Months (SecurityKey, RegionKey, AsOfDate, HistoricalPeriodMonths, TotalRevenueGenerated, NetProfitGains, MarketCapExpansion, ProjectionBuffer)
SELECT @Sec_Samsung, @Reg_ASIA, CAST('2026-10-07' AS DATETIME), 55, 1450000000000.0000, 380000000000.0000, 480000000000.0000, 0.1200 UNION ALL
SELECT @Sec_SKHynix, @Reg_ASIA, CAST('2026-10-07' AS DATETIME), 55, 890000000000.0000, 210000000000.0000, 190000000000.0000, 0.1500 UNION ALL
SELECT @Sec_MSFT, @Reg_US, CAST('2026-10-07' AS DATETIME), 55, 2350000000000.0000, 720000000000.0000, 1100000000000.0000, 0.0980;
GO

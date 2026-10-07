-- =====================================================================
-- Target: SQL Server 2005 (9.0) / 2008 Compatibility Architecture
-- Fixes: Inline variable declarations, multi-row inserts, subqueries
-- Integration: Bloomberg DB Context Mapping
-- =====================================================================

-- 1. SCHEMA DEFINITION
IF OBJECT_ID('Fact_ETF_Holdings_Weight', 'U') IS NOT NULL DROP TABLE Fact_ETF_Holdings_Weight;
IF OBJECT_ID('Fact_Market_Key_Data', 'U') IS NOT NULL DROP TABLE Fact_Market_Key_Data;
IF OBJECT_ID('Fact_Stock_Quote_Snapshot', 'U') IS NOT NULL DROP TABLE Fact_Stock_Quote_Snapshot;
IF OBJECT_ID('Dim_ETF', 'U') IS NOT NULL DROP TABLE Dim_ETF;
IF OBJECT_ID('Dim_Security', 'U') IS NOT NULL DROP TABLE Dim_Security;
GO

CREATE TABLE Dim_Security (
    SecurityKey INT IDENTITY(1,1) NOT NULL,
    TickerSymbol VARCHAR(10) NOT NULL,
    CompanyName VARCHAR(150) NOT NULL,
    ExchangeName VARCHAR(50) NOT NULL,
    SectorName VARCHAR(100) NOT NULL,
    IndustryName VARCHAR(150) NOT NULL,
    IsNasdaq100 BIT DEFAULT (0),
    IsActive BIT DEFAULT (1),
    CONSTRAINT PK_Dim_Security PRIMARY KEY CLUSTERED (SecurityKey),
    CONSTRAINT UQ_DimSecurity_Ticker UNIQUE (TickerSymbol)
);

CREATE TABLE Dim_ETF (
    ETFKey INT IDENTITY(1,1) NOT NULL,
    ETFTicker VARCHAR(10) NOT NULL,
    ETFName VARCHAR(150) NOT NULL,
    IssuerName VARCHAR(100) NULL,
    CONSTRAINT PK_Dim_ETF PRIMARY KEY CLUSTERED (ETFKey),
    CONSTRAINT UQ_DimETF_Ticker UNIQUE (ETFTicker)
);

CREATE TABLE Fact_Stock_Quote_Snapshot (
    SnapshotKey BIGINT IDENTITY(1,1) NOT NULL,
    SecurityKey INT NOT NULL,
    SnapshotDateTime DATETIME NOT NULL, 
    LastPrice DECIMAL(18, 4) NOT NULL,
    PriceChange DECIMAL(18, 4) NOT NULL,
    PercentageChange DECIMAL(6, 4) NOT NULL,
    BidPrice DECIMAL(18, 4) NOT NULL,
    BidSize INT NOT NULL,
    AskPrice DECIMAL(18, 4) NOT NULL,
    AskSize INT NOT NULL,
    TotalShareVolume DECIMAL(24, 6) NOT NULL,
    CONSTRAINT PK_Fact_Stock_Quote_Snapshot PRIMARY KEY CLUSTERED (SnapshotKey, SnapshotDateTime)
);

CREATE TABLE Fact_Market_Key_Data (
    KeyDataKey INT IDENTITY(1,1) NOT NULL,
    SecurityKey INT NOT NULL,
    AsOfDate DATETIME NOT NULL, -- Changed from DATE to DATETIME for standard 2005 support
    PreviousClose DECIMAL(18, 4) NOT NULL,
    TodayHigh DECIMAL(18, 4) NOT NULL,
    TodayLow DECIMAL(18, 4) NOT NULL,
    FiftyTwoWeekHigh DECIMAL(18, 4) NOT NULL,
    FiftyTwoWeekLow DECIMAL(18, 4) NOT NULL,
    MarketCap DECIMAL(20, 2) NOT NULL,     
    AnnualizedDividend DECIMAL(10, 4) NOT NULL,
    CurrentYield DECIMAL(5, 4) NOT NULL,    
    ExDividendDate DATETIME NULL,
    DividendPayDate DATETIME NULL,
    OneYearTargetPrice DECIMAL(18, 4) NOT NULL,
    AverageVolume INT NOT NULL,
    CONSTRAINT PK_Fact_Market_Key_Data PRIMARY KEY CLUSTERED (KeyDataKey)
);

CREATE TABLE Fact_ETF_Holdings_Weight (
    HoldingKey INT IDENTITY(1,1) NOT NULL,
    ETFKey INT NOT NULL,
    SecurityKey INT NOT NULL,
    AsOfDate DATETIME NOT NULL, 
    PercentWeighting DECIMAL(5, 4) NOT NULL, 
    HoldingRank INT NOT NULL,
    CONSTRAINT PK_Fact_ETF_Holdings_Weight PRIMARY KEY CLUSTERED (HoldingKey)
);
GO

-- 2. INDEX OPTIMIZATION
CREATE NONCLUSTERED INDEX IX_FactSnapshot_Security_DateTime 
ON Fact_Stock_Quote_Snapshot (SecurityKey, SnapshotDateTime) 
INCLUDE (LastPrice, TotalShareVolume);

CREATE NONCLUSTERED INDEX IX_FactETF_ETF_Security 
ON Fact_ETF_Holdings_Weight (ETFKey, SecurityKey) 
INCLUDE (PercentWeighting);
GO

-- Foreign Keys
ALTER TABLE Fact_Stock_Quote_Snapshot ADD CONSTRAINT FK_FactSnapshot_DimSecurity FOREIGN KEY (SecurityKey) REFERENCES Dim_Security (SecurityKey);
ALTER TABLE Fact_Market_Key_Data ADD CONSTRAINT FK_FactKeyData_DimSecurity FOREIGN KEY (SecurityKey) REFERENCES Dim_Security (SecurityKey);
ALTER TABLE Fact_ETF_Holdings_Weight ADD CONSTRAINT FK_FactETF_DimETF FOREIGN KEY (ETFKey) REFERENCES Dim_ETF (ETFKey);
ALTER TABLE Fact_ETF_Holdings_Weight ADD CONSTRAINT FK_FactETF_DimSecurity FOREIGN KEY (SecurityKey) REFERENCES Dim_Security (SecurityKey);
GO


-- 3. SYNTAX-COMPLIANT SEED DATA INSERTS
INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100)
VALUES ('MSFT', 'Microsoft Corporation Common Stock', 'NASDAQ-GS', 'Technology', 'Computer Software: Prepackaged Software', 1);

-- Correct multi-statement variable parsing for SQL 2005
DECLARE @MSFT_ID INT;
SET @MSFT_ID = SCOPE_IDENTITY();

-- Corrected compatible multi-row seed framework
INSERT INTO Dim_ETF (ETFTicker, ETFName) SELECT 'MSFU', 'Direxion Daily MSFT Bull 2X ETF';
INSERT INTO Dim_ETF (ETFTicker, ETFName) SELECT 'SUSL', 'iShares ESG MSCI USA Leaders ETF';
INSERT INTO Dim_ETF (ETFTicker, ETFName) SELECT 'IUSG', 'iShares Core S&P U.S. Growth ETF';
INSERT INTO Dim_ETF (ETFTicker, ETFName) SELECT 'GFGF', 'Guru Favorite Stocks ETF';
INSERT INTO Dim_ETF (ETFTicker, ETFName) SELECT 'TDIV', 'First Trust NASDAQ Technology Dividend Index Fund';

-- Snapshot Seed
INSERT INTO Fact_Stock_Quote_Snapshot (SecurityKey, SnapshotDateTime, LastPrice, PriceChange, PercentageChange, BidPrice, BidSize, AskPrice, AskSize, TotalShareVolume)
VALUES (@MSFT_ID, '2026-10-07 09:52:00', 527.1500, -2.1500, -0.0041, 527.0400, 87, 527.1500, 167, 1871927.434443);

-- Key Data Seed
INSERT INTO Fact_Market_Key_Data (SecurityKey, AsOfDate, PreviousClose, TodayHigh, TodayLow, FiftyTwoWeekHigh, FiftyTwoWeekLow, MarketCap, AnnualizedDividend, CurrentYield, ExDividendDate, DividendPayDate, OneYearTargetPrice, AverageVolume)
VALUES (@MSFT_ID, '2026-10-07', 529.3000, 531.5900, 525.6830, 553.7200, 349.2000, 3913448112394.00, 3.6400, 0.0069, '2026-08-20', '2026-09-10', 575.0000, 27337999);

-- ETF Holdings Weight Seed (Resolved via local scalar parameters)
DECLARE @ETF_MSFU INT, @ETF_SUSL INT, @ETF_IUSG INT, @ETF_GFGF INT, @ETF_TDIV INT;
SELECT @ETF_MSFU = ETFKey FROM Dim_ETF WHERE ETFTicker='MSFU';
SELECT @ETF_SUSL = ETFKey FROM Dim_ETF WHERE ETFTicker='SUSL';
SELECT @ETF_IUSG = ETFKey FROM Dim_ETF WHERE ETFTicker='IUSG';
SELECT @ETF_GFGF = ETFKey FROM Dim_ETF WHERE ETFTicker='GFGF';
SELECT @ETF_TDIV = ETFKey FROM Dim_ETF WHERE ETFTicker='TDIV';

INSERT INTO Fact_ETF_Holdings_Weight (ETFKey, SecurityKey, AsOfDate, PercentWeighting, HoldingRank) VALUES (@ETF_MSFU, @MSFT_ID, '2026-10-07', 0.1958, 1);
INSERT INTO Fact_ETF_Holdings_Weight (ETFKey, SecurityKey, AsOfDate, PercentWeighting, HoldingRank) VALUES (@ETF_SUSL, @MSFT_ID, '2026-10-07', 0.1052, 2);
INSERT INTO Fact_ETF_Holdings_Weight (ETFKey, SecurityKey, AsOfDate, PercentWeighting, HoldingRank) VALUES (@ETF_IUSG, @MSFT_ID, '2026-10-07', 0.0988, 3);
INSERT INTO Fact_ETF_Holdings_Weight (ETFKey, SecurityKey, AsOfDate, PercentWeighting, HoldingRank) VALUES (@ETF_GFGF, @MSFT_ID, '2026-10-07', 0.0918, 4);
INSERT INTO Fact_ETF_Holdings_Weight (ETFKey, SecurityKey, AsOfDate, PercentWeighting, HoldingRank) VALUES (@ETF_TDIV, @MSFT_ID, '2026-10-07', 0.0823, 5);
GO

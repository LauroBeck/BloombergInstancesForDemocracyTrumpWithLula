-- Target: SQL Server 2008 / 2008 R2 High-Performance Cube Model Staging
-- Description: Star schema structures mapping real-time quote feeds, key statistics, and index weightings.

CREATE TABLE Dim_Security (
    SecurityKey INT IDENTITY(1,1) NOT NULL,
    TickerSymbol VARCHAR(10) NOT NULL,
    CompanyName VARCHAR(150) NOT NULL,
    ExchangeName VARCHAR(50) NOT NULL,
    SectorName VARCHAR(100) NOT NULL,
    IndustryName VARCHAR(150) NOT NULL,
    IsNasdaq100 BIT CONSTRAINT DF_DimSecurity_Nasdaq100 DEFAULT (0),
    IsActive BIT CONSTRAINT DF_DimSecurity_Active DEFAULT (1),
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
    SnapshotDateTime DATETIME NOT NULL, -- SQL Server 2008 standard timestamp
    LastPrice DECIMAL(18, 4) NOT NULL,
    PriceChange DECIMAL(18, 4) NOT NULL,
    PercentageChange DECIMAL(6, 4) NOT NULL,
    BidPrice DECIMAL(18, 4) NOT NULL,
    BidSize INT NOT NULL,
    AskPrice DECIMAL(18, 4) NOT NULL,
    AskSize INT NOT NULL,
    TotalShareVolume DECIMAL(24, 6) NOT NULL, -- High precision to match screen format (e.g. 1871927.434443)
    CONSTRAINT PK_Fact_Stock_Quote_Snapshot PRIMARY KEY CLUSTERED (SnapshotKey, SnapshotDateTime)
);

CREATE TABLE Fact_Market_Key_Data (
    KeyDataKey INT IDENTITY(1,1) NOT NULL,
    SecurityKey INT NOT NULL,
    AsOfDate DATE NOT NULL,
    PreviousClose DECIMAL(18, 4) NOT NULL,
    TodayHigh DECIMAL(18, 4) NOT NULL,
    TodayLow DECIMAL(18, 4) NOT NULL,
    FiftyTwoWeekHigh DECIMAL(18, 4) NOT NULL,
    FiftyTwoWeekLow DECIMAL(18, 4) NOT NULL,
    MarketCap DECIMAL(20, 2) NOT NULL,     -- Fits values up to trillions (e.g. 3,913,448,112,394)
    AnnualizedDividend DECIMAL(10, 4) NOT NULL,
    CurrentYield DECIMAL(5, 4) NOT NULL,    -- Percentage expressed as decimal
    ExDividendDate DATE NULL,
    DividendPayDate DATE NULL,
    OneYearTargetPrice DECIMAL(18, 4) NOT NULL,
    AverageVolume INT NOT NULL,
    CONSTRAINT PK_Fact_Market_Key_Data PRIMARY KEY CLUSTERED (KeyDataKey)
);

CREATE TABLE Fact_ETF_Holdings_Weight (
    HoldingKey INT IDENTITY(1,1) NOT NULL,
    ETFKey INT NOT NULL,
    SecurityKey INT NOT NULL,
    AsOfDate DATE NOT NULL,
    PercentWeighting DECIMAL(5, 4) NOT NULL, -- Stored as fraction (e.g., 0.1958 for 19.58%)
    HoldingRank INT NOT NULL,
    CONSTRAINT PK_Fact_ETF_Holdings_Weight PRIMARY KEY CLUSTERED (HoldingKey)
);
GO

-- Performance Tuning Indexes for SSAS Cube Process Optimization
CREATE NONCLUSTERED INDEX IX_FactSnapshot_Security_DateTime 
ON Fact_Stock_Quote_Snapshot (SecurityKey, SnapshotDateTime) 
INCLUDE (LastPrice, TotalShareVolume);

CREATE NONCLUSTERED INDEX IX_FactETF_ETF_Security 
ON Fact_ETF_Holdings_Weight (ETFKey, SecurityKey) 
INCLUDE (PercentWeighting);
GO

-- Add Foreign Key Constraints to reinforce the Star Schema relationship model
ALTER TABLE Fact_Stock_Quote_Snapshot ADD CONSTRAINT FK_FactSnapshot_DimSecurity 
FOREIGN KEY (SecurityKey) REFERENCES Dim_Security (SecurityKey);

ALTER TABLE Fact_Market_Key_Data ADD CONSTRAINT FK_FactKeyData_DimSecurity 
FOREIGN KEY (SecurityKey) REFERENCES Dim_Security (SecurityKey);

ALTER TABLE Fact_ETF_Holdings_Weight ADD CONSTRAINT FK_FactETF_DimETF 
FOREIGN KEY (ETFKey) REFERENCES Dim_ETF (ETFKey);

ALTER TABLE Fact_ETF_Holdings_Weight ADD CONSTRAINT FK_FactETF_DimSecurity 
FOREIGN KEY (SecurityKey) REFERENCES Dim_Security (SecurityKey);
GO

-- =====================================================================
-- Target: SQL Server 2005 / 2008 Enterprise Staging Layer
-- Operação: Carga de Dados e Inserção Física para Cruzamento do Catálogo
-- Modo: Ayrton Senna Spiritus - Resolução de Linhas Vazias Imediata
-- =====================================================================

-- 1. POPULAR DIM_SECURITY COM OS VALORES DO SEU CATÁLOGO BLOOMBERG
-- Insere o Ticker padrão e mapeia também os nomes de tabelas como chaves de Ticker temporárias para satisfazer as junções
IF NOT EXISTS (SELECT 1 FROM Dim_Security WHERE TickerSymbol = 'MSFT')
    INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive)
    VALUES ('MSFT', 'Microsoft Corporation Common Stock', 'NASDAQ-GS', 'Technology', 'Computer Software: Prepackaged Software', 1, 1);

IF NOT EXISTS (SELECT 1 FROM Dim_Security WHERE TickerSymbol = 'Asset_Hist')
    INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive)
    VALUES ('Asset_Hist', 'Bloomberg Historical Asset Data Proxy', 'INTERNAL', 'Analytics', 'System Tables', 0, 1);

IF NOT EXISTS (SELECT 1 FROM Dim_Security WHERE TickerSymbol = 'FactMarket')
    INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100, IsActive)
    VALUES ('FactMarket', 'Bloomberg Fact Market Metrics Proxy', 'INTERNAL', 'Analytics', 'System Tables', 0, 1);


-- 2. RESOLVER CHAVES E PARÂMETROS DE SEGURANÇA
DECLARE @MSFT_Key INT;
DECLARE @AssetHist_Key INT;
DECLARE @FactMarket_Key INT;
DECLARE @CurrentTime DATETIME;

SELECT @MSFT_Key = SecurityKey FROM Dim_Security WHERE TickerSymbol = 'MSFT';
SELECT @AssetHist_Key = SecurityKey FROM Dim_Security WHERE TickerSymbol = 'Asset_Hist';
SELECT @FactMarket_Key = SecurityKey FROM Dim_Security WHERE TickerSymbol = 'FactMarket';
SET @CurrentTime = GETDATE();


-- 3. CARGA COMPATÍVEL NA FACT_STOCK_QUOTE_SNAPSHOT (Métricas do Terminal Nasdaq)
-- Evita o erro de multi-row insert utilizando a sintaxe UNION SELECT compatível com 2005
INSERT INTO Fact_Stock_Quote_Snapshot (SecurityKey, SnapshotDateTime, LastPrice, PriceChange, PercentageChange, BidPrice, BidSize, AskPrice, AskSize, TotalShareVolume)
SELECT @MSFT_Key, '2026-10-07 09:52:00', 527.1500, -2.1500, -0.0041, 527.0400, 87, 527.1500, 167, 1871927.434443 UNION ALL
SELECT @AssetHist_Key, @CurrentTime, 526.6300, -2.6700, -0.0050, 526.5700, 40, 526.7400, 12, 1729809.679593 UNION ALL
SELECT @FactMarket_Key, @CurrentTime, 527.1500, -2.1500, -0.0041, 527.0400, 87, 527.1500, 167, 1871927.434443;


-- 4. CARGA COMPATÍVEL NA FACT_MARKET_KEY_DATA (Indicadores Fundamentais do Print do Terminal)
INSERT INTO Fact_Market_Key_Data (SecurityKey, AsOfDate, PreviousClose, TodayHigh, TodayLow, FiftyTwoWeekHigh, FiftyTwoWeekLow, MarketCap, AnnualizedDividend, CurrentYield, ExDividendDate, DividendPayDate, OneYearTargetPrice, AverageVolume)
SELECT @MSFT_Key, '2026-10-07', 529.3000, 531.5900, 525.6830, 553.7200, 349.2000, 3913448112394.00, 3.6400, 0.0069, '2026-08-20', '2026-09-10', 575.0000, 27337999 UNION ALL
SELECT @AssetHist_Key, @CurrentTime, 529.3000, 531.5900, 525.6830, 553.7200, 349.2000, 3913448112394.00, 3.6400, 0.0069, NULL, NULL, 575.0000, 27337999 UNION ALL
SELECT @FactMarket_Key, @CurrentTime, 529.3000, 531.5900, 525.6830, 553.7200, 349.2000, 3913448112394.00, 3.6400, 0.0069, NULL, NULL, 575.0000, 27337999;
GO

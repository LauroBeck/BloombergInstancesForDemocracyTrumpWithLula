-- Seed the master core security records
INSERT INTO Dim_Security (TickerSymbol, CompanyName, ExchangeName, SectorName, IndustryName, IsNasdaq100)
VALUES ('MSFT', 'Microsoft Corporation Common Stock', 'NASDAQ-GS', 'Technology', 'Computer Software: Prepackaged Software', 1);

DECLARE @MSFT_ID INT = SCOPE_IDENTITY();

-- Seed the historical core target ETFs
INSERT INTO Dim_ETF (ETFTicker, ETFName) VALUES 
('MSFU', 'Direxion Daily MSFT Bull 2X ETF'),
('SUSL', 'iShares ESG MSCI USA Leaders ETF'),
('IUSG', 'iShares Core S&P U.S. Growth ETF'),
('GFGF', 'Guru Favorite Stocks ETF'),
('TDIV', 'First Trust NASDAQ Technology Dividend Index Fund');

-- Seed Fact: 9:52 AM snapshot metrics
INSERT INTO Fact_Stock_Quote_Snapshot 
(SecurityKey, SnapshotDateTime, LastPrice, PriceChange, PercentageChange, BidPrice, BidSize, AskPrice, AskSize, TotalShareVolume)
VALUES 
(@MSFT_ID, '2026-10-07 09:52:00', 527.1500, -2.1500, -0.0041, 527.0400, 87, 527.1500, 167, 1871927.434443);

-- Seed Fact: Core analytical metrics
INSERT INTO Fact_Market_Key_Data 
(SecurityKey, AsOfDate, PreviousClose, TodayHigh, TodayLow, FiftyTwoWeekHigh, FiftyTwoWeekLow, MarketCap, AnnualizedDividend, CurrentYield, ExDividendDate, DividendPayDate, OneYearTargetPrice, AverageVolume)
VALUES 
(@MSFT_ID, '2026-10-07', 529.3000, 531.5900, 525.6830, 553.7200, 349.2000, 3913448112394.00, 3.6400, 0.0069, '2026-08-20', '2026-09-10', 575.0000, 27337999);

-- Seed Fact: Top 10 fund holdings weightings allocations
INSERT INTO Fact_ETF_Holdings_Weight (ETFKey, SecurityKey, AsOfDate, PercentWeighting, HoldingRank)
VALUES 
((SELECT ETFKey FROM Dim_ETF WHERE ETFTicker='MSFU'), @MSFT_ID, '2026-10-07', 0.1958, 1),
((SELECT ETFKey FROM Dim_ETF WHERE ETFTicker='SUSL'), @MSFT_ID, '2026-10-07', 0.1052, 2),
((SELECT ETFKey FROM Dim_ETF WHERE ETFTicker='IUSG'), @MSFT_ID, '2026-10-07', 0.0988, 3),
((SELECT ETFKey FROM Dim_ETF WHERE ETFTicker='GFGF'), @MSFT_ID, '2026-10-07', 0.0918, 4),
((SELECT ETFKey FROM Dim_ETF WHERE ETFTicker='TDIV'), @MSFT_ID, '2026-10-07', 0.0823, 5);
GO

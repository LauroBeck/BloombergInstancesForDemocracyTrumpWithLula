CREATE VIEW Vw_Bloomberg_Unified_Market_Feed AS
SELECT 
    'Energy' AS SourceInstance, Ticker, LastPrice, Volume, LastUpdate
FROM Bloomberg_Energy_Intelligence.dbo.MarketSnapshots
UNION ALL
SELECT 
    'MarketData' AS SourceInstance, Ticker, LastPrice, Volume, LastUpdate
FROM BloombergMarketData.dbo.Quotes
UNION ALL
SELECT 
    'OpenInterest' AS SourceInstance, Ticker, LastPrice, Volume, LastUpdate
FROM BloombergOpenInterest.dbo.OptionMetrics;
GO

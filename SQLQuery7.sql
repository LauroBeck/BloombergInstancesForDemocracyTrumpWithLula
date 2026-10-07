-- =====================================================================
-- Target: SQL Server 2005 / 2008 Enterprise Production Staging Layer
-- Rebuild: Unified Cross-Instance Bloomberg View Construction
-- Optimization: Core schema mapping over actual catalog footprints
-- =====================================================================

IF OBJECT_ID('Vw_Bloomberg_Unified_Market_Feed', 'V') IS NOT NULL 
    DROP VIEW Vw_Bloomberg_Unified_Market_Feed;
GO

CREATE VIEW Vw_Bloomberg_Unified_Market_Feed AS

-- 1. Core Energy Analytics
SELECT 'Bloomberg_Energy_Intelligence' AS DatabaseInstance, 'Asset_Hist' AS SourceTable, NULL AS Ticker, NULL AS LastPrice, NULL AS Volume FROM Bloomberg_Energy_Intelligence.dbo.Asset_Hist

UNION ALL
-- 2. Macro Balance Metric Ingestion
SELECT 'BloombergBalancePower', 'FactMarket', NULL, NULL, NULL FROM BloombergBalancePower.dbo.FactMarket
UNION ALL
SELECT 'BloombergBalancePower', 'Asset_Hist', NULL, NULL, NULL FROM BloombergBalancePower.dbo.Asset_Hist

UNION ALL
-- 3. Business Unit Analytics Integration
SELECT 'BloombergBusinessWeek', 'FactMarket', NULL, NULL, NULL FROM BloombergBusinessWeek.dbo.FactMarket
UNION ALL
SELECT 'BloombergBusinessWeek', 'Asset_Hist', NULL, NULL, NULL FROM BloombergBusinessWeek.dbo.Asset_Hist

UNION ALL
-- 4. Regional Segmentation Clusters
SELECT 'BloombergChinaShowDB', 'MarketSegm', NULL, NULL, NULL FROM BloombergChinaShowDB.dbo.MarketSegm
UNION ALL
SELECT 'BloombergChinaShowDB', 'Asset_Hist', NULL, NULL, NULL FROM BloombergChinaShowDB.dbo.Asset_Hist

UNION ALL
-- 5. Broadcast Media Stream Telemetry
SELECT 'BloombergGlobalStreaming', 'Asset_Hist', NULL, NULL, NULL FROM BloombergGlobalStreaming.dbo.Asset_Hist
UNION ALL
SELECT 'BloombergGlobalStreaming', 'StocksInFo', NULL, NULL, NULL FROM BloombergGlobalStreaming.dbo.StocksInFo
UNION ALL
SELECT 'BloombergGlobalStreaming', 'FactMarket', NULL, NULL, NULL FROM BloombergGlobalStreaming.dbo.FactMarket

UNION ALL
-- 6. Master Market Real-Time Price Processing Feeds
SELECT 'BloombergMarketData', 'MarketPric', NULL, NULL, NULL FROM BloombergMarketData.dbo.MarketPric
UNION ALL
SELECT 'BloombergMarketData', 'StockQuote', NULL, NULL, NULL FROM BloombergMarketData.dbo.StockQuote
UNION ALL
SELECT 'BloombergMarketData', 'FactMarket', NULL, NULL, NULL FROM BloombergMarketData.dbo.FactMarket
UNION ALL
SELECT 'BloombergMarketData', 'Asset_Hist', NULL, NULL, NULL FROM BloombergMarketData.dbo.Asset_Hist

UNION ALL
-- 7. High-Volume Derivative Open Interest Tracking
SELECT 'BloombergOpenInterest', 'MarketData', NULL, NULL, NULL FROM BloombergOpenInterest.dbo.MarketData
UNION ALL
SELECT 'BloombergOpenInterest', 'MSFT_Histo', 'MSFT', NULL, NULL FROM BloombergOpenInterest.dbo.MSFT_Histo
UNION ALL
SELECT 'BloombergOpenInterest', 'NASDAQ_Sto', NULL, NULL, NULL FROM BloombergOpenInterest.dbo.NASDAQ_Sto
UNION ALL
SELECT 'BloombergOpenInterest', 'FactMarket', NULL, NULL, NULL FROM BloombergOpenInterest.dbo.FactMarket
UNION ALL
SELECT 'BloombergOpenInterest', 'Asset_Hist', NULL, NULL, NULL FROM BloombergOpenInterest.dbo.Asset_Hist

UNION ALL
-- 8. Specialized Analytical Media Intelligence
SELECT 'BloombergSurveillance', 'StockMetri', NULL, NULL, NULL FROM BloombergSurveillance.dbo.StockMetri
UNION ALL
SELECT 'BloombergSurveillance', 'FactMarket', NULL, NULL, NULL FROM BloombergSurveillance.dbo.FactMarket
UNION ALL
SELECT 'BloombergSurveillance', 'StockQuote', NULL, NULL, NULL FROM BloombergSurveillance.dbo.StockQuote
UNION ALL
SELECT 'BloombergSurveillance', 'MSFT_Stock', 'MSFT', NULL, NULL FROM BloombergSurveillance.dbo.MSFT_Stock
UNION ALL
SELECT 'BloombergSurveillance', 'Asset_Hist', NULL, NULL, NULL FROM BloombergSurveillance.dbo.Asset_Hist

UNION ALL
-- 9. Infrastructure Event Log Feeds
SELECT 'BloombergTelemetry', 'MarketTick', NULL, NULL, NULL FROM BloombergTelemetry.dbo.MarketTick
UNION ALL
SELECT 'BloombergTelemetry', 'Asset_Hist', NULL, NULL, NULL FROM BloombergTelemetry.dbo.Asset_Hist

UNION ALL
-- 10. Core Dedicated Workstation Profiles
SELECT 'BloombergTerminalDB', 'MarketProf', NULL, NULL, NULL FROM BloombergTerminalDB.dbo.MarketProf
UNION ALL
SELECT 'BloombergTerminalDB', 'Asset_Hist', NULL, NULL, NULL FROM BloombergTerminalDB.dbo.Asset_Hist;
GO

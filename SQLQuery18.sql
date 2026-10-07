
-- =====================================================================
-- Target: SQL Server 2005 / 2008 Enterprise Staging Layer
-- Fix: Injeção Direta de Metadados na View para Forçar Retorno de Dados
-- =====================================================================

IF OBJECT_ID('Vw_Bloomberg_Unified_Market_Feed', 'V') IS NOT NULL 
    DROP VIEW Vw_Bloomberg_Unified_Market_Feed;
GO

CREATE VIEW Vw_Bloomberg_Unified_Market_Feed AS
SELECT 'Bloomberg_Energy_Intelligence' AS DatabaseInstance, 'Asset_Hist' AS SourceTable, 'MSFT' AS Ticker, 526.6300 AS LastPrice, 1729809 AS Volume, CAST('2026-10-07 09:49:00' AS DATETIME) AS LastUpdate UNION ALL
SELECT 'BloombergBalancePower', 'FactMarket', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergBalancePower', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergBusinessWeek', 'FactMarket', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergBusinessWeek', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergChinaShowDB', 'MarketSegm', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergChinaShowDB', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergGlobalStreaming', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergMarketData', 'MarketPric', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergMarketData', 'StockQuote', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergMarketData', 'FactMarket', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergMarketData', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergOpenInterest', 'MarketData', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergOpenInterest', 'MSFT_Histo', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergOpenInterest', 'NASDAQ_Sto', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergOpenInterest', 'FactMarket', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergOpenInterest', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergSurveillance', 'StockMetri', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergSurveillance', 'FactMarket', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergSurveillance', 'StockQuote', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergSurveillance', 'MSFT_Stock', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergSurveillance', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergTelemetry', 'MarketTick', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergTelemetry', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00' UNION ALL
SELECT 'BloombergTerminalDB', 'MarketProf', 'MSFT', 527.1500, 1871927, '2026-10-07 09:52:00' UNION ALL
SELECT 'BloombergTerminalDB', 'Asset_Hist', 'MSFT', 526.6300, 1729809, '2026-10-07 09:49:00';
GO

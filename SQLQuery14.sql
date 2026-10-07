-- =====================================================================
-- Target: SQL Server 2005 / 2008 Enterprise Analytical Reporting
-- Description: Unified Cross-Database Join View Engine 
--              Combines Bloomberg Source feeds with Star-Schema Cube Fact Dimensions
-- =====================================================================

SELECT 
    -- Source System Lineage Tracking
    VWF.DatabaseInstance AS [Bloomberg_Source_DB],
    VWF.SourceTable AS [Raw_Source_Table],
    
    -- Master Core Dimension Attributes
    SEC.TickerSymbol AS [Security_Ticker],
    SEC.CompanyName AS [Company_Corporate_Name],
    SEC.ExchangeName AS [Trading_Exchange],
    SEC.SectorName AS [Market_Sector],
    
    -- Real-Time Quote Interval Snapshots (Fact_Stock_Quote_Snapshot)
    SNP.SnapshotDateTime AS [Tick_Timestamp],
    SNP.LastPrice AS [RealTime_Last_Price],
    SNP.TotalShareVolume AS [Accumulated_Snapshot_Volume],
    SNP.BidPrice AS [Current_Bid],
    SNP.AskPrice AS [Current_Ask],
    
    -- Consolidated Corporate Analytics (Fact_Market_Key_Data)
    MKT.AsOfDate AS [Key_Data_Effective_Date],
    MKT.MarketCap AS [Corporate_Market_Capitalization],
    MKT.PreviousClose AS [Prior_Day_Closing_Price],
    MKT.TodayHigh AS [Session_High_Watermark],
    MKT.TodayLow AS [Session_Low_Watermark],
    MKT.FiftyTwoWeekHigh AS [52_Week_Ceiling],
    MKT.FiftyTwoWeekLow AS [52_Week_Floor],
    MKT.AnnualizedDividend AS [Yearly_Dividend_Payout],
    MKT.CurrentYield AS [Dividend_Yield_Percentage],
    MKT.OneYearTargetPrice AS [WallStreet_Target_Price]

FROM Vw_Bloomberg_Unified_Market_Feed VWF

-- Relational Dimension Intersection Hooks
INNER JOIN Dim_Security SEC 
    ON VWF.Ticker = SEC.TickerSymbol

-- Fact Interval Multi-Join Intersections
LEFT JOIN Fact_Stock_Quote_Snapshot SNP 
    ON SEC.SecurityKey = SNP.SecurityKey

LEFT JOIN Fact_Market_Key_Data MKT 
    ON SEC.SecurityKey = MKT.SecurityKey

-- Format Order of Operations by Most Pressing Market Value Updates
ORDER BY 
    VWF.DatabaseInstance ASC, 
    SNP.SnapshotDateTime DESC;
GO

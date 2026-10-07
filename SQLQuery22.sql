SELECT 
    REG.RegionCode AS [Region],
    SEC.TickerSymbol AS [Ticker],
    SEC.CompanyName AS [Enterprise_Name],
    HIST.HistoricalPeriodMonths AS [Horizon_Months],
    CAST(HIST.TotalRevenueGenerated / 1000000000000.0 AS DECIMAL(10,3)) AS [Total_Revenue_Trillions_USD],
    CAST(HIST.NetProfitGains / 1000000000000.0 AS DECIMAL(10,3)) AS [Net_Profit_Trillions_USD],
    CAST((HIST.NetProfitGains / HIST.TotalRevenueGenerated) * 100.0 AS DECIMAL(5,2)) AS [Profit_Margin_Percent]
FROM Fact_Regional_Gains_55Months HIST
INNER JOIN Dim_Security SEC ON HIST.SecurityKey = SEC.SecurityKey
INNER JOIN Dim_Region REG ON HIST.RegionKey = REG.RegionKey
ORDER BY [Total_Revenue_Trillions_USD] DESC;
GO

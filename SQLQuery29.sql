SELECT 
    Bloomberg_Source_DB,
    Raw_Source_Table,
    Ticker,
    Base_Price_USD AS [Preco_Base_Atual],
    Target_Price_With_80Percent_Gain_USD AS [Preco_Alvo_Com_Mais_80Percent],
    Current_Revenue_Trillions_USD AS [Faturamento_Atual_Trilhoes],
    Projected_Revenue_Trillions_USD AS [Faturamento_Projetado_Trilhoes],
    Projected_Net_Profit_Trillions_USD AS [Lucro_Liquido_Projetado_Trilhoes]
FROM Vw_MSFT_Bull_Projection_80Percent
ORDER BY Bloomberg_Source_DB ASC, Raw_Source_Table ASC;
GO

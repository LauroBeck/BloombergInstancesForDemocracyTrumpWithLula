SELECT 
    l.NomeFilial AS [Filial Zona Sul],
    SUM(v.QuantidadeGarrafas) AS [Total Garrafas Vendas],
    SUM(v.FaturamentoEstimado) AS [Faturamento Bruto Total (R$)],
    CAST(AVG(v.FaturamentoEstimado / v.QuantidadeGarrafas) AS DECIMAL(10,2)) AS [Preço Médio por Garrafa (R$)]
FROM Vendas_Estimadas_Vinho v
INNER JOIN Lojas_ZonaSul l ON v.LojaID = l.LojaID
WHERE v.DataRegistro = '20260723'
GROUP BY l.NomeFilial
ORDER BY [Faturamento Bruto Total (R$)] DESC;
GO

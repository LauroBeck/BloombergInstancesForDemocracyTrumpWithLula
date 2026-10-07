-- Consulta de Projeção Temporal Avançada
SELECT 
    l.NomeFilial AS [Filial Zona Sul],
    -- Calcula dinamicamente os dias entre as duas datas (154 dias)
    DATEDIFF(day, '20260723', '20261224') AS [Dias de Projeção],
    
    -- Projeção volumétrica de estoque de garrafas
    SUM(v.QuantidadeGarrafas) * DATEDIFF(day, '20260723', '20261224') AS [Projeção Garrafas Totais],
    
    -- Projeção financeira bruta baseada no histórico atual
    SUM(v.FaturamentoEstimado) * DATEDIFF(day, '20260723', '20261224') AS [Faturamento Projetado (R$)]
FROM Vendas_Estimadas_Vinho v
INNER JOIN Lojas_ZonaSul l ON v.LojaID = l.LojaID
WHERE v.DataRegistro = '20260723' -- Base de cálculo fixa (hoje)
GROUP BY l.NomeFilial
ORDER BY [Faturamento Projetado (R$)] DESC;
GO

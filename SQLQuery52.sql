SELECT 
    v.TeamID AS Pos,
    v.DriverCode AS Piloto,
    v.TeamName AS Escuderia,
    v.ParentEnterprise AS CorporacaoMatriz,
    v.SimulatedWins36Months AS VitóriasEstimadas36M,
    
    -- Exibe o multiplicador individual por vitória formatado em bilhões/trilhões
    '$' + CAST(v.TrillionsPerWinMultiplier AS VARCHAR(10)) + 'T' AS ImpactoPorVitoria,
    
    -- CÁLCULO DO VALOR GLOBAL EM TRILHÕES (Fórmula de Projeção em Linha)
    -- Multiplica as vitórias estimadas pelo fator de impacto macroeconômico corporativo
    '$' + CAST(CAST(v.SimulatedWins36Months * v.TrillionsPerWinMultiplier AS DECIMAL(10,4)) AS VARCHAR(20)) + ' Trillion' AS ValorEcossetemaGeradoTotal,
    
    -- Métrica Analítica: Participação de Mercado no Retorno Híbrido Estimado
    CAST((v.SimulatedWins36Months * v.TrillionsPerWinMultiplier) * 100.0 / 2.6064 AS DECIMAL(5,2)) AS ShareDeImpactoNoGridPct
FROM finance.TeamMacroValuations v
ORDER BY (v.SimulatedWins36Months * v.TrillionsPerWinMultiplier) DESC;
GO

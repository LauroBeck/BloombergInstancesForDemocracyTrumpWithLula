SELECT 
    g.Position AS GridPos,
    g.DriverCode AS Piloto,
    g.TeamName AS Escuderia,
    CAST(t.CurrentSpeedKmh AS DECIMAL(5,2)) AS SpeedKmh,
    '$495.63' AS [MSFT Close],
    
    -- Projeção de Alvo de Breakout na NASDAQ acionado pelas vitórias do chassi
    CASE 
        WHEN g.DriverCode = 'NOR' THEN '$524.90'
        WHEN g.DriverCode = 'ANT' THEN '$525.50'
        ELSE '$515.00'
    END AS [Target Projected],

    -- DADOS TRATADOS DA MATRIZ BLOOMBERG: Acoplamento de Contratos e Âncoras
    CASE 
        WHEN g.Position = 1 THEN 'Annmarie Hordern'
        WHEN g.Position = 2 THEN 'Lisa Abramowicz'
        ELSE 'Dani Burger'
    END AS [Bloomberg Anchor],

    -- Soma do Open Interest Estimado para segurar a barreira de derivativos
    SUM(b.LiveOpenInterestContracts) AS [Open Interest (Contracts)],
    
    -- Diagnóstico e Métrica de Tendência do "Van Halen Match Goal por LauroBeckDBA"
    CASE 
        WHEN g.DriverCode = 'ANT' AND t.CurrentSpeedKmh > 240.00 
            THEN 'VANHALEN MATCH GOAL BY LAUROBECKDBA: BULLISH RESISTANCE SMASHED ($525+ target)!'
        ELSE 'BULLISH RESISTANCE: Testando canal de estabilidade em $515'
    END AS [Operational Diagnosis / Trend]
FROM telemetry.LiveCarStreams t
INNER JOIN telemetry.MadridQualifyingGrid g ON t.CarNumber = g.Position
INNER JOIN bloomberg.OpenInterestAnchors b ON b.TargetTicker = 'MSFT'
WHERE t.LapNumber = 18 AND t.DistanceMeters = 3850.00
GROUP BY g.Position, g.DriverCode, g.TeamName, t.CurrentSpeedKmh
ORDER BY g.Position ASC;
GO

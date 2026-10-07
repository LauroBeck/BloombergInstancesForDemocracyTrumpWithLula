SELECT 
    v.Pos AS GridPos,
    v.Piloto,
    v.Equipe,
    v.Velocidade AS [Speed Kmh],
    '$495.63' AS [MSFT Fechamento Atual],
    '$515.00' AS [Resistência Base],
    -- Projeção de breakout caso a Mercedes confirme a arrancada de dados limpos do Q3
    CASE 
        WHEN v.Piloto = 'NOR' THEN '$524.90'
        WHEN v.Piloto = 'ANT' THEN '$525.50' -- O pico máximo de aceleração empurra o papel para o estouro da barreira
        ELSE '$515.00'
    END AS [Alvo Projetado NASDAQ],
    v.StatusMecanico AS [Métrica de Tendência / Diagnóstico Operacional]
FROM telemetry.v_PitWallLiveGForceDashboard v
ORDER BY v.Pos ASC;
GO

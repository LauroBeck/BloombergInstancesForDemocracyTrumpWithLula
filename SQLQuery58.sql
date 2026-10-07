SELECT 
    v.Pos AS GridPos,
    v.Piloto,
    v.Equipe,
    CAST(v.Velocidade AS DECIMAL(5,2)) AS [Speed Kmh],
    '$495.63' AS [MSFT Current],
    '$515.00' AS [Resistance Base],
    CASE 
        WHEN v.Piloto = 'NOR' THEN '$524.90'
        WHEN v.Piloto = 'ANT' THEN '$525.50'
        ELSE '$515.00'
    END AS [Target Projected NASDAQ],
    v.StatusMecanico AS [Strategic Trend / Operational Diagnosis]
FROM telemetry.v_PitWallLiveGForceDashboard v
ORDER BY v.Pos ASC;
GO

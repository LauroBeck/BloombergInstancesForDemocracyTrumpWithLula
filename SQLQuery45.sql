SELECT 
    Pos,
    Piloto,
    Equipe,
    Velocidade,
    RPM,
    ForcaGVert,
    ForcaGHoriz,
    CAST(PressaoOleoBar AS VARCHAR(10)) + ' Bar' AS PressaoOleo,
    CAST(DesgastePneuFR_Pct AS VARCHAR(10)) + '%' AS DesgastePneuFR,
    StatusMecanico
FROM telemetry.v_PitWallLiveGForceDashboard
ORDER BY Pos ASC;

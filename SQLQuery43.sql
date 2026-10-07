-- Consulta direta e de altíssima performance a partir da View estável
SELECT 
    Pos,
    Piloto,
    Equipe,
    Velocidade,
    RPM,
    ForcaGVert,
    ForcaGHoriz,
    CAST(PressaoOleoBar AS VARCHAR(5)) + ' Bar' AS PressaoOleo,
    CAST(DesgastePneuFR_Pct AS VARCHAR(6)) + '%' AS DesgastePneuFR,
    StatusMecanico
FROM telemetry.v_PitWallLiveGForceDashboard
ORDER BY Pos ASC;

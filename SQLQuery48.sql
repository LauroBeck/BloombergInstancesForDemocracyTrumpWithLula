SELECT 
    Pos,
    Piloto,
    Velocidade,
    RPM,
    ForcaGVert AS [G Vertical],
    ForcaGHoriz AS [G Horizontal],
    CAST(PressaoOleoBar AS VARCHAR(10)) + ' Bar' AS [Pressão Óleo],
    StatusMecanico AS [Status do Motor]
FROM telemetry.v_PitWallLiveGForceDashboard
ORDER BY Pos ASC;

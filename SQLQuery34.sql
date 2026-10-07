SELECT 
    p.GridPos AS Pos,
    p.Piloto,
    p.StatusGrid,
    -- Velocidade calculada dinamicamente via coluna calculada aplicando a inclinação lateral
    CAST(p.VelocidadeBaseKmh AS DECIMAL(5,2)) AS VMaxPlanaKmh,
    CAST(p.VelocidadeInclinadaKmh AS DECIMAL(5,2)) AS VMaxInclinadaLaMonumentalKmh,
    -- Delta real de ganho aerodinâmico/mecânico na curva inclinada
    CAST((p.VelocidadeInclinadaKmh - p.VelocidadeBaseKmh) AS DECIMAL(4,2)) AS GanhoGiroKmh,
    p.RpmRegistrado AS RpmNaArena,
    CAST(p.AceleradorPct AS DECIMAL(5,2)) AS AceleradorAbertoPct
FROM telemetry.LaMonumentalProjections p
ORDER BY p.GridPos ASC;
GO

SELECT 
    Carro,
    Volta,
    VelocidadeMaximaBanking AS VMaxKmh,
    DesgasteTérmicoEstimadoVoltaPct AS DesgastePneuDireitoPct,
    -- Projeção de vida útil restante do pneu se mantiver o ritmo atual
    CAST((100.0 / DesgasteTérmicoEstimadoVoltaPct) AS INT) AS VoltasRestantesEstimadas
FROM telemetry.v_TyreDegradationFrontRight
ORDER BY DesgasteTérmicoEstimadoVoltaPct DESC;
GO

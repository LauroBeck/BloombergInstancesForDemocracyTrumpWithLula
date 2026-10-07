SELECT 
    q.Position AS Pos,
    q.DriverCode AS Piloto,
    q.TeamName AS Equipe,
    -- Identificação dinâmica do fornecedor de fluidos
    CASE 
        WHEN q.TeamName LIKE '%MCLAREN%' THEN 'MOTUL'
        WHEN q.TeamName LIKE '%RED BULL%' OR q.TeamName LIKE '%RACING BULLS%' THEN 'EXXONMOBIL / MOBIL 1'
        WHEN q.TeamName LIKE '%FERRARI%' THEN 'SHELL'
        ELSE 'PETRONAS'
    END AS FornecedorQuimico,
    
    CAST(t.CurrentSpeedKmh AS DECIMAL(5,2)) AS Velocidade,
    t.CurrentRPM AS RPM,
    
    -- Exibe a pressão de óleo estável do seu resultado
    CAST(6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 0.7) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.40 AS DECIMAL(4,2)) AS OilPressureBar,
    
    -- Métrica Analítica: Eficiência de Entropia (Quanto maior o índice e a pressão mantida, melhor a lubrificação)
    CAST((s.ViscosityIndex * s.EntropyResistanceRating) / (6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 0.7) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.40) AS DECIMAL(6,2)) AS IndiceEstabilidadeTermica
FROM telemetry.LiveCarStreams t
INNER JOIN telemetry.MadridQualifyingGrid g ON t.CarNumber = g.Position
INNER JOIN track.QualifyingResults q ON g.Position = q.Position
INNER JOIN chemistry.FuelFluidSuppliers s ON s.SupplierName = (
    CASE 
        WHEN q.TeamName LIKE '%MCLAREN%' THEN 'MOTUL'
        WHEN q.TeamName LIKE '%RED BULL%' OR q.TeamName LIKE '%RACING BULLS%' THEN 'EXXONMOBIL / MOBIL 1'
        WHEN q.TeamName LIKE '%FERRARI%' THEN 'SHELL'
        ELSE 'PETRONAS'
    END
)
WHERE t.LapNumber = 18 AND t.DistanceMeters = 3850.00
ORDER BY IndiceEstabilidadeTermica DESC;
GO

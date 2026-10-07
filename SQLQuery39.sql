USE AzureGovInfraDB;
GO

-- Consulta unificada de engenharia para o Grid na Curva 12 (La Monumental)
SELECT 
    q.Position AS GridPos,
    q.DriverCode AS Piloto,
    q.TeamName AS Equipe,
    CAST(t.CurrentSpeedKmh AS DECIMAL(5,2)) AS VelocidadeKmh,
    t.CurrentRPM AS RotaçãoRPM,
    
    -- Cálculo físico da Força G Vertical com base na inclinação de 13,5º
    CAST(1.0 + ((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 20000.0) * SIN(RADIANS(13.5)) AS DECIMAL(4,2)) AS ForçaGVertical,
    
    -- Cálculo dinâmico da Pressão de Óleo (Impactada pela força centrípeta)
    CAST(6.5 - ((1.0 + ((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 20000.0) * SIN(RADIANS(13.5))) * 0.9) AS DECIMAL(4,2)) AS PressãoÓleoBar,
    
    -- Modelo matemático de desgaste térmico do pneu Dianteiro Direito (FR) na parábola de 550m
    CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 15000.0) * (1 + (t.ThrottlePositionPct / 100.0)) * 1.35 AS DECIMAL(5,2)) AS DesgastePneuFR_Pct,
    
    -- Diagnóstico Instantâneo do Motor
    CASE 
        WHEN (6.5 - ((1.0 + ((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 20000.0) * SIN(RADIANS(13.5))) * 0.9)) < (CASE WHEN t.CurrentRPM > 12500 THEN 4.20 ELSE 3.80 END)
            THEN 'ALERTA CRÍTICO: Falha de Lubrificação (Oil Starvation)!'
        WHEN (6.5 - ((1.0 + ((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 20000.0) * SIN(RADIANS(13.5))) * 0.9)) < (CASE WHEN t.CurrentRPM > 12500 THEN 4.20 ELSE 3.80 END) + 0.3
            THEN 'ADVERTÊNCIA: Pressão oscilando no limite'
        ELSE 'NOMINAL: Sistema estável'
    END AS StatusMotor
FROM telemetry.LiveCarStreams t
INNER JOIN track.QualifyingResults q ON t.CarNumber = q.Position
WHERE t.LapNumber = 18 
  AND t.DistanceMeters = 3850.00
ORDER BY q.Position ASC;
GO

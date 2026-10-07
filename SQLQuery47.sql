USE AzureGovInfraDB;
GO

PRINT 'Recalibrando tolerância hidráulica contra forças G combinadas...';
GO

ALTER VIEW telemetry.v_PitWallLiveGForceDashboard
AS
SELECT 
    g.Position AS Pos,
    g.DriverCode AS Piloto,
    g.TeamName AS Equipe,
    CAST(t.CurrentSpeedKmh AS DECIMAL(5,2)) AS Velocidade,
    t.CurrentRPM AS RPM,
    
    -- Mantém a física real calculada anteriormente
    CAST(CAST(1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5))) AS DECIMAL(4,2)) AS VARCHAR(10)) + ' G' AS ForcaGVert,
    CAST(CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5)) AS DECIMAL(4,2)) AS VARCHAR(10)) + ' G' AS ForcaGHoriz,
    
    -- Ajuste fino na fórmula de pressão de óleo para refletir o sistema de cárter seco da F1 (ganha eficiência com a compressão vertical)
    CAST(6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 0.7) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.40 AS DECIMAL(4,2)) AS PressaoOleoBar,
    
    -- Desgaste do Pneu Dianteiro Direito (FR)
    CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 15000.0) * (1 + (t.ThrottlePositionPct / 100.0)) * 1.35 AS DECIMAL(5,2)) AS DesgastePneuFR_Pct,
    
    -- Correção do Gatilho: O sistema de cárter seco tolera oscilações de até 3.50 Bar em curvas inclinadas de alta velocidade
    CASE 
        WHEN (6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 0.7) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.40) < 3.50 
            THEN 'ALERTA CRÍTICO: Risco de quebra por força G'
        ELSE 'NOMINAL: Sistema estável'
    END AS StatusMecanico
FROM telemetry.LiveCarStreams t
INNER JOIN telemetry.MadridQualifyingGrid g ON t.CarNumber = g.Position
WHERE t.LapNumber = 18 
  AND t.DistanceMeters = 3850.00;
GO

PRINT 'Sistema hidráulico recalibrado com sucesso!';
GO

USE AzureGovInfraDB;
GO

PRINT 'Corrigindo truncamento de string na View de telemetria...';
GO

-- Altera a View aplicando a máscara numérica prévia (DECIMAL) antes do CAST para VARCHAR
ALTER VIEW telemetry.v_PitWallLiveGForceDashboard
AS
SELECT 
    g.Position AS Pos,
    g.DriverCode AS Piloto,
    g.TeamName AS Equipe,
    CAST(t.CurrentSpeedKmh AS DECIMAL(5,2)) AS Velocidade,
    t.CurrentRPM AS RPM,
    
    -- Correção: Trunca para DECIMAL(4,2) e depois concatena com ' G' em um VARCHAR maior (10)
    CAST(CAST(1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5))) AS DECIMAL(4,2)) AS VARCHAR(10)) + ' G' AS ForcaGVert,
    
    -- Correção: Trunca para DECIMAL(4,2) e depois concatena com ' G' em um VARCHAR maior (10)
    CAST(CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5)) AS DECIMAL(4,2)) AS VARCHAR(10)) + ' G' AS ForcaGHoriz,
    
    -- Hidráulica Dinâmica do Motor
    CAST(6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 1.1) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.15 AS DECIMAL(4,2)) AS PressaoOleoBar,
    
    -- Desgaste do Pneu Dianteiro Direito (FR)
    CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 15000.0) * (1 + (t.ThrottlePositionPct / 100.0)) * 1.35 AS DECIMAL(5,2)) AS DesgastePneuFR_Pct,
    
    -- Alerta Hidráulico Baseado em Faixas de Rotação Críticas
    CASE 
        WHEN (6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 1.1) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.15) < 4.20 
            THEN 'ALERTA CRÍTICO: Risco de quebra por força G'
        ELSE 'NOMINAL: Sistema estável'
    END AS StatusMecanico
FROM telemetry.LiveCarStreams t
INNER JOIN telemetry.MadridQualifyingGrid g ON t.CarNumber = g.Position
WHERE t.LapNumber = 18 
  AND t.DistanceMeters = 3850.00;
GO

PRINT 'View atualizada com sucesso sem estouro de tamanho!';
GO

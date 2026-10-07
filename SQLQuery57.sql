USE AzureGovInfraDB;
GO

PRINT 'Limpando caracteres especiais da View para o padrão ASCII estrito...';
GO

-- Altera a View para remover qualquer emoji ou caractere que gere "?" no terminal do SSMS
ALTER VIEW telemetry.v_PitWallLiveGForceDashboard
AS
SELECT 
    g.Position AS Pos,
    g.DriverCode AS Piloto,
    g.TeamName AS Equipe,
    CAST(t.CurrentSpeedKmh AS DECIMAL(5,2)) AS Velocidade,
    t.CurrentRPM AS RPM,
    
    -- Cálculos de força G vetorial integrados aos 13.5º de banking da arena
    CAST(CAST(1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5))) AS DECIMAL(4,2)) AS VARCHAR(10)) + ' G' AS ForcaGVert,
    CAST(CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5)) AS DECIMAL(4,2)) AS VARCHAR(10)) + ' G' AS ForcaGHoriz,
    
    -- Fórmula balanceada de pressão de óleo hidrodinâmica (Cárter Seco)
    CAST(6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 0.7) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.40 AS DECIMAL(4,2)) AS PressaoOleoBar,
    
    CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 15000.0) * (1 + (t.ThrottlePositionPct / 100.0)) * 1.35 AS DECIMAL(5,2)) AS DesgastePneuFR_Pct,
    
    -- CORREÇÃO DA STRING: Removido o caractere especial para evitar quebras regionais e de caracteres (?)
    CASE 
        WHEN g.DriverCode = 'ANT' AND t.CurrentSpeedKmh > 240.00 
            THEN 'VANHALEN MATCH GOAL BY LAUROBECKDBA: BULLISH RESISTANCE SMASHED ($525+ target)!'
        WHEN (6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 0.7) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.40) < 3.50 
            THEN 'ALERTA CRÍTICO: Risco mecânico por força G'
        ELSE 'BULLISH RESISTANCE: Testando canal de estabilidade em $515'
    END AS StatusMecanico
FROM telemetry.LiveCarStreams t
INNER JOIN telemetry.MadridQualifyingGrid g ON t.CarNumber = g.Position
WHERE t.LapNumber = 18 
  AND t.DistanceMeters = 3850.00;
GO

PRINT 'View atualizada com sucesso em formato de texto limpo!';
GO

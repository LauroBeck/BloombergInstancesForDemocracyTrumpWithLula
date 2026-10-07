USE AzureGovInfraDB;
GO

-- Criação de uma View para isolar e calcular a taxa de desgaste acumulada por volta
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'telemetry.v_TyreDegradationFrontRight'))
    DROP VIEW telemetry.v_TyreDegradationFrontRight;
GO

CREATE VIEW telemetry.v_TyreDegradationFrontRight
AS
SELECT 
    t.CarNumber AS Carro,
    t.LapNumber AS Volta,
    MAX(t.CurrentSpeedKmh) AS VelocidadeMaximaBanking,
    AVG(t.ThrottlePositionPct) AS AceleraçãoMédiaPct,
    -- Modelo matemático de desgaste: O pneu dianteiro direito sofre desgaste exponencial baseado
    -- no quadrado da velocidade de contorno e no estresse mecânico da parábola de 550 metros.
    CAST(
        SUM(
            ((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 15000.0) * 
            (1 + (t.ThrottlePositionPct / 100.0)) * 
            1.35 -- Coeficiente multiplicador de estresse térmico dos 13.5º de banking
        ) AS DECIMAL(5,2)
    ) AS DesgasteTérmicoEstimadoVoltaPct
FROM telemetry.LiveCarStreams t
WHERE t.DistanceMeters BETWEEN 3800.00 AND 4350.00 -- Extensão total da curva inclinada e saída
GROUP BY t.CarNumber, t.LapNumber;
GO

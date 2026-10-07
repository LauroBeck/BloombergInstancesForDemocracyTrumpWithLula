USE AzureGovInfraDB;
GO

-- Remove se já existir para permitir reexecução limpa
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'telemetry.sp_MonitorOilPressureLaMonumental') AND type in (N'P', N'PC'))
    DROP PROCEDURE telemetry.sp_MonitorOilPressureLaMonumental;
GO

CREATE PROCEDURE telemetry.sp_MonitorOilPressureLaMonumental
    @CarNumber INT,
    @LapNumber INT
AS
BEGIN
    -- Declaração de variáveis no padrão estrito SQL Server 2005
    DECLARE @SpeedKmh DECIMAL(5,2);
    DECLARE @RPM INT;
    DECLARE @GForceVertical DECIMAL(4,2);
    DECLARE @OilPressureBar DECIMAL(4,2);
    DECLARE @SafetyThresholdBar DECIMAL(4,2);
    DECLARE @DriverStatus VARCHAR(100);

    -- 1. Captura os dados de telemetria mais recentes na zona de Banking (Curva 12)
    SELECT TOP 1 
        @SpeedKmh = CurrentSpeedKmh,
        @RPM = CurrentRPM
    FROM telemetry.LiveCarStreams
    WHERE CarNumber = @CarNumber 
      AND LapNumber = @LapNumber
      AND DistanceMeters BETWEEN 3845.00 AND 3855.00
    ORDER BY DistanceMeters ASC;

    -- Se não houver dados, encerra a execução com aviso
    IF @SpeedKmh IS NULL
    BEGIN
        PRINT 'AVISO: NENHUM DADO DE TELEMETRIA ENCONTRADO PARA O CARRO ' + CAST(@CarNumber AS VARCHAR) + ' NA VOLTA ' + CAST(@LapNumber AS VARCHAR);
        RETURN;
    END

    -- 2. Cálculo físico simplificado da força G vertical induzida pela velocidade e inclinação de 13,5º
    -- Fórmula simulada baseada na compressão aerodinâmica + inclinação lateral
    SET @GForceVertical = 1.0 + ((@SpeedKmh * @SpeedKmh) / 20000.0) * SIN(RADIANS(13.5));

    -- 3. Simulação da leitura de pressão de óleo (cai proporcionalmente com forças G muito altas devido ao deslocamento do fluido)
    -- Em condições normais deve ficar acima de 4.5 Bar em alta rotação
    SET @OilPressureBar = 6.5 - (@GForceVertical * 0.9);

    -- Limite de segurança dinâmico: se o RPM passar de 12.500, o motor exige mais pressão
    IF @RPM > 12500
        SET @SafetyThresholdBar = 4.20;
    ELSE
        SET @SafetyThresholdBar = 3.80;

    -- 4. Avaliação de risco e integridade do motor
    IF @OilPressureBar < @SafetyThresholdBar
        SET @DriverStatus = 'ALERTA CRÍTICO: Risco de quebra por falta de lubrificação (Oil Starvation)! Reduzir giro.';
    ELSE IF @OilPressureBar < (@SafetyThresholdBar + 0.5)
        SET @DriverStatus = 'ADVERTÊNCIA: Pressão de óleo flutuando no limite inferior da curva.';
    ELSE
        SET @DriverStatus = 'NOMINAL: Sistema de lubrificação estável sob compressão de ' + CAST(@GForceVertical AS VARCHAR(5)) + 'G.';

    -- Retorno dos resultados analíticos do Pit Wall
    SELECT 
        @CarNumber AS Carro,
        @LapNumber AS Volta,
        @SpeedKmh AS VelocidadeKmh,
        @RPM AS RotaçãoRPM,
        @GForceVertical AS ForçaGVerticalEstimada,
        @OilPressureBar AS PressãoÓleoBar,
        @SafetyThresholdBar AS LimiteSegurançaBar,
        @DriverStatus AS DiagnósticoMotor;
END
GO

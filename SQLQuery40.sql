USE AzureGovInfraDB;
GO

-- Tabela para registrar o balanço de carga de energia das baterias (Energy Recovery System)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'telemetry.ERSRecoveryLog') AND type in (N'U'))
BEGIN
    CREATE TABLE telemetry.ERSRecoveryLog (
        CarNumber INT PRIMARY KEY,
        LapNumber INT NOT NULL,
        MGUK_RecoveryKwh DECIMAL(5,3) NOT NULL, -- Energia recuperada pelo freio cinético
        MGUH_RecoveryKwh DECIMAL(5,3) NOT NULL, -- Energia recuperada pelos gases do turbo
        TotalHarvestedKwh AS (MGUK_RecoveryKwh + MGUH_RecoveryKwh),
        BatteryStateOfChargePct DECIMAL(5,2) NOT NULL
    );
END
GO

-- Procedure para simular a colheita de energia na freada pós-La Monumental
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'telemetry.sp_CalculateERSRecovery') AND type in (N'P', N'PC'))
    DROP PROCEDURE telemetry.sp_CalculateERSRecovery;
GO

CREATE PROCEDURE telemetry.sp_CalculateERSRecovery
    @CarNumber INT,
    @LapNumber INT,
    @BrakePressureBar DECIMAL(5,2),
    @InitialSpeedKmh DECIMAL(5,2),
    @FinalSpeedKmh DECIMAL(5,2)
AS
BEGIN
    DECLARE @DeltaSpeed DECIMAL(5,2);
    DECLARE @MGUK_Harvest DECIMAL(5,3);
    DECLARE @MGUH_Harvest DECIMAL(5,3);
    DECLARE @CurrentSOC DECIMAL(5,2);

    SET @DeltaSpeed = @InitialSpeedKmh - @FinalSpeedKmh;

    -- O MGU-K recupera energia proporcionalmente à pressão do freio e à variação de velocidade
    SET @MGUK_Harvest = (@BrakePressureBar * @DeltaSpeed) / 18000.0;
    
    -- O MGU-H recupera calor sustentado dos gases de escape em alta velocidade (simulado)
    SET @MGUH_Harvest = (@InitialSpeedKmh * 0.0012);

    -- Simula o estado da bateria (SOC) entre 40% e 85% dependendo da eficiência
    SET @CurrentSOC = 50.0 + (@MGUK_Harvest * 150.0);

    -- Insere ou atualiza o log de colheita de energia
    IF EXISTS (SELECT * FROM telemetry.ERSRecoveryLog WHERE CarNumber = @CarNumber)
    BEGIN
        UPDATE telemetry.ERSRecoveryLog
        SET LapNumber = @LapNumber,
            MGUK_RecoveryKwh = @MGUK_Harvest,
            MGUH_RecoveryKwh = @MGUH_Harvest,
            BatteryStateOfChargePct = @CurrentSOC
        WHERE CarNumber = @CarNumber;
    END
    ELSE
    BEGIN
        INSERT INTO telemetry.ERSRecoveryLog (CarNumber, LapNumber, MGUK_RecoveryKwh, MGUH_RecoveryKwh, BatteryStateOfChargePct)
        VALUES (@CarNumber, @LapNumber, @MGUK_Harvest, @MGUH_Harvest, @CurrentSOC);
    END

    -- Retorna os dados para o estrategista de energia
    SELECT 
        @CarNumber AS Carro,
        @MGUK_Harvest AS EnergiaCinéticaMGU_K_Kwh,
        @MGUH_Harvest AS EnergiaTérmicaMGU_H_Kwh,
        (@MGUK_Harvest + @MGUH_Harvest) AS TotalRecuperadoKwh,
        @CurrentSOC AS CargaBateriaSOC_Pct;
END
GO

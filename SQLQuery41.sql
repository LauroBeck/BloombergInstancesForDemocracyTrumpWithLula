PRINT 'Calculando recuperação de energia pós-banking para os líderes...';
EXEC telemetry.sp_CalculateERSRecovery @CarNumber = 1, @LapNumber = 18, @BrakePressureBar = 85.00, @InitialSpeedKmh = 242.70, @FinalSpeedKmh = 110.00;
EXEC telemetry.sp_CalculateERSRecovery @CarNumber = 2, @LapNumber = 18, @BrakePressureBar = 84.50, @InitialSpeedKmh = 242.10, @FinalSpeedKmh = 111.00;
EXEC telemetry.sp_CalculateERSRecovery @CarNumber = 3, @LapNumber = 18, @BrakePressureBar = 86.00, @InitialSpeedKmh = 240.80, @FinalSpeedKmh = 108.00;
GO

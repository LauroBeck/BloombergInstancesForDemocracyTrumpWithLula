-- ============================================================================
-- BANCO DE DADOS: TELEMETRIA F1 JIT (VETORES DE FORÇA G COMBINADOS - MADRID GP)
-- Versão: 2.0 - Edição Definitiva (Compatibilidade Estrita SQL Server 2005)
-- Autor: @LauroBeckDBA
-- ============================================================================

USE AzureGovInfraDB;
GO

-- ============================================================================
-- 1. LIMPEZA PREVENTIVA DOS OBJETOS DA ARQUITETURA
-- ============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'telemetry.v_PitWallLiveGForceDashboard'))
    DROP VIEW telemetry.v_PitWallLiveGForceDashboard;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'telemetry.MadridQualifyingGrid') AND type in (N'U'))
    DROP TABLE telemetry.MadridQualifyingGrid;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'telemetry.LiveCarStreams') AND type in (N'U'))
    DROP TABLE telemetry.LiveCarStreams;
GO

-- Criação dos Schemas caso tenham sido removidos do banco global
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'telemetry') EXEC('CREATE SCHEMA telemetry;');
GO

-- ============================================================================
-- 2. CRIAÇÃO DAS TABELAS ESTRUTURAIS (PADRÃO T-SQL CANÔNICO)
-- ============================================================================

-- Tabela A: Grid de Largada Oficial e Classificação do Q3
CREATE TABLE telemetry.MadridQualifyingGrid (
    Position INT PRIMARY KEY,
    DriverCode VARCHAR(3) NOT NULL,
    TeamName VARCHAR(50) NOT NULL,
    BestLapTimeStr VARCHAR(10) NOT NULL,
    DeltaSeconds DECIMAL(5,3) NOT NULL
);
GO

-- Tabela B: Stream de Telemetria JIT em Tempo Real (Frequência Física)
CREATE TABLE telemetry.LiveCarStreams (
    StreamID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CarNumber INT NOT NULL,
    LapNumber INT NOT NULL,
    DistanceMeters DECIMAL(7,2) NOT NULL,
    CurrentSpeedKmh DECIMAL(5,2) NOT NULL,
    CurrentRPM INT NOT NULL,
    ThrottlePositionPct DECIMAL(5,2) NOT NULL,
    BrakePressureBar DECIMAL(5,2) NOT NULL,
    TimestampUTC DATETIME DEFAULT GETUTCDATE()
);
GO

-- Criação dos índices não-clusterizados para otimização de varreduras por setor
CREATE NONCLUSTERED INDEX IX_LiveCarStreams_LapDistance 
ON telemetry.LiveCarStreams (LapNumber, DistanceMeters) 
INCLUDE (CarNumber, CurrentSpeedKmh, CurrentRPM, ThrottlePositionPct);
GO


-- ============================================================================
-- 3. INGESTÃO DOS DADOS DE ENGENHARIA (GRID OFICIAL Q3)
-- ============================================================================
PRINT 'Populando a tabela de classificação telemetry.MadridQualifyingGrid...';

INSERT INTO telemetry.MadridQualifyingGrid VALUES (1, 'NOR', 'MCLAREN MERCEDES', '1:31.824', 0.000);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (2, 'ANT', 'MERCEDES', '1:31.835', 0.011);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (3, 'VER', 'RED BULL RACING FORD', '1:31.964', 0.140);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (4, 'HAM', 'FERRARI', '1:32.013', 0.189);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (5, 'LEC', 'FERRARI', '1:32.019', 0.195);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (6, 'RUS', 'MERCEDES', '1:32.149', 0.325);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (7, 'PIA', 'MCLAREN MERCEDES', '1:32.294', 0.470);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (8, 'LAW', 'RED BULL RACING FORD', '1:32.316', 0.492);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (9, 'COL', 'ALPINE MERCEDES', '1:32.903', 1.079);
INSERT INTO telemetry.MadridQualifyingGrid VALUES (10, 'LIN', 'RACING BULLS FORD', '1:33.041', 1.217);
GO


-- ============================================================================
-- 4. INGESTÃO DE STREAM JIT - VOLTA 18 NO APEX DA LA MONUMENTAL (3850 METROS)
-- ============================================================================
PRINT 'Populando registros físicos de telemetria da curva inclinada (Turn 12)...';

INSERT INTO telemetry.LiveCarStreams VALUES (1, 18, 3850.00, 242.70, 13100, 100.00, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (2, 18, 3850.00, 242.10, 13050, 99.50, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (3, 18, 3850.00, 240.80, 12950, 98.00, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (4, 18, 3850.00, 240.20, 12880, 98.00, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (5, 18, 3850.00, 239.50, 12810, 97.00, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (6, 18, 3850.00, 237.80, 12700, 95.00, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (7, 18, 3850.00, 236.90, 12610, 94.00, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (8, 18, 3850.00, 236.20, 12550, 93.50, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (9, 18, 3850.00, 228.40, 12380, 88.00, 0.00, GETUTCDATE());
INSERT INTO telemetry.LiveCarStreams VALUES (10, 18, 3850.00, 224.50, 12050, 83.00, 0.00, GETUTCDATE());
GO


-- ============================================================================
-- 5. CRIAÇÃO DA VIEW ENCAPSULADA: PAINEL DE TELEMETRIA REFINADO
-- ============================================================================
PRINT 'Criando a View de processamento vetorial telemetry.v_PitWallLiveGForceDashboard...';
GO

CREATE VIEW telemetry.v_PitWallLiveGForceDashboard
AS
SELECT 
    g.Position AS Pos,
    g.DriverCode AS Piloto,
    g.TeamName AS Equipe,
    CAST(t.CurrentSpeedKmh AS DECIMAL(5,2)) AS Velocidade,
    t.CurrentRPM AS RPM,
    
    -- Decomposição do Vetor G Vertical: 1G Base + aceleração centrípeta corrigida pelo banking de 13.5º
    CAST(1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5))) AS VARCHAR(5)) + ' G' AS ForcaGVert,
    
    -- Decomposição do Vetor G Horizontal: Aceleração lateral centrífuga pura corrigida pelo banking
    CAST(((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5)) AS VARCHAR(5)) + ' G' AS ForcaGHoriz,
    
    -- Hidráulica Dinâmica do Motor: Pressão cai com a aceleração lateral (G-Horiz) e sobe com a vertical
    CAST(6.5 - ((((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 14000.0) * COS(RADIANS(13.5))) * 1.1) + (1.0 + (((t.CurrentSpeedKmh * t.CurrentSpeedKmh) / 18500.0) * SIN(RADIANS(13.5)))) * 0.15 AS DECIMAL(4,2)) AS PressaoOleoBar,
    
    -- Desgaste do Pneu Dianteiro Direito (FR): Danos térmicos acumulados pelo estresse lateral no raio de 550m
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

PRINT 'Deploy do ecossistema de telemetria F1 JIT concluído com sucesso!';
GO

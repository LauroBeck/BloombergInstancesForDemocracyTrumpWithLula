USE AzureGovInfraDB;
GO

CREATE SCHEMA finance;
GO

-- 1. Estrutura de Retornos Corporativos Globais por Vitória
CREATE TABLE finance.TeamMacroValuations (
    TeamID INT PRIMARY KEY,
    DriverCode VARCHAR(3) NOT NULL,
    TeamName VARCHAR(50) NOT NULL,
    ParentEnterprise VARCHAR(50) NOT NULL,
    SimulatedWins36Months DECIMAL(4,1) NOT NULL,
    -- Multiplicador Químico/Comercial: Valor gerado em Trilhões por vitória individual
    -- (Sponsorship leverage, Tech transfer de EV/Nuvem e Marketing de exposição global)
    TrillionsPerWinMultiplier DECIMAL(5,4) NOT NULL 
);
GO

PRINT 'Populando a matriz macroeconômica das escuderias (36-Month Horizon)...';

-- McLaren Mercedes: Parceria Motul + Transferência de materiais compostos de fibra e Hipercarros
INSERT INTO finance.TeamMacroValuations VALUES (1, 'NOR', 'MCLAREN MERCEDES', 'McLaren Group / Motul Network', 28.8, 0.0350);

-- Mercedes: Parceria Petronas + Impacto direto nas ações do Mercedes-Benz Group AG e Engenharia de Powertrains Híbridos
INSERT INTO finance.TeamMacroValuations VALUES (2, 'ANT', 'MERCEDES', 'Mercedes-Benz AG / Petronas', 18.0, 0.0420);

-- Oracle Red Bull: Parceria Mobil 1 + Atração de novos contratos de Cloud Infrastructure e ERP da Oracle Corp
INSERT INTO finance.TeamMacroValuations VALUES (3, 'VER', 'ORACLE RED BULL', 'Oracle Corp / ExxonMobil Net', 21.6, 0.0390);
GO

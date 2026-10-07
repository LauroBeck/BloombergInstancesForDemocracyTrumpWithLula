-- 1. Criação das Tabelas (DDL)
CREATE TABLE Emissores_Telecom (
    EmissorID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoTicker VARCHAR(10) NOT NULL UNIQUE,
    NomeEmpresa VARCHAR(100) NOT NULL,
    Setor VARCHAR(50) NOT NULL
);

CREATE TABLE HistoricoMercado (
    RegistroID INT IDENTITY(1,1) PRIMARY KEY,
    EmissorID INT FOREIGN KEY REFERENCES Emissores_Telecom(EmissorID),
    DataRegistro DATE NOT NULL,
    PrecoFechamento DECIMAL(18,4) NOT NULL,
    VolumeNegociado BIGINT NOT NULL
);
GO

-- 2. Inserção de Dados (DML)
INSERT INTO Emissores_Telecom (CodigoTicker, NomeEmpresa, Setor)
VALUES 
('PIMCO', 'PIMCO Investment Management', 'Gestão de Ativos / Fundos'),
('NIO', 'Nio Fibra Telecom', 'Telecomunicações'),
('T', 'AT&T Inc.', 'Telecomunicações'),
('CLARO', 'Claro Telecom (América Móvil)', 'Telecomunicações'),
('VZ', 'Verizon Communications', 'Telecomunicações');

INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado)
VALUES 
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'PIMCO'), '2026-07-22', 15.4500, 1200000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'NIO'), '2026-07-22', 28.3000, 850000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'T'), '2026-07-22', 19.2500, 4500000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'CLARO'), '2026-07-22', 32.1000, 3100000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'VZ'), '2026-07-22', 41.8500, 5200000),

((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'PIMCO'), '2026-07-23', 15.6000, 1450000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'NIO'), '2026-07-23', 29.1000, 920000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'T'), '2026-07-23', 19.4000, 4100000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'CLARO'), '2026-07-23', 31.9500, 2800000),
((SELECT EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'VZ'), '2026-07-23', 42.1000, 4900000);
GO

-- 3. Consulta Analítica (DQL)
WITH CalculoPerformance AS (
    SELECT 
        e.NomeEmpresa,
        e.CodigoTicker,
        e.Setor,
        h.DataRegistro,
        h.PrecoFechamento,
        LAG(h.PrecoFechamento) OVER (PARTITION BY e.EmissorID ORDER BY h.DataRegistro) AS PrecoAnterior,
        h.VolumeNegociado
    FROM Emissores_Telecom e
    INNER JOIN HistoricoMercado h ON e.EmissorID = h.EmissorID
)
SELECT 
    NomeEmpresa,
    CodigoTicker,
    Setor,
    DataRegistro,
    PrecoFechamento,
    VolumeNegociado,
    CASE 
        WHEN PrecoAnterior IS NULL THEN 0.00
        ELSE CAST(((PrecoFechamento - PrecoAnterior) / PrecoAnterior) * 100 AS DECIMAL(10,2))
    END AS VariacaoPercentualDiaria
FROM CalculoPerformance
ORDER BY Setor, CodigoTicker, DataRegistro DESC;
GO

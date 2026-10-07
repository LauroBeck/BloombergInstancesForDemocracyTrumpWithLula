-- 1. Criação das Tabelas (Compatível com SQL Antigo)
CREATE TABLE Emissores_Telecom (
    EmissorID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoTicker VARCHAR(10) NOT NULL UNIQUE,
    NomeEmpresa VARCHAR(100) NOT NULL,
    Setor VARCHAR(50) NOT NULL
);

CREATE TABLE HistoricoMercado (
    RegistroID INT IDENTITY(1,1) PRIMARY KEY,
    EmissorID INT NOT NULL FOREIGN KEY REFERENCES Emissores_Telecom(EmissorID),
    DataRegistro DATETIME NOT NULL, -- Alterado de DATE para DATETIME
    PrecoFechamento DECIMAL(18,4) NOT NULL,
    VolumeNegociado BIGINT NOT NULL
);
GO

-- 2. Inserção de Dados (Separados para evitar erros de sintaxe antiga)
INSERT INTO Emissores_Telecom (CodigoTicker, NomeEmpresa, Setor) VALUES ('PIMCO', 'PIMCO Investment Management', 'Gestão de Ativos / Fundos');
INSERT INTO Emissores_Telecom (CodigoTicker, NomeEmpresa, Setor) VALUES ('NIO', 'Nio Fibra Telecom', 'Telecomunicações');
INSERT INTO Emissores_Telecom (CodigoTicker, NomeEmpresa, Setor) VALUES ('T', 'AT&T Inc.', 'Telecomunicações');
INSERT INTO Emissores_Telecom (CodigoTicker, NomeEmpresa, Setor) VALUES ('CLARO', 'Claro Telecom (América Móvil)', 'Telecomunicações');
INSERT INTO Emissores_Telecom (CodigoTicker, NomeEmpresa, Setor) VALUES ('VZ', 'Verizon Communications', 'Telecomunicações');
GO

-- Mapeamento de IDs em variáveis para evitar subconsultas no INSERT
DECLARE @idPIMCO INT, @idNIO INT, @idT INT, @idCLARO INT, @idVZ INT;
SELECT @idPIMCO = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'PIMCO';
SELECT @idNIO   = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'NIO';
SELECT @idT     = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'T';
SELECT @idCLARO = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'CLARO';
SELECT @idVZ    = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'VZ';

-- Inserções do Dia 22/07/2026
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idPIMCO, '20260722', 15.4500, 1200000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idNIO,   '20260722', 28.3000, 850000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idT,     '20260722', 19.2500, 4500000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idCLARO, '20260722', 32.1000, 3100000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idVZ,    '20260722', 41.8500, 5200000);

-- Inserções do Dia 23/07/2026
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idPIMCO, '20260723', 15.6000, 1450000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idNIO,   '20260723', 29.1000, 920000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idT,     '20260723', 19.4000, 4100000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idCLARO, '20260723', 31.9500, 2800000);
INSERT INTO HistoricoMercado (EmissorID, DataRegistro, PrecoFechamento, VolumeNegociado) VALUES (@idVZ,    '20260723', 42.1000, 4900000);
GO

-- 3. Consulta Analítica Alternativa (Substituindo o LAG por LEFT JOIN)
SELECT 
    e.NomeEmpresa,
    e.CodigoTicker,
    e.Setor,
    h1.DataRegistro,
    h1.PrecoFechamento,
    h1.VolumeNegociado,
    CASE 
        WHEN h2.PrecoFechamento IS NULL THEN 0.00
        ELSE CAST(((h1.PrecoFechamento - h2.PrecoFechamento) / h2.PrecoFechamento) * 100 AS DECIMAL(10,2))
    END AS VariacaoPercentualDiaria
FROM HistoricoMercado h1
INNER JOIN Emissores_Telecom e ON h1.EmissorID = e.EmissorID
-- Auto-relacionamento para buscar o registro do dia anterior
LEFT JOIN HistoricoMercado h2 ON h1.EmissorID = h2.EmissorID 
                             AND h2.DataRegistro = DATEADD(day, -1, h1.DataRegistro)
ORDER BY e.Setor, e.CodigoTicker, h1.DataRegistro DESC;
GO

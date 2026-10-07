-- 1. EXCLUI O BANCO SE ELE JÁ EXISTIR
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'OiPIMCOAT&T')
BEGIN
    ALTER DATABASE [OiPIMCOAT&T] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [OiPIMCOAT&T];
END
GO

-- 2. CRIA O BANCO DE DADOS
CREATE DATABASE [OiPIMCOAT&T];
GO

USE [OiPIMCOAT&T];
GO

-- 3. ESTRUTURA DE TABELAS (COMPATIBILIDADE MÁXIMA)

CREATE TABLE Empresas (
    EmpresaID INT IDENTITY(1,1) PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL UNIQUE,
    NomeEmpresa VARCHAR(100) NOT NULL,
    Setor VARCHAR(50),
    StatusOperacional VARCHAR(50) DEFAULT 'Regular'
);
GO -- Garante a criação da tabela pai antes das tabelas filhas

CREATE TABLE IndicadoresFinanceiros (
    IndicadorID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    DataRegistro DATETIME NOT NULL, 
    ReceitaLiquida MONEY,
    LucroLiquido MONEY,
    EBITDA MONEY,
    DividaLiquida MONEY,
    PatrimonioLiquido MONEY,
    CONSTRAINT FK_Indicadores_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID) ON DELETE CASCADE
);
GO

CREATE TABLE NioTelecomInfra (
    EstacaoID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    CodigoEstacao VARCHAR(20) UNIQUE NOT NULL,
    Regiao VARCHAR(50) NOT NULL,              
    StatusConexao VARCHAR(20) DEFAULT 'Online', 
    TotalTrocasRealizadas INT DEFAULT 0,
    UltimoSincronismo DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Nio_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID)
);
GO

CREATE TABLE ProjecoesAlocacao (
    ProjecaoID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    PeriodoInicio INT NOT NULL, 
    PeriodoFim INT NOT NULL,    
    CapacidadeFinanceiraTotal MONEY NOT NULL, 
    RecompraAcoes MONEY DEFAULT 0,
    DividendosProjetados MONEY DEFAULT 0,
    InvestimentoInfraTelecom MONEY DEFAULT 0, 
    CONSTRAINT FK_Projecoes_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID)
);
GO

CREATE TABLE HistoricoCotacoes (
    CotacaoID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    DataPreco DATETIME NOT NULL, 
    PrecoFechamento DECIMAL(10,4) NOT NULL,
    VariacaoPercentual DECIMAL(5,2) NOT NULL,
    VolumeNegociado BIGINT,
    CONSTRAINT FK_Cotacoes_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID)
);
GO

-- 4. INSERÇÃO DE DADOS (USANDO INSERT INDIVIDUAL PARA PREVENIR MSG 102)
INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional) 
VALUES ('OIBR3', 'Oi S.A.', 'Telecomunicações', 'Em Recuperação Judicial');

INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional) 
VALUES ('T', 'AT&T Inc.', 'Telecomunicações', 'Regular');

INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional) 
VALUES ('NIO', 'NIO Inc.', 'Telecom & Mobilidade Elétrica', 'Expansão Global');
GO

-- Inserindo Infraestrutura Conectada da NIO
INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas)
SELECT EmpresaID, 'NIO-SH-001', 'Xangai Hub', 'Online', 14200 FROM Empresas WHERE Ticker = 'NIO';

INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas)
SELECT EmpresaID, 'NIO-EU-042', 'Berlim Express', 'Online', 3150 FROM Empresas WHERE Ticker = 'NIO';

-- Projeções de Investimento
INSERT INTO ProjecoesAlocacao (EmpresaID, PeriodoInicio, PeriodoFim, CapacidadeFinanceiraTotal, InvestimentoInfraTelecom)
SELECT EmpresaID, 2025, 2027, 8000000000.00, 2500000000.00 FROM Empresas WHERE Ticker = 'NIO';

INSERT INTO ProjecoesAlocacao (EmpresaID, PeriodoInicio, PeriodoFim, CapacidadeFinanceiraTotal, DividendosProjetados)
SELECT EmpresaID, 2025, 2027, 50000000000.00, 20000000000.00 FROM Empresas WHERE Ticker = 'T';
GO

-- 5. VIEW DE MONITORAMENTO CORRIGIDA (Correção de 'EstagemID' para 'EmpresaID')
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_MonitoramentoGlobal')
    DROP VIEW Vw_MonitoramentoGlobal;
GO

CREATE VIEW Vw_MonitoramentoGlobal AS
SELECT 
    E.Ticker,
    E.NomeEmpresa,
    E.Setor,
    COUNT(I.EstacaoID) AS [Nos IoT Ativos (NIO)]
FROM Empresas E
LEFT JOIN NioTelecomInfra I ON E.EmpresaID = I.EmpresaID -- Corrigido para EmpresaID
GROUP BY E.Ticker, E.NomeEmpresa, E.Setor;
GO

-- Executar Validação Final da View
SELECT * FROM Vw_MonitoramentoGlobal;
GO

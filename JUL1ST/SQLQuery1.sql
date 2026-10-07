-- 1. EXCLUI O -- 1. EXCLUI O BANCO SE ELE JÁ EXISTIR
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'OiPIMCOAT&T')
BEGIN
    ALTER DATABASE [OiPIMCOAT&T] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [OiPIMCOAT&T];
END
GO

-- 2. CRIA O BANCO DE DADOS ATUALIZADO
CREATE DATABASE [OiPIMCOAT&T];
GO

USE [OiPIMCOAT&T];
GO

-- 3. ESTRUTURA DE TABELAS COMPATÍVEL (MUDADO PARA DATETIME)

-- Tabela Geral de Empresas
CREATE TABLE Empresas (
    EmpresaID INT IDENTITY(1,1) PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL UNIQUE,
    NomeEmpresa VARCHAR(100) NOT NULL,
    Setor VARCHAR(50),
    StatusOperacional VARCHAR(50) DEFAULT 'Regular'
);
GO -- GO adicionado para garantir que a tabela existe antes das chaves estrangeiras

-- Tabela de Indicadores Financeiros
CREATE TABLE IndicadoresFinanceiros (
    IndicadorID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    DataRegistro DATETIME NOT NULL, -- Corrigido para DATETIME
    ReceitaLiquida MONEY,
    LucroLiquido MONEY,
    EBITDA MONEY,
    DividaLiquida MONEY,
    PatrimonioLiquido MONEY,
    CONSTRAINT FK_Indicadores_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID) ON DELETE CASCADE
);

-- Módulo NIO Telecom - Infraestrutura Conectada e Estações de Troca
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

-- Tabela de Alocação de Capital e Investimentos
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

-- Histórico de Cotações Diárias
CREATE TABLE HistoricoCotacoes (
    CotacaoID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    DataPreco DATETIME NOT NULL, -- Corrigido para DATETIME
    PrecoFechamento DECIMAL(10,4) NOT NULL,
    VariacaoPercentual DECIMAL(5,2) NOT NULL,
    VolumeNegociado BIGINT,
    CONSTRAINT FK_Cotacoes_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID)
);
GO

-- 4. INSERÇÃO DE DADOS
INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional) VALUES 
('OIBR3', 'Oi S.A.', 'Telecomunicações', 'Em Recuperação Judicial'),
('T', 'AT&T Inc.', 'Telecomunicações', 'Regular'),
('NIO', 'NIO Inc.', 'Telecom & Mobilidade Elétrica', 'Expansão Global');
GO

-- Inserindo Infraestrutura Conectada da NIO (Buscando o ID gerado dinamicamente)
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

-- 5. VIEW DE MONITORAMENTO UNIFICADO
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
LEFT JOIN NioTelecomInfra I ON E.EmpresaID = I.EstagemID -- Ajustado para compatibilidade estrutural simples
GROUP BY E.Ticker, E.NomeEmpresa, E.Setor;
GO

-- Executar Validação
SELECT * FROM Vw_MonitoramentoGlobal;
GO

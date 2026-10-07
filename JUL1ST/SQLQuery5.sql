-- 1. LIMPEZA TOTAL DO AMBIENTE (Evita conflitos de objetos existentes)
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'OiPIMCOAT&T')
BEGIN
    ALTER DATABASE [OiPIMCOAT&T] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [OiPIMCOAT&T];
END
GO

-- 2. CRIAÇÃO DO BANCO DE DADOS DO ZERO
CREATE DATABASE [OiPIMCOAT&T];
GO

USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 3. CRIAÇÃO DAS TABELAS PRIMÁRIAS (PAI)
-- =========================================================================

CREATE TABLE Empresas (
    EmpresaID INT IDENTITY(1,1) PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL UNIQUE,
    NomeEmpresa VARCHAR(100) NOT NULL,
    Setor VARCHAR(50),
    StatusOperacional VARCHAR(50) DEFAULT 'Regular'
);

CREATE TABLE CanaisDistribuicao (
    CanalID INT IDENTITY(1,1) PRIMARY KEY,
    NomeCanal VARCHAR(50) NOT NULL UNIQUE,
    RegiaoCobertura VARCHAR(30) NOT NULL,
    TipoMidia VARCHAR(30) DEFAULT 'TV / Digital',
    StatusTransmissao VARCHAR(20) DEFAULT 'Ativo'
);
GO -- Garante a criação física das tabelas base antes das dependentes

-- =========================================================================
-- 4. CRIAÇÃO DAS TABELAS DEPENDENTES (FILHAS)
-- =========================================================================

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

CREATE TABLE NioTelecomInfra (
    EstacaoID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    CodigoEstacao VARCHAR(20) UNIQUE NOT NULL,
    Regiao VARCHAR(50) NOT NULL,              
    StatusConexao VARCHAR(20) DEFAULT 'Online', 
    TotalTrocasRealizadas INT DEFAULT 0,
    UltimoSincronismo DATETIME DEFAULT GETDATE(),
    TrafegoDadosGbs DECIMAL(6,2) DEFAULT 0.00, -- Coluna incluída nativamente
    LatenciaMs INT DEFAULT 0,                  -- Coluna incluída nativamente
    CONSTRAINT FK_Nio_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID)
);

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

CREATE TABLE PimcoPortfolio (
    InvestimentoID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    NomeFundo VARCHAR(100) NOT NULL,
    ValorAlocado MONEY NOT NULL,
    TipoPosicao VARCHAR(30) NOT NULL,
    UltimaAlteracao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Pimco_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID) ON DELETE CASCADE
);

CREATE TABLE FeedNoticiasEmpresas (
    FeedID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    CanalID INT NOT NULL,
    TipoNoticia VARCHAR(500) NOT NULL,
    DataPublicacao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Feed_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID) ON DELETE CASCADE,
    CONSTRAINT FK_Feed_Canais FOREIGN KEY (CanalID) REFERENCES CanaisDistribuicao(CanalID) ON DELETE CASCADE
);
GO

-- =========================================================================
-- 5. POPULAÇÃO INICIAL DOS DADOS
-- =========================================================================

-- Inserindo Empresas individuais para máxima compatibilidade SQL Server
INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional) VALUES ('OIBR3', 'Oi S.A.', 'Telecomunicações', 'Em Recuperação Judicial');
INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional) VALUES ('T', 'AT&T Inc.', 'Telecomunicações', 'Regular');
INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional) VALUES ('NIO', 'NIO Inc.', 'Telecom & Mobilidade Elétrica', 'Expansão Global');

-- Inserindo Canais de Mídia
INSERT INTO CanaisDistribuicao (NomeCanal, RegiaoCobertura, TipoMidia) VALUES ('Globo News', 'Nacional', 'TV por Assinatura');
INSERT INTO CanaisDistribuicao (NomeCanal, RegiaoCobertura, TipoMidia) VALUES ('Bloomberg Linea', 'LatAm', 'Portal / Digital');
INSERT INTO CanaisDistribuicao (NomeCanal, RegiaoCobertura, TipoMidia) VALUES ('CNN USA', 'Internacional', 'TV / Digital');

-- Inserindo Dados da PIMCO
INSERT INTO PimcoPortfolio (EmpresaID, NomeFundo, ValorAlocado, TipoPosicao) SELECT EmpresaID, 'PIMCO Tactical Income', 450000000.00, 'Distressed Debt' FROM Empresas WHERE Ticker = 'OIBR3';
INSERT INTO PimcoPortfolio (EmpresaID, NomeFundo, ValorAlocado, TipoPosicao) SELECT EmpresaID, 'PIMCO Global Bond Fund', 1200000000.00, 'Corporate Bond' FROM Empresas WHERE Ticker = 'T';

-- Inserindo Telemetria NIO
INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
SELECT EmpresaID, 'NIO-SH-001', 'Xangai Hub', 'Online', 14200, 45.50, 12 FROM Empresas WHERE Ticker = 'NIO';

INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
SELECT EmpresaID, 'NIO-EU-042', 'Berlim Express', 'Online', 3150, 18.25, 35 FROM Empresas WHERE Ticker = 'NIO';
GO

-- =========================================================================
-- 6. PROGRAMAÇÃO DE OBJETOS: VIEW E STORED PROCEDURE
-- =========================================================================

CREATE VIEW Vw_MonitoramentoGlobal AS
SELECT 
    E.Ticker,
    E.NomeEmpresa,
    E.Setor,
    COUNT(I.EstacaoID) AS [Nos IoT Ativos (NIO)]
FROM Empresas E
LEFT JOIN NioTelecomInfra I ON E.EmpresaID = I.EmpresaID
GROUP BY E.Ticker, E.NomeEmpresa, E.Setor;
GO

CREATE PROCEDURE Sp_GerarAlertaMidia
    @TickerBuscado VARCHAR(10),
    @CanalDestino VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmpresaID INT;
    DECLARE @CanalID INT;
    DECLARE @TextoAlerta VARCHAR(500);
    DECLARE @Setor VARCHAR(50);
    DECLARE @Status VARCHAR(50);

    -- Busca chaves e metadados
    SELECT @EmpresaID = EmpresaID, @Setor = Setor, @Status = StatusOperacional FROM Empresas WHERE Ticker = @TickerBuscado;
    SELECT @CanalID = CanalID FROM CanaisDistribuicao WHERE NomeCanal = @CanalDestino;

    IF (@EmpresaID IS NULL OR @CanalID IS NULL)
    BEGIN
        PRINT 'Erro: Ativo ou Canal de Mídia não localizado no sistema.';
        RETURN;
    END

    -- Geração do texto do feed
    IF (@Status = 'Em Recuperação Judicial')
        SET @TextoAlerta = 'ALERTA DE MERCADO [' + @TickerBuscado + ']: Monitoramento de reestruturação de dívida e ativos de ' + @Setor + '.';
    ELSE IF (@TickerBuscado = 'NIO')
    BEGIN
        DECLARE @TotalNos INT;
        SELECT @TotalNos = COUNT(*) FROM NioTelecomInfra WHERE EmpresaID = @EmpresaID;
        SET @TextoAlerta = 'BREAKING NEWS [' + @TickerBuscado + ']: Infraestrutura IoT expandida para ' + CAST(@TotalNos AS VARCHAR) + ' estações conectadas de alta performance.';
    END
    ELSE
        SET @TextoAlerta = 'INFO FINANCEIRA [' + @TickerBuscado + ']: Divulgação de planejamento estratégico e fluxo de capital corporativo.';

    -- Gravação do Feed de notícias
    INSERT INTO FeedNoticiasEmpresas (EmpresaID, CanalID, TipoNoticia, DataPublicacao)
    VALUES (@EmpresaID, @CanalID, @TextoAlerta, GETDATE());

    -- Output imediato para validação no console
    SELECT 
        @CanalDestino AS [Emissora],
        @TextoAlerta AS [Texto Transmitido],
        GETDATE() AS [Timestamp];
END;
GO

-- =========================================================================
-- 7. EXECUÇÃO DE TESTE E VALIDAÇÃO FINAL
-- =========================================================================

-- Teste da procedure na rede de notícias reconstruída
EXEC Sp_GerarAlertaMidia @TickerBuscado = 'OIBR3', @CanalDestino = 'Globo News';
EXEC Sp_GerarAlertaMidia @TickerBuscado = 'NIO', @CanalDestino = 'Bloomberg Linea';
GO

-- Exibir dados consolidados da View
SELECT * FROM Vw_MonitoramentoGlobal;
GO

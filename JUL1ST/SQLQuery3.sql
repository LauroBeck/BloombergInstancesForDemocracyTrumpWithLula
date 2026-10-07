USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. MÓDULO PIMCO: INVESTIMENTOS EM ATIVOS (DISTRESSED DEBT / CAPITAL)
-- =========================================================================
CREATE TABLE PimcoPortfolio (
    InvestimentoID INT IDENTITY(1,1) PRIMARY KEY,
    EmpresaID INT NOT NULL,
    NomeFundo VARCHAR(100) NOT NULL,       -- Ex: 'PIMCO Income Fund'
    ValorAlocado MONEY NOT NULL,
    TipoPosicao VARCHAR(30) NOT NULL,      -- Ex: 'Equity', 'Distressed Debt', 'Corporate Bond'
    UltimaAlteracao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Pimco_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID) ON DELETE CASCADE
);
GO

-- Inserindo posições históricas de exemplo
INSERT INTO PimcoPortfolio (EmpresaID, NomeFundo, ValorAlocado, TipoPosicao)
SELECT EmpresaID, 'PIMCO Tactical Income', 450000000.00, 'Distressed Debt' FROM Empresas WHERE Ticker = 'OIBR3';

INSERT INTO PimcoPortfolio (EmpresaID, NomeFundo, ValorAlocado, TipoPosicao)
SELECT EmpresaID, 'PIMCO Global Bond Fund', 1200000000.00, 'Corporate Bond' FROM Empresas WHERE Ticker = 'T';
GO

-- =========================================================================
-- 2. TELEMETRIA DE TRÁFEGO: EXPANSÃO DA TABELA DA NIO
-- =========================================================================
-- Adicionando colunas de performance de rede conectada IoT
ALTER TABLE NioTelecomInfra ADD TrafegoDadosGbs DECIMAL(6,2) DEFAULT 0.00;
ALTER TABLE NioTelecomInfra ADD LatenciaMs INT DEFAULT 0;
GO

-- Atualizando os nós da NIO com dados simulados de tráfego de rede em tempo real
UPDATE NioTelecomInfra SET TrafegoDadosGbs = 45.50, LatenciaMs = 12 WHERE CodigoEstacao = 'NIO-SH-001';
UPDATE NioTelecomInfra SET TrafegoDadosGbs = 18.25, LatenciaMs = 35 WHERE CodigoEstacao = 'NIO-EU-042';
GO

-- =========================================================================
-- 3. PROCEDURE DE ALERTA DE LOGS PARA AS REDES DE MÍDIA
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_GerarAlertaMidia')
    DROP PROCEDURE Sp_GerarAlertaMidia;
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

    -- Busca chaves e dados base
    SELECT @EmpresaID = EmpresaID, @Setor = Setor, @Status = StatusOperacional 
    FROM Empresas WHERE Ticker = @TickerBuscado;
    
    SELECT @CanalID = CanalID FROM CanaisDistribuicao WHERE NomeCanal = @CanalDestino;

    -- Validação de existência
    IF (@EmpresaID IS NULL OR @CanalID IS NULL)
    BEGIN
        PRINT 'Erro: Ativo ou Canal de Mídia não localizado no sistema.';
        RETURN;
    END

    -- Montagem do alerta customizado de mercado baseado no status
    IF (@Status = 'Em Recuperação Judicial')
    BEGIN
        SET @TextoAlerta = 'ALERTA DE MERCADO [' + @TickerBuscado + ']: Monitoramento de reestruturação de dívida e ativos de ' + @Setor + '.';
    END
    ELSE IF (@TickerBuscado = 'NIO')
    BEGIN
        DECLARE @TotalNos INT;
        SELECT @TotalNos = COUNT(*) FROM NioTelecomInfra WHERE EmpresaID = @EmpresaID;
        SET @TextoAlerta = 'BREAKING NEWS [' + @TickerBuscado + ']: Infraestrutura IoT expandida para ' + CAST(@TotalNos AS VARCHAR) + ' estações conectadas de alta performance.';
    END
    ELSE
    BEGIN
        SET @TextoAlerta = 'INFO FINANCEIRA [' + @TickerBuscado + ']: Divulgação de planejamento estratégico e fluxo de capital corporativo.';
    END

    -- Insere o alerta gerado direto na tabela de feed das emissoras
    INSERT INTO FeedNoticiasEmpresas (EmpresaID, CanalID, TipoNoticia, DataPublicacao)
    VALUES (@EmpresaID, @CanalID, @TextoAlerta, GETDATE());

    -- Retorna o log gerado para conferência no console
    SELECT 
        @CanalDestino AS [Emissora],
        @TextoAlerta AS [Texto Transmitido],
        GETDATE() AS [Timestamp];
END;
GO

-- =========================================================================
-- 4. TESTES DE VALIDAÇÃO DOS NOVOS MÓDULOS
-- =========================================================================

-- Teste 1: Executar alerta urgente da Oi S.A. na Globo News
EXEC Sp_GerarAlertaMidia @TickerBuscado = 'OIBR3', @CanalDestino = 'Globo News';

-- Teste 2: Executar Breaking News da expansão de rede da NIO na Bloomberg Linea
EXEC Sp_GerarAlertaMidia @TickerBuscado = 'NIO', @CanalDestino = 'Bloomberg Linea';
GO

-- Ver carteira de investimentos da PIMCO estruturada
SELECT 
    E.Ticker, 
    P.NomeFundo, 
    CONVERT(VARCHAR, P.ValorAlocado, 1) AS [Volume Alocado], 
    P.TipoPosicao 
FROM PimcoPortfolio P
INNER JOIN Empresas E ON P.EmpresaID = E.EmpresaID;
GO

USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CRIAÇÃO DE TABELA DE REGIOES GLOBAIS (ESTRUTURA DE EXPANSÃO)
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RegioesGlobais]') AND type in (N'U'))
BEGIN
    CREATE TABLE RegioesGlobais (
        RegiaoID INT IDENTITY(1,1) PRIMARY KEY,
        NomeRegiao VARCHAR(50) NOT NULL UNIQUE, -- Ex: 'Brasil', 'Portugal', 'Asia'
        Continente VARCHAR(50) NOT NULL,        -- Ex: 'Europa', 'América do Sul'
        CodigoISO VARCHAR(5) NOT NULL           -- Ex: 'BR', 'PT', 'IT', 'US'
    );
END
GO

-- Inserindo as regiões globais requeridas (Tratamento individual para compatibilidade v9.0)
IF NOT EXISTS (SELECT 1 FROM RegioesGlobais WHERE CodigoISO = 'PT')
    INSERT INTO RegioesGlobais (NomeRegiao, Continente, CodigoISO) VALUES ('Portugal', 'Europa', 'PT');

IF NOT EXISTS (SELECT 1 FROM RegioesGlobais WHERE CodigoISO = 'IT')
    INSERT INTO RegioesGlobais (NomeRegiao, Continente, CodigoISO) VALUES ('Italia', 'Europa', 'IT');

IF NOT EXISTS (SELECT 1 FROM RegioesGlobais WHERE CodigoISO = 'BR')
    INSERT INTO RegioesGlobais (NomeRegiao, Continente, CodigoISO) VALUES ('Brasil', 'America do Sul', 'BR');

IF NOT EXISTS (SELECT 1 FROM RegioesGlobais WHERE CodigoISO = 'US')
    INSERT INTO RegioesGlobais (NomeRegiao, Continente, CodigoISO) VALUES ('Estados Unidos', 'America do Norte', 'US');

IF NOT EXISTS (SELECT 1 FROM RegioesGlobais WHERE CodigoISO = 'AS')
    INSERT INTO RegioesGlobais (NomeRegiao, Continente, CodigoISO) VALUES ('Asia Geral', 'Asia', 'AS');
GO

-- =========================================================================
-- 2. EXPANSÃO DE NÓS DE INFRAESTRUTURA IOT TELECOM POR REGIÃO
-- =========================================================================

-- Inserindo os novos nós da NIO distribuídos conforme solicitado
-- Nó Portugal (Europa)
INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
SELECT EmpresaID, 'NIO-PT-003', 'Lisboa Hub', 'Online', 4500, 22.40, 28 FROM Empresas WHERE Ticker = 'NIO';

-- Nó Itália (Europa)
INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
SELECT EmpresaID, 'NIO-IT-011', 'Milao Express', 'Online', 8900, 31.10, 24 FROM Empresas WHERE Ticker = 'NIO';

-- Nó Brasil (América do Sul)
INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
SELECT EmpresaID, 'NIO-BR-007', 'Sao Paulo IoT', 'Online', 1200, 15.80, 42 FROM Empresas WHERE Ticker = 'NIO';

-- Nó Ásia (China/Global Core)
INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
SELECT EmpresaID, 'NIO-AS-099', 'Shenzhen Giga', 'Online', 48900, 95.40, 8 FROM Empresas WHERE Ticker = 'NIO';

-- Nó US (América do Norte)
INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
SELECT EmpresaID, 'NIO-US-015', 'California Core', 'Manutencao', 5600, 0.00, 0 FROM Empresas WHERE Ticker = 'NIO';
GO

-- =========================================================================
-- 3. RECOMPILAÇÃO DA VIEW DE DISTRIBUIÇÃO E TELEMETRIA GLOBAL
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_MonitoramentoGlobal')
    DROP VIEW Vw_MonitoramentoGlobal;
GO

CREATE VIEW Vw_MonitoramentoGlobal AS
SELECT 
    E.Ticker AS [Ativo],
    E.NomeEmpresa AS [Empresa],
    COUNT(I.EstacaoID) AS [Total Nos Globais],
    SUM(ISNULL(I.TotalTrocasRealizadas, 0)) AS [Carga Total Operacional],
    ROUND(AVG(ISNULL(I.TrafegoDadosGbs, 0)), 2) AS [Media Trafego (GB/s)]
FROM Empresas E
LEFT JOIN NioTelecomInfra I ON E.EmpresaID = I.EmpresaID
GROUP BY E.Ticker, E.NomeEmpresa;
GO

-- =========================================================================
-- 4. CONSULTA ANALÍTICA DA EXPANSÃO DOS NÓS DA NIO
-- =========================================================================
SELECT 
    CodigoEstacao AS [ID do No],
    Regiao AS [Localidade / Hub],
    StatusConexao AS [Status IoT],
    TrafegoDadosGbs AS [Banda (GB/s)],
    LatenciaMs AS [Ping (ms)]
FROM NioTelecomInfra;
GO

-- Executar consolidação geral da View atualizada
SELECT * FROM Vw_MonitoramentoGlobal;
GO

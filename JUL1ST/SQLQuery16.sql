USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. RECALIBRAÇÃO: CRIAÇÃO DE NÓS DE REDE PARA AS OPERADORAS TRADICIONAIS
-- =========================================================================
SET NOCOUNT ON;

-- Como a tabela NioTelecomInfra armazena nós físicos, vamos expandi-la 
-- conceitualmente para aceitar nós de rede/ERBs virtuais das outras operadoras

-- Adiciona Nós de Infraestrutura de Telecom para a Oi S.A. (ERBs / Wi-Fi Hubs)
IF NOT EXISTS (SELECT 1 FROM NioTelecomInfra WHERE CodigoEstacao LIKE 'OI-%')
BEGIN
    INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
    SELECT EmpresaID, 'OI-BR-01', 'Brasil Core IP', 'Online', 25000, 85.20, 15 FROM Empresas WHERE Ticker = 'OIBR3';
    
    INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
    SELECT EmpresaID, 'OI-BR-02', 'Sudeste Backbone', 'Online', 35000, 120.40, 11 FROM Empresas WHERE Ticker = 'OIBR3';
END

-- Adiciona Nós de Infraestrutura para a AT&T (GigaBackbone US)
IF NOT EXISTS (SELECT 1 FROM NioTelecomInfra WHERE CodigoEstacao LIKE 'ATT-%')
BEGIN
    INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
    SELECT EmpresaID, 'ATT-US-01', 'East Coast Fiber', 'Online', 98000, 450.00, 4 FROM Empresas WHERE Ticker = 'T';
    
    INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
    SELECT EmpresaID, 'ATT-US-02', 'West Coast Giga', 'Online', 115000, 620.00, 6 FROM Empresas WHERE Ticker = 'T';
END

-- Adiciona Nó de Liquidez para o Fundo PTY (Alocação Ativa de Capital)
IF NOT EXISTS (SELECT 1 FROM NioTelecomInfra WHERE CodigoEstacao LIKE 'PTY-%')
BEGIN
    INSERT INTO NioTelecomInfra (EmpresaID, CodigoEstacao, Regiao, StatusConexao, TotalTrocasRealizadas, TrafegoDadosGbs, LatenciaMs)
    SELECT EmpresaID, 'PTY-MKT-01', 'Nasdaq Debt Feed', 'Online', 5000, 12.50, 2 FROM Empresas WHERE Ticker = 'PTY';
END
GO

-- =========================================================================
-- 2. RECOMPILAÇÃO COMPLETA DA VIEW (SEM ZEROS / EXCLUSÃO DE ZEROS)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_MarcacaoMercadoGlobal')
    DROP VIEW Vw_MarcacaoMercadoGlobal;
GO

CREATE VIEW Vw_MarcacaoMercadoGlobal AS
SELECT 
    E.Ticker AS [Ticker Ativo],
    E.NomeEmpresa AS [Operadora / Infra],
    E.Setor AS [Core Business],
    E.StatusOperacional AS [Situação de Mercado],
    COUNT(I.EstacaoID) AS [Nós de Rede Ativos] -- Conta todos os nós de Telecom e Capital inseridos
FROM Empresas E
INNER JOIN NioTelecomInfra I ON E.EmpresaID = I.EmpresaID -- INNER JOIN remove automaticamente quem tiver 0 nós
GROUP BY E.Ticker, E.NomeEmpresa, E.Setor, E.StatusOperacional;
GO

-- =========================================================================
-- 3. VALIDAÇÃO DO PAINEL ATUALIZADO (ZERO-FREE)
-- =========================================================================
SELECT * FROM Vw_MarcacaoMercadoGlobal ORDER BY [Nós de Rede Ativos] DESC;
GO

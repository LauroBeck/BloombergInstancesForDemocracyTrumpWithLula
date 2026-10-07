USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. GARANTE A EXISTÊNCIA DA TABELA DE HISTÓRICO DE COTAÇÕES
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HistoricoCotacoes]') AND type in (N'U'))
BEGIN
    CREATE TABLE HistoricoCotacoes (
        CotacaoID INT IDENTITY(1,1) PRIMARY KEY,
        EmpresaID INT NOT NULL,
        DataPreco DATETIME NOT NULL, 
        PrecoFechamento DECIMAL(10,4) NOT NULL,
        VariacaoPercentual DECIMAL(5,2) NOT NULL,
        VolumeNegociado BIGINT,
        CONSTRAINT FK_Cotacoes_Empresas FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID) ON DELETE CASCADE
    );
END
GO

-- =========================================================================
-- 2. GARANTE A EXISTÊNCIA DA TABELA DE CANAIS (CASO TENHA SIDO APAGADA)
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CanaisDistribuicao]') AND type in (N'U'))
BEGIN
    CREATE TABLE CanaisDistribuicao (
        CanalID INT IDENTITY(1,1) PRIMARY KEY,
        NomeCanal VARCHAR(50) NOT NULL UNIQUE,
        RegiaoCobertura VARCHAR(30) NOT NULL,
        TipoMidia VARCHAR(30) DEFAULT 'TV / Digital',
        StatusTransmissao VARCHAR(20) DEFAULT 'Ativo'
    );
END
GO

-- =========================================================================
-- 3. INSERÇÃO E ATUALIZAÇÃO DO TICKER REAL DA PIMCO (PTY - US$ 12.125)
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM Empresas WHERE Ticker = 'PTY')
BEGIN
    INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional)
    VALUES ('PTY', 'Pimco Corporate & Income Fund', 'Fundos / Renda Fixa', 'Regular');
END
GO

-- Grava a cotação exata mostrada na imagem da Nasdaq
INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
SELECT EmpresaID, '2026-07-01 13:46:00', 12.1250, 0.79, 1084643
FROM Empresas WHERE Ticker = 'PTY';
GO

-- =========================================================================
-- 4. RECOMPILAÇÃO DA STORED PROCEDURE DE MARCAÇÃO A MERCADO
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_MarcarMercadoPimco')
    DROP PROCEDURE Sp_MarcarMercadoPimco;
GO

CREATE PROCEDURE Sp_MarcarMercadoPimco
    @TickerFundo VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FundoID INT;
    DECLARE @UltimoPreco DECIMAL(10,4);
    DECLARE @Variacao DECIMAL(5,2);

    -- Captura com segurança a última cotação registrada
    SELECT TOP 1 
        @FundoID = EmpresaID, 
        @UltimoPreco = PrecoFechamento, 
        @Variacao = VariacaoPercentual 
    FROM HistoricoCotacoes 
    WHERE EmpresaID = (SELECT EmpresaID FROM Empresas WHERE Ticker = @TickerFundo)
    ORDER BY DataPreco DESC;

    IF (@FundoID IS NOT NULL)
    BEGIN
        SELECT 
            E.Ticker AS [Fundo Target],
            E.NomeEmpresa AS [Nome do Ativo],
            @UltimoPreco AS [Preco Nasdaq (US$)],
            @Variacao AS [Variacao (%)],
            CASE 
                WHEN @Variacao > 0 THEN 'VALORIZAÇÃO DO PORTFÓLIO'
                ELSE 'RETRAÇÃO DE MERCADO'
            END AS [Status de Performance]
        FROM Empresas E
        WHERE E.EmpresaID = @FundoID;
    END
    ELSE
    BEGIN
        PRINT 'Erro: Ativo de mercado não localizado.';
    END
END;
GO

-- =========================================================================
-- 5. EXECUÇÃO DO TESTE DE VALIDAÇÃO COM O ATIVO CORRIGIDO
-- =========================================================================
EXEC Sp_MarcarMercadoPimco @TickerFundo = 'PTY';
GO

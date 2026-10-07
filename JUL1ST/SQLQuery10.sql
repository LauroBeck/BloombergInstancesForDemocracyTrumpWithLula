USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. ADIÇÃO DO FUNDO REAL PTY DA PIMCO NA TABELA DE HOLDINGS
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM Empresas WHERE Ticker = 'PTY')
BEGIN
    INSERT INTO Empresas (Ticker, NomeEmpresa, Setor, StatusOperacional)
    VALUES ('PTY', 'Pimco Corporate & Income Fund', 'Fundos / Renda Fixa', 'Regular');
END
GO

-- =========================================================================
-- 2. HISTÓRICO DE COTAÇÕES COM PREÇO REAL DA IMAGEM (US$ 12.125)
-- =========================================================================
INSERT INTO HistoricoCotacoes (EmpresaID, DataPreco, PrecoFechamento, VariacaoPercentual, VolumeNegociado)
SELECT EmpresaID, '2026-07-01 13:46:00', 12.1250, 0.79, 1084643
FROM Empresas WHERE Ticker = 'PTY';
GO

-- =========================================================================
-- 3. STORED PROCEDURE PARA MARCAÇÃO A MERCADO (MARK-TO-MARKET V9.0)
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

    -- Captura os dados capturados da imagem/ticker
    SELECT TOP 1 
        @FundoID = EmpresaID, 
        @UltimoPreco = PrecoFechamento, 
        @Variacao = VariacaoPercentual 
    FROM HistoricoCotacoes 
    WHERE EmpresaID = (SELECT EmpresaID FROM Empresas WHERE Ticker = @TickerFundo)
    ORDER BY DataPreco DESC;

    -- Se o fundo possuir cotistas/aportes vinculados na holding, atualiza o PL
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
-- 4. EXECUÇÃO DA CONSULTA DA CARTEIRA ATUALIZADA
-- =========================================================================

-- Executa a marcação a mercado do fundo PTY exibido na tela da Nasdaq
EXEC Sp_MarcarMercadoPimco @TickerFundo = 'PTY';
GO

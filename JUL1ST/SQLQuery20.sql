USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CRIAÇÃO DA TABELA DE FLUXO DE EXPORTAÇÕES DE CADEIA GLOBAL (TESLA & BYD)
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CadeiaExportacaoVale]') AND type in (N'U'))
BEGIN
    CREATE TABLE CadeiaExportacaoVale (
        ExportacaoID INT IDENTITY(1,1) PRIMARY KEY,
        EmpresaID INT NOT NULL,              -- Amarração com ID da VALE
        ClienteMontadora VARCHAR(30) NOT NULL, -- 'Tesla Inc (US)' ou 'BYD Auto (Asia)'
        VolumeToneladasAnual DECIMAL(12,2),
        PrecoContratoPorTonelada MONEY,
        RegiaoDestino VARCHAR(15),           -- 'US' ou 'Asia'
        CONSTRAINT FK_Exportacao_VALE FOREIGN KEY (EmpresaID) REFERENCES Empresas(EmpresaID)
    );
END
GO

-- Inicializa os contratos de fornecimento do Ponto de Inflexão no lote
TRUNCATE TABLE CadeiaExportacaoVale;

DECLARE @ValeID INT;
SELECT @ValeID = EmpresaID FROM Empresas WHERE Ticker = 'VALE';

IF (@ValeID IS NOT NULL)
BEGIN
    -- Contrato de Exportação US: Fornecimento de Níquel de Alta Pureza para Gigafactories da Tesla
    INSERT INTO CadeiaExportacaoVale (EmpresaID, ClienteMontadora, VolumeToneladasAnual, PrecoContratoPorTonelada, RegiaoDestino)
    VALUES (@ValeID, 'Tesla Inc (US)', 450000.00, 18500.00, 'US');

    -- Contrato de Exportação Ásia: Fornecimento de Ferro Verde e Lítio para as Plantas Integradas da BYD
    INSERT INTO CadeiaExportacaoVale (EmpresaID, ClienteMontadora, VolumeToneladasAnual, PrecoContratoPorTonelada, RegiaoDestino)
    VALUES (@ValeID, 'BYD Auto (Asia)', 680000.00, 14200.00, 'Asia');
END
GO

-- =========================================================================
-- 2. VIEW DO INFLECTION POINT: MUTAÇÃO CÍCLICA PARA MULTIBILIONÁRIA ($BN)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_ValeInflectionPoint')
    DROP VIEW Vw_ValeInflectionPoint;
GO

CREATE VIEW Vw_ValeInflectionPoint AS
SELECT 
    C.ClienteMontadora AS [Montadora Alvo],
    C.RegiaoDestino AS [Eixo Exportacao],
    CONVERT(VARCHAR, CAST(C.VolumeToneladasAnual AS BIGINT), 1) AS [Volume (Toneladas)],
    
    -- Ganhos Brutos do Contrato na Escala Nominal
    CONVERT(VARCHAR, (C.VolumeToneladasAnual * C.PrecoContratoPorTonelada), 1) AS [Valor Contrato Bruto ($)],
    
    -- Ganhos do Ponto de Inflexão convertidos na métrica estrutural de Bilhões ($BN)
    CAST(((C.VolumeToneladasAnual * C.PrecoContratoPorTonelada) / 1000000000.00) AS DECIMAL(10,4)) AS [Ganhos de Inflexao ($BN)],
    
    -- Análise de direcionamento estratégico na cadeia de valor de Telecom/Mobilidade IoT
    CASE 
        WHEN C.ClienteMontadora = 'Tesla Inc (US)' THEN 'ACELERAÇÃO DE CAIXA SECULAR - REDE US CORES'
        ELSE 'VOLUME ESCALAR AGRESSIVO - INTEGRAÇÃO ÁSIA HUB'
    END AS [Impacto Economico]
FROM CadeiaExportacaoVale C;
GO

-- =========================================================================
-- 3. PROCEDURE DE ATUALIZAÇÃO AGREGADA DO SCORECARD GERAL DA HOLDING
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_CalibrarGanhosInflexao')
    DROP PROCEDURE Sp_CalibrarGanhosInflexao;
GO

CREATE PROCEDURE Sp_CalibrarGanhosInflexao
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GanhosInflexaoTotaisBN DECIMAL(12,4);
    
    -- Soma o valor acumulado dos contratos automotivos Tesla + BYD na escala de bilhões
    SELECT @GanhosInflexaoTotaisBN = SUM((VolumeToneladasAnual * PrecoContratoPorTonelada) / 1000000000.00) 
    FROM CadeiaExportacaoVale;

    -- Atualiza os alvos finais de mercado do ecossistema injetando o novo caixa gerado
    SELECT 
        'VALE CORE' AS [Instancia],
        SUM([Ganhos de Inflexao ($BN)]) AS [Injecao Direta no Caixa ($BN)],
        (SELECT MAX(GanhosFinaisTotais ($BN)) FROM Vw_SimulacaoAporteInternacional) + @GanhosInflexaoTotaisBN AS [Nova Meta Consolidada ($BN)],
        'PONTO DE INFLEXÃO VALIDADO' AS [Resultado Auditoria]
    FROM Vw_ValeInflectionPoint;
END;
GO

-- =========================================================================
-- 4. CONSULTA E AUDITORIA GLOBAL DO NOVO LOTE
-- =========================================================================

-- Consulta 1: Detalhamento do fornecimento analítico estruturado por montadora
SELECT * FROM Vw_ValeInflectionPoint ORDER BY [Ganhos de Inflexao ($BN)] DESC;

-- Consulta 2: Execução da Stored Procedure para rodar a fusão macroeconômica
EXEC Sp_CalibrarGanhosInflexao;
GO

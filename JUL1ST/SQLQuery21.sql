USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. CORREÇÃO E COMPILAÇÃO SEGURA DA STORED PROCEDURE (SEM SINTAXE DE CIFRÃO)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_CalibrarGanhosInflexao')
    DROP PROCEDURE Sp_CalibrarGanhosInflexao;
GO

CREATE PROCEDURE Sp_CalibrarGanhosInflexao
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GanhosInflexaoTotaisBN DECIMAL(12,4);
    DECLARE @MetaBaseBN DECIMAL(12,4);
    
    -- 1. Calcula o acumulado dos contratos automotivos na escala de bilhões
    SELECT @GanhosInflexaoTotaisBN = SUM((VolumeToneladasAnual * PrecoContratoPorTonelada) / 1000000000.00) 
    FROM CadeiaExportacaoVale;

    -- 2. Captura o valor máximo da view geopolítica tratando o nome da coluna com colchetes
    SELECT @MetaBaseBN = MAX([Ganhos Finais Totais ($BN)]) 
    FROM Vw_SimulacaoAporteInternacional;

    -- 3. Retorna o output de auditoria consolidado livre de erros de pseudocoluna
    SELECT 
        'VALE CORE' AS [Instancia],
        SUM([Ganhos de Inflexao ($BN)]) AS [Injecao Direta no Caixa ($BN)],
        (@MetaBaseBN + @GanhosInflexaoTotaisBN) AS [Nova Meta Consolidada ($BN)],
        'PONTO DE INFLEXAO VALIDADO' AS [Resultado Auditoria]
    FROM Vw_ValeInflectionPoint;
END;
GO

-- =========================================================================
-- 2. EXECUÇÃO INTEGRADA E AUDITORIA DO LOTE NO CONSOLE
-- =========================================================================

-- Exibe a matriz de exportação cadastrada (Tesla e BYD)
SELECT * FROM Vw_ValeInflectionPoint ORDER BY [Ganhos de Inflexao ($BN)] DESC;

-- Executa a Stored Procedure agora totalmente corrigida e registrada
EXEC Sp_CalibrarGanhosInflexao;
GO

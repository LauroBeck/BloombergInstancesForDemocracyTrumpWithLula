USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. RECOMPILAÇÃO SEGURA DA VIEW DE CENÁRIOS GEOPOLÍTICOS ATUALIZADA
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_SimulacaoAporteInternacional')
    DROP VIEW Vw_SimulacaoAporteInternacional;
GO

CREATE VIEW Vw_SimulacaoAporteInternacional AS
SELECT 
    S.OrigemSuporte AS [Origem do Capital],
    CONVERT(VARCHAR, S.AporteCapital, 1) AS [Aporte Expandido ($)],
    S.DestinoPrincipal AS [Ativo Alvo Core],
    
    -- Ganhos Totais recalculados: A VALE traz forte geração de caixa cíclico na simulação
    CASE 
        WHEN S.OrigemSuporte = 'Asia Sovereign' THEN (SELECT MAX(GanhosAcumuladosBN) FROM TraceProjecao36Meses) * 1.45
        ELSE (SELECT MAX(GanhosAcumuladosBN) FROM TraceProjecao36Meses) * 1.60 -- EU assume a liderança em $BN com a VALE
    END AS [Ganhos Finais Totais ($BN)],
    
    CASE 
        WHEN S.OrigemSuporte = 'Asia Sovereign' THEN 'DOMÍNIO DIGITAL E HARDWARE DA NIO ASIA'
        ELSE 'CADEIA GREEN METALS & COMPLIANCE INFRA COM VALE'
    END AS [Tese de Investimento]
FROM SuporteFinanceiroGlobal S;
GO

-- =========================================================================
-- 2. CONSULTA RETIFICADA DE DECISÃO GEOPOLÍTICA (ÁSIA VS EUROPA COM VALE)
-- =========================================================================
SELECT * FROM Vw_SimulacaoAporteInternacional ORDER BY [Ganhos Finais Totais ($BN)] DESC;
GO

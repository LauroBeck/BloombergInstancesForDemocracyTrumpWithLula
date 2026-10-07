USE [OiPIMCOAT&T];
GO

-- =========================================================================
-- 1. ESTRUTURA PARA INJEÇÃO DE INCENTIVO FINANCEIRO EXTERNO (CAPITAL INFLOW)
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SuporteFinanceiroGlobal]') AND type in (N'U'))
BEGIN
    CREATE TABLE SuporteFinanceiroGlobal (
        SuporteID INT IDENTITY(1,1) PRIMARY KEY,
        OrigemSuporte VARCHAR(30) NOT NULL,    -- 'Asia Sovereign' ou 'EU Green Infrastructure'
        AporteCapital MONEY NOT NULL,          -- Volume em bilhões
        MultiplicadorTelecom DECIMAL(4,2),     -- Impacto de eficiência de rede
        DestinoPrincipal VARCHAR(10)           -- Qual ativo receberá mais suporte (NIO, OIBR3, T)
    );
END
GO

-- Inicializa o suporte estratégico simulado (Aportes pesados de $BN no lote)
TRUNCATE TABLE SuporteFinanceiroGlobal;

INSERT INTO SuporteFinanceiroGlobal (OrigemSuporte, AporteCapital, MultiplicadorTelecom, DestinoPrincipal)
VALUES ('Asia Sovereign', 15000000000.00, 1.12, 'NIO'); -- Injeção de $15 Bilhões (Foco em Infra e Baterias)

INSERT INTO SuporteFinanceiroGlobal (OrigemSuporte, AporteCapital, MultiplicadorTelecom, DestinoPrincipal)
VALUES ('EU Green Infrastructure', 12000000000.00, 1.07, 'PTY'); -- Injeção de $12 Bilhões (Foco em Títulos Limpos/PIMCO)
GO

-- =========================================================================
-- 2. VIEW COMPARATIVA DE PERFORMANCE: SCENARIO A (ASIA) VS SCENARIO B (EU)
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vw_SimulacaoAporteInternacional')
    DROP VIEW Vw_SimulacaoAporteInternacional;
GO

CREATE VIEW Vw_SimulacaoAporteInternacional AS
SELECT 
    S.OrigemSuporte AS [Origem do Capital],
    CONVERT(VARCHAR, S.AporteCapital, 1) AS [Aporte Inicial ($)],
    S.DestinoPrincipal AS [Alvo Estratégico],
    
    -- Recalcula os nós projetados com base no suporte financeiro recebido
    CASE 
        WHEN S.OrigemSuporte = 'Asia Sovereign' THEN (SELECT COUNT(*) FROM NioTelecomInfra) * 3
        ELSE (SELECT COUNT(*) FROM NioTelecomInfra) * 2
    END AS [Nos Finais Estimados (36m)],
    
    -- Projeção de Ganhos em Bilhões ao final do ciclo de telecom de 36 meses
    CASE 
        WHEN S.OrigemSuporte = 'Asia Sovereign' THEN (SELECT MAX(GanhosAcumuladosBN) FROM TraceProjecao36Meses) * 1.45
        ELSE (SELECT MAX(GanhosAcumuladosBN) FROM TraceProjecao36Meses) * 1.22
    END AS [Ganhos Finais Totais ($BN)],
    
    -- Diagnóstico macroeconômico do incentivo
    CASE 
        WHEN S.OrigemSuporte = 'Asia Sovereign' THEN 'DOMÍNIO DE ESCALA GLOBAL E VELOCIDADE IOT'
        ELSE 'ESTABILIDADE PATRIMONIAL E ENERGIA LIMPA'
    END AS [Direcionamento Estratégico]
FROM SuporteFinanceiroGlobal S;
GO

-- =========================================================================
-- 3. EXECUÇÃO DA CONSULTA DE ARBITRAGEM DE CAPITAL GEOPOLÍTICO
-- =========================================================================
SELECT * FROM Vw_SimulacaoAporteInternacional ORDER BY [Ganhos Finais Totais ($BN)] DESC;
GO

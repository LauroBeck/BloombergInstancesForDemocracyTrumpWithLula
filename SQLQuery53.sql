USE AzureGovInfraDB;
GO

CREATE SCHEMA nasdaq;
GO

-- Tabela estrutural para mapear o impacto das vitórias de F1 na variação de ações de Big Techs
CREATE TABLE nasdaq.StockProjections (
    StockID INT IDENTITY(1,1) PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL,
    CompanyName VARCHAR(50) NOT NULL,
    CurrentPriceUSD DECIMAL(6,2) NOT NULL,
    BaseTargetUSD DECIMAL(6,2) NOT NULL,    -- Alvo sem o efeito catalisador das vitórias
    MercedesWinPremiumUSD DECIMAL(5,2) NOT NULL, -- Ganho de valuation por vitória da Mercedes (Azure/Petronas Synergy)
    TotalWinsProjected INT NOT NULL
);
GO

PRINT 'Injetando dados de calibração financeira (NASDAQ Close: Setembro 2026)...';

-- Inserção dos dados atuais da Microsoft (MSFT) e o impacto das vitórias de Kimi Antonelli (Mercedes)
INSERT INTO nasdaq.StockProjections (Ticker, CompanyName, CurrentPriceUSD, BaseTargetUSD, MercedesWinPremiumUSD, TotalWinsProjected)
VALUES ('MSFT', 'Microsoft Corporation', 495.63, 515.00, 0.55, 18);
GO

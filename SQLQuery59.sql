USE AzureGovInfraDB;
GO

CREATE SCHEMA bloomberg;
GO

-- Tabela de Análise Quantitativa de Opções e Contratos Futuros (Open Interest)
CREATE TABLE bloomberg.OpenInterestAnchors (
    AnchorID INT IDENTITY(1,1) PRIMARY KEY,
    AnchorName VARCHAR(50) NOT NULL,
    BloombergShow VARCHAR(50) NOT NULL,
    TargetTicker VARCHAR(10) NOT NULL,
    CallOptionStrikeUSD DECIMAL(6,2) NOT NULL, -- Preço de exercício alvo das opções de compra
    LiveOpenInterestContracts INT NOT NULL,     -- Contratos em aberto mantendo a liquidez do canal
    Volume24hInTrillions DECIMAL(5,4) NOT NULL  -- Volume financeiro derivativo movimentado em 24h
);
GO

PRINT 'Injetando a matriz de calibração do painel Bloomberg Surveillance...';

-- Âncora: Annmarie Hordern - Foco em Geopolítica e Infraestrutura Governamental (Azure Gov / Mercedes)
INSERT INTO bloomberg.OpenInterestAnchors VALUES ('Annmarie Hordern', 'Bloomberg Surveillance', 'MSFT', 515.00, 850000, 0.0421);

-- Âncora: Lisa Abramowicz - Foco em Macroeconomia Dinâmica e Breakouts de Teto Monetário ($525+ Target)
INSERT INTO bloomberg.OpenInterestAnchors VALUES ('Lisa Abramowicz', 'Bloomberg Open Interest', 'MSFT', 525.50, 1240000, 0.0652);

-- Âncora: Dani Burger - Foco em Alta Frequência, Volatilidade de Big Techs e Momentum de Grid na NASDAQ
INSERT INTO bloomberg.OpenInterestAnchors VALUES ('Dani Burger', 'Bloomberg Open Interest', 'MSFT', 525.50, 980000, 0.0518);
GO

-- Criar tabela de Empresas / Gestoras de Telecom e Investimentos
CREATE TABLE Emissores Telecom (
    EmissorID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoTicker VARCHAR(10) NOT NULL UNIQUE,
    NomeEmpresa VARCHAR(100) NOT NULL,
    Setor VARCHAR(50) NOT NULL
);

-- Criar tabela de Histórico de Preços e Movimentações de Mercado
CREATE TABLE HistoricoMercado (
    RegistroID INT IDENTITY(1,1) PRIMARY KEY,
    EmissorID INT FOREIGN KEY REFERENCES Emissores Telecom(EmissorID),
    DataRegistro DATE NOT NULL,
    PrecoFechamento DECIMAL(18,4) NOT NULL,
    VolumeNegociado BIGINT NOT NULL
);
GO

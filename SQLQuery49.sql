USE AzureGovInfraDB;
GO

CREATE SCHEMA chemistry;
GO

-- Tabela com as propriedades físico-químicas de resistência térmica de cada fornecedor
CREATE TABLE chemistry.FuelFluidSuppliers (
    SupplierName VARCHAR(50) PRIMARY KEY,
    TechnicalPartnerTeam VARCHAR(50) NOT NULL,
    ChemicalBaseType VARCHAR(50) NOT NULL,       -- Base molecular do óleo/combustível
    ViscosityIndex INT NOT NULL,                 -- Capacidade de manter a viscosidade sob alta pressão G
    EntropyResistanceRating DECIMAL(4,2) NOT NULL -- Grau de controle de dispersão de calor (0 a 10)
);
GO

PRINT 'Injetando a matriz de fornecedores químicos oficiais da F1...';

-- Petronas (Mercedes/Alpine/Williams): Soluções Fluid Technology Solutions com HVO Biofuels
INSERT INTO chemistry.FuelFluidSuppliers VALUES ('PETRONAS', 'MERCEDES / ALPINE', 'Fluid Technology Solutions (HVO)', 185, 9.45);

-- Mobil 1 / ExxonMobil (Red Bull/Racing Bulls): Alta estabilidade térmica e viscosidade linear
INSERT INTO chemistry.FuelFluidSuppliers VALUES ('EXXONMOBIL / MOBIL 1', 'RED BULL RACING', 'Polyalphaolefin (PAO) Synthetic', 190, 9.60);

-- Motul (McLaren): Especialistas em ésteres de altíssima performance para caixas e motores de rotação extrema
INSERT INTO chemistry.FuelFluidSuppliers VALUES ('MOTUL', 'MCLAREN MERCEDES', 'ESTEER Core Technology', 198, 9.85);

-- Shell (Ferrari): Combustíveis com base em hidrocarbonetos sustentáveis integrados
INSERT INTO chemistry.FuelFluidSuppliers VALUES ('SHELL', 'FERRARI', 'Gas-to-Liquid (GTL) Base', 182, 9.30);
GO

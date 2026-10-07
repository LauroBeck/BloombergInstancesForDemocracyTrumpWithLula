-- Criar tabela de Lojas/Filiais Zona Sul
CREATE TABLE Lojas_ZonaSul (
    LojaID INT IDENTITY(1,1) PRIMARY KEY,
    NomeFilial VARCHAR(50) NOT NULL UNIQUE
);

-- Criar tabela de Categorias de Vinho baseadas no catálogo
CREATE TABLE Categorias_Vinho (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,
    NomeCategoria VARCHAR(50) NOT NULL UNIQUE
);

-- Criar tabela de Fatos: Estimativa de Vendas Diárias
CREATE TABLE Vendas_Estimadas_Vinho (
    VendaID INT IDENTITY(1,1) PRIMARY KEY,
    LojaID INT FOREIGN KEY REFERENCES Lojas_ZonaSul(LojaID),
    CategoriaID INT FOREIGN KEY REFERENCES Categorias_Vinho(CategoriaID),
    DataRegistro DATE NOT NULL,
    QuantidadeGarrafas INT NOT NULL,
    FaturamentoEstimado DECIMAL(18,2) NOT NULL
);
GO

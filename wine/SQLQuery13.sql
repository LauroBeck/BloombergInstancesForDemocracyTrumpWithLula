-- 1. Estrutura de Tabelas (DDL Compatível)
CREATE TABLE Lojas_ZonaSul (
    LojaID INT IDENTITY(1,1) PRIMARY KEY,
    NomeFilial VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Categorias_Vinho (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,
    NomeCategoria VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Vendas_Estimadas_Vinho (
    VendaID INT IDENTITY(1,1) PRIMARY KEY,
    LojaID INT NOT NULL FOREIGN KEY REFERENCES Lojas_ZonaSul(LojaID),
    CategoriaID INT NOT NULL FOREIGN KEY REFERENCES Categorias_Vinho(CategoriaID),
    DataRegistro DATETIME NOT NULL, -- Corrigido de DATE para DATETIME
    QuantidadeGarrafas INT NOT NULL,
    FaturamentoEstimado DECIMAL(18,2) NOT NULL
);
GO

-- 2. Alimentando as Tabelas (DML)
INSERT INTO Lojas_ZonaSul (NomeFilial) VALUES ('Leblon');
INSERT INTO Lojas_ZonaSul (NomeFilial) VALUES ('Barra da Tijuca');
INSERT INTO Lojas_ZonaSul (NomeFilial) VALUES ('Lagoa');
INSERT INTO Lojas_ZonaSul (NomeFilial) VALUES ('Recreio dos Bandeirantes');
INSERT INTO Lojas_ZonaSul (NomeFilial) VALUES ('Ilha do Governador');

INSERT INTO Categorias_Vinho (NomeCategoria) VALUES ('Vinho Tinto Importado');
INSERT INTO Categorias_Vinho (NomeCategoria) VALUES ('Vinho Branco Importado');
INSERT INTO Categorias_Vinho (NomeCategoria) VALUES ('Oferta Leve Mais por Menos (Quinta das Amoras)');
GO

-- Carga de Dados usando bloco compatível com variáveis locais
DECLARE @idLeblon INT, @idBarra INT, @idLagoa INT, @idRecreio INT, @idIlha INT;
SELECT @idLeblon = LojaID FROM Lojas_ZonaSul WHERE NomeFilial = 'Leblon';
SELECT @idBarra  = LojaID FROM Lojas_ZonaSul WHERE NomeFilial = 'Barra da Tijuca';
SELECT @idLagoa  = LojaID FROM Lojas_ZonaSul WHERE NomeFilial = 'Lagoa';
SELECT @idRecreio = LojaID FROM Lojas_ZonaSul WHERE NomeFilial = 'Recreio dos Bandeirantes';
SELECT @idIlha    = LojaID FROM Lojas_ZonaSul WHERE NomeFilial = 'Ilha do Governador';

DECLARE @idTinto INT, @idBranco INT, @idCombo INT;
SELECT @idTinto  = CategoriaID FROM Categorias_Vinho WHERE NomeCategoria = 'Vinho Tinto Importado';
SELECT @idBranco = CategoriaID FROM Categorias_Vinho WHERE NomeCategoria = 'Vinho Branco Importado';
SELECT @idCombo  = CategoriaID FROM Categorias_Vinho WHERE NomeCategoria = 'Oferta Leve Mais por Menos (Quinta das Amoras)';

-- Inserções detalhadas linha por linha para máxima compatibilidade
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idLeblon,  @idTinto,  '20260723', 120, 4795.20);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idLeblon,  @idBranco, '20260723', 85,  5049.00);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idLeblon,  @idCombo,  '20260723', 160, 9028.80);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idBarra,   @idTinto,  '20260723', 140, 5594.40);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idBarra,   @idBranco, '20260723', 90,  5346.00);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idBarra,   @idCombo,  '20260723', 200, 11286.00);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idLagoa,   @idTinto,  '20260723', 70,  2797.20);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idLagoa,   @idCombo,  '20260723', 95,  5360.85);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idRecreio, @idTinto,  '20260723', 95,  3796.20);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idRecreio, @idCombo,  '20260723', 130, 7335.90);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idIlha,    @idTinto,  '20260723', 45,  1798.20);
INSERT INTO Vendas_Estimadas_Vinho VALUES (@idIlha,    @idCombo,  '20260723', 60,  3385.80);
GO

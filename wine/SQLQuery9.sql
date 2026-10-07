-- Criar tabela física para armazenar o resumo diário consolidado
CREATE TABLE Resumo_Fechamento_Diario (
    FechamentoID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoTicker VARCHAR(10) NOT NULL,
    DataRegistro DATETIME NOT NULL,
    VariacaoPercentual DECIMAL(10,2) NOT NULL,
    StatusAtivo VARCHAR(20) NOT NULL
);
GO

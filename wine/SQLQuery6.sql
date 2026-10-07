-- Início da transação para garantir que tudo seja executado de forma segura e atômica
BEGIN TRANSACTION;

-- 1. Declaração de Variáveis para armazenar os IDs mapeados dos emissores
DECLARE @IdPimco INT, @IdNio INT, @IdAtt INT, @IdClaro INT, @IdVerizon INT;

-- Captura dos IDs com base nos tickers cadastrados na tabela de emissores
SELECT @IdPimco   = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'PIMCO';
SELECT @IdNio     = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'NIO';
SELECT @IdAtt     = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'T';
SELECT @IdClaro   = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'CLARO';
SELECT @IdVerizon = EmissorID FROM Emissores_Telecom WHERE CodigoTicker = 'VZ';

-- 2. Atualização Retroativa dos valores bases para o Dia 22 (Equilíbrio de Moeda em USD)
-- Corrigindo a distorção inicial para que o cálculo percentual do dia 23 reflita a realidade física de mercado
UPDATE HistoricoMercado SET PrecoFechamento = 15.4500 WHERE EmissorID = @IdPimco   AND DataRegistro = '20260722';
UPDATE HistoricoMercado SET PrecoFechamento = 4.6700  WHERE EmissorID = @IdNio     AND DataRegistro = '20260722'; -- Preço real anterior da NIO Inc.
UPDATE HistoricoMercado SET PrecoFechamento = 23.0400 WHERE EmissorID = @IdAtt     AND DataRegistro = '20260722'; -- Preço real anterior da AT&T
UPDATE HistoricoMercado SET PrecoFechamento = 26.1000 WHERE EmissorID = @IdClaro   AND DataRegistro = '20260722'; -- Preço real anterior da América Móvil
UPDATE HistoricoMercado SET PrecoFechamento = 44.2900 WHERE EmissorID = @IdVerizon AND DataRegistro = '20260722'; -- Preço real anterior da Verizon

-- 3. Criação de uma Tabela Temporária estruturada para receber os novos preços oficiais do fechamento do Dia 23
CREATE TABLE #PrecosOficiaisFechamento (
    IDDoEmissor INT,
    NovoPrecoFechamento DECIMAL(18,4)
);

-- Carga dos dados de mercado reais do dia 23 de Julho de 2026
INSERT INTO #PrecosOficiaisFechamento (IDDoEmissor, NovoPrecoFechamento) VALUES (@IdPimco,   15.6000); 
INSERT INTO #PrecosOficiaisFechamento (IDDoEmissor, NovoPrecoFechamento) VALUES (@IdNio,     4.6150);  -- Fechamento real da NIO Inc
INSERT INTO #PrecosOficiaisFechamento (IDDoEmissor, NovoPrecoFechamento) VALUES (@IdAtt,     22.8300); -- Fechamento real da AT&T na NYSE
INSERT INTO #PrecosOficiaisFechamento (IDDoEmissor, NovoPrecoFechamento) VALUES (@IdClaro,   22.8200); -- Fechamento real da América Móvil (Claro)
INSERT INTO #PrecosOficiaisFechamento (IDDoEmissor, NovoPrecoFechamento) VALUES (@IdVerizon, 43.9950); -- Fechamento real da Verizon Communications

-- 4. Comando de UPDATE com junção (JOIN) aplicando as alterações em massa no banco de dados
UPDATE hm
SET hm.PrecoFechamento = f.NovoPrecoFechamento
FROM HistoricoMercado hm
INNER JOIN #PrecosOficiaisFechamento f ON hm.EmissorID = f.IDDoEmissor
WHERE hm.DataRegistro = '20260723'; -- Alvo restrito para manter a integridade temporal

-- Limpeza e desalocação da tabela temporária da memória do servidor
DROP TABLE #PrecosOficiaisFechamento;

-- Salva definitivamente todas as atualizações no banco de dados
COMMIT TRANSACTION;
GO

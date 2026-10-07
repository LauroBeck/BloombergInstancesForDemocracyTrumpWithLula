INSERT INTO Resumo_Fechamento_Diario (CodigoTicker, DataRegistro, VariacaoPercentual, StatusAtivo)
SELECT 
    CodigoTicker,
    DataRegistro,
    VariacaoPercentualDiaria,
    CASE 
        WHEN VariacaoPercentualDiaria > 0 THEN 'Alta'
        WHEN VariacaoPercentualDiaria < 0 THEN 'Baixa'
        ELSE 'Estável'
    END
FROM Vw_Performance_Telecom_Fundos
WHERE DataRegistro = '20260723';
GO

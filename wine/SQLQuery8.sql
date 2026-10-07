SELECT TOP 1 NomeEmpresa, CodigoTicker, VariacaoPercentualDiaria 
FROM Vw_Performance_Telecom_Fundos
WHERE DataRegistro = '20260723'
ORDER BY VariacaoPercentualDiaria DESC;

CREATE VIEW Vw_Performance_Telecom_Fundos AS
SELECT 
    e.NomeEmpresa,
    e.CodigoTicker,
    e.Setor,
    h1.DataRegistro,
    h1.PrecoFechamento,
    h1.VolumeNegociado,
    CASE 
        WHEN h2.PrecoFechamento IS NULL THEN 0.00
        ELSE CAST(((h1.PrecoFechamento - h2.PrecoFechamento) / h2.PrecoFechamento) * 100 AS DECIMAL(10,2))
    END AS VariacaoPercentualDiaria
FROM HistoricoMercado h1
INNER JOIN Emissores_Telecom e ON h1.EmissorID = e.EmissorID
LEFT JOIN HistoricoMercado h2 ON h1.EmissorID = h2.EmissorID 
                             AND h2.DataRegistro = DATEADD(day, -1, h1.DataRegistro);
GO

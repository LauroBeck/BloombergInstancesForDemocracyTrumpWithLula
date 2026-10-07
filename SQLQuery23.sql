/* =====================================================================
   Target: SSAS Multidimensional Cube (Calculated Members Engine)
   Syntax: MDX (Multi-Dimensional eXpressions)
   Focus: Dynamic Trillion Dividers & Non-Additive Profit Margins
   ===================================================================== */

-- 1. Formatador Dinâmico de Faturamento em Trilhões de Dólares
CREATE MEMBER CURRENTCUBE.[Measures].[Faturamento Geral (Trilhoes USD)]
AS
    [Measures].[Total Revenue Generated] / 1000000000000,
    FORMAT_STRING = "$#,##0.000;($#,##0.000);-",
    ASSOCIATED_MEASURE_GROUP = "Fact Regional Gains 55Months",
    DISPLAY_FOLDER = "Métricas de Performance Global";

-- 2. Formatador Dinâmico de Lucro Líquido em Trilhões de Dólares
CREATE MEMBER CURRENTCUBE.[Measures].[Lucro Liquido (Trilhoes USD)]
AS
    [Measures].[Net Profit Gains] / 1000000000000,
    FORMAT_STRING = "$#,##0.000;($#,##0.000);-",
    ASSOCIATED_MEASURE_GROUP = "Fact Regional Gains 55Months",
    DISPLAY_FOLDER = "Métricas de Performance Global";

-- 3. Margem Dinâmica Não-Aditiva (Garante o cálculo correto em qualquer nível de hierarquia)
CREATE MEMBER CURRENTCUBE.[Measures].[Margem de Lucro Dinamica %]
AS
    IIF(
        [Measures].[Total Revenue Generated] = 0 OR ISEMPTY([Measures].[Total Revenue Generated]),
        NULL,
        [Measures].[Net Profit Gains] / [Measures].[Total Revenue Generated]
    ),
    FORMAT_STRING = "Percent",
    ASSOCIATED_MEASURE_GROUP = "Fact Regional Gains 55Months",
    DISPLAY_FOLDER = "Métricas de Performance Global";

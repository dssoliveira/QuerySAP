WITH REFERENCIAS AS
(
    SELECT 'Cummins NTA855' AS "Motor", 'Combustível' AS "Categoria", 2 AS "Qtd_Kit", 'FF1001' AS "Referencia" FROM DUMMY
    UNION ALL SELECT 'Cummins NTA855', 'Lubrificante', 1, 'LF9009' FROM DUMMY
    UNION ALL SELECT 'Cummins NTA855', 'Filtro água', 1, 'WF2175' FROM DUMMY

    UNION ALL SELECT 'Scania DC13 072A', 'Combustível', 1, '1873018' FROM DUMMY
    UNION ALL SELECT 'Scania DC13 072A', 'Racor', 1, '1518512' FROM DUMMY
    UNION ALL SELECT 'Scania DC13 072A', 'Lubrificante', 1, '2625884' FROM DUMMY
    UNION ALL SELECT 'Scania DC13 072A', 'Anel rotativo', 1, '1769799' FROM DUMMY
    UNION ALL SELECT 'Scania DC13 072A', 'Anel rotativo', 1, '1769800' FROM DUMMY
    UNION ALL SELECT 'Scania DC13 072A', 'Placa limpeza', 1, '2153635' FROM DUMMY

    UNION ALL SELECT 'Scania DC16 049A', 'Combustível', 1, '1873018' FROM DUMMY
    UNION ALL SELECT 'Scania DC16 049A', 'Racor', 1, '1518512' FROM DUMMY
    UNION ALL SELECT 'Scania DC16 049A', 'Lubrificante', 1, '2057893' FROM DUMMY
    UNION ALL SELECT 'Scania DC16 049A', 'Anel rotativo', 1, '1769799' FROM DUMMY
    UNION ALL SELECT 'Scania DC16 049A', 'Anel rotativo', 1, '1769800' FROM DUMMY
    UNION ALL SELECT 'Scania DC16 049A', 'Placa limpeza', 1, '2153635' FROM DUMMY

    UNION ALL SELECT 'Mercedes OM471', 'Combustível', 1, 'A4700900055' FROM DUMMY
    UNION ALL SELECT 'Mercedes OM471', 'Racor', 1, 'A4700908252' FROM DUMMY
    UNION ALL SELECT 'Mercedes OM471', 'Lubrificante', 1, 'A4711800209' FROM DUMMY
),

ITENS_SAP AS
(
    SELECT
        I."ItemCode",
        I."ItemName",
        I."FrgnName",
        I."OnHand",
        I."IsCommited",
        I."OnOrder",
        I."AvgPrice",
        I."LastPurPrc",
        I."LastPurCur",
        I."LastPurDat",
        I."DfltWH",

        P."Price" AS "Preco_Lista_01",
        P."Currency" AS "Moeda_Preco_Lista_01",

        C."Substitute" AS "Codigo_Alternativo"

    FROM OITM I

    LEFT JOIN ITM1 P
        ON P."ItemCode" = I."ItemCode"
       AND P."PriceList" = 1

    LEFT JOIN OSCN C
        ON C."ItemCode" = I."ItemCode"
)

SELECT
    R."Motor",
    R."Categoria",
    R."Qtd_Kit",
    R."Referencia" AS "Referencia_Fabricante",

    CASE
        WHEN I."ItemCode" IS NULL
        THEN 'Não localizado no cadastro SAP'

        WHEN UPPER(I."ItemCode") = UPPER(R."Referencia")
        THEN 'Código do item coincide exatamente'

        WHEN UPPER(IFNULL(I."Codigo_Alternativo", '')) = UPPER(R."Referencia")
        THEN 'Código alternativo coincide exatamente'

        WHEN UPPER(I."ItemName") LIKE '%' || UPPER(R."Referencia") || '%'
        THEN 'Referência localizada na descrição'

        WHEN UPPER(IFNULL(I."FrgnName", '')) LIKE '%' || UPPER(R."Referencia") || '%'
        THEN 'Referência localizada no nome estrangeiro'

        ELSE 'Correlação parcial — validar cadastro'
    END AS "Status_Correlacao",

    I."ItemCode" AS "Codigo_Item_SAP",
    I."ItemName" AS "Descricao_Item_SAP",
    I."Codigo_Alternativo",
    I."DfltWH" AS "Deposito_Padrao",

    I."OnHand" AS "Estoque_Atual",
    I."IsCommited" AS "Estoque_Comprometido",
    I."OnOrder" AS "Estoque_Em_Pedido",
    I."OnHand" - I."IsCommited" AS "Estoque_Disponivel",

    I."AvgPrice" AS "Custo_Medio",
    I."LastPurPrc" AS "Ultimo_Preco_Compra",
    I."LastPurCur" AS "Moeda_Ultima_Compra",
    I."LastPurDat" AS "Data_Ultima_Compra",

    I."Preco_Lista_01",
    I."Moeda_Preco_Lista_01",

    R."Qtd_Kit" * IFNULL(I."Preco_Lista_01", 0) AS "Valor_Kit_Preco_Lista",
    R."Qtd_Kit" * IFNULL(I."AvgPrice", 0) AS "Custo_Kit_Medio"

FROM REFERENCIAS R

LEFT JOIN ITENS_SAP I
    ON UPPER(I."ItemCode") = UPPER(R."Referencia")
    OR UPPER(IFNULL(I."Codigo_Alternativo", '')) = UPPER(R."Referencia")
    OR UPPER(I."ItemName") LIKE '%' || UPPER(R."Referencia") || '%'
    OR UPPER(IFNULL(I."FrgnName", '')) LIKE '%' || UPPER(R."Referencia") || '%'

ORDER BY
    R."Motor",
    R."Categoria",
    R."Referencia",
    I."ItemCode";

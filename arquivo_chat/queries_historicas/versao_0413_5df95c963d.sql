WITH REFERENCIAS AS
(
    SELECT
        'Cummins NTA855' AS "Motor",
        'Combustível' AS "Categoria",
        2 AS "Qtd_Kit",
        'FS1001' AS "Referencia"
    FROM DUMMY

    UNION ALL
    SELECT 'Cummins NTA855', 'Lubrificante', 1, 'LF9009'
    FROM DUMMY

    UNION ALL
    SELECT 'Cummins NTA855', 'Filtro água', 1, 'WF2176'
    FROM DUMMY

    UNION ALL
    SELECT
        'Cummins NTA855',
        'Óleo lubrificante',
        NULL,
        'OLEO LUBRIFICANTE TURBO 15W40CI4 LITRO - VALVOLINE'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC13 072A', 'Combustível', 1, '1873018'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC13 072A', 'Racor', 1, '1518512'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC13 072A', 'Lubrificante', 1, '2625884'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC13 072A', 'Anel rotativo', 1, '1769799'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC13 072A', 'Anel rotativo', 1, '1769800'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC13 072A', 'Placa limpeza', 1, '2153365'
    FROM DUMMY

    UNION ALL
    SELECT
        'Scania DC13 072A',
        'Óleo lubrificante',
        NULL,
        'OLEO LUBRIFICANTE TURBO 15W40CI4 LITRO - VALVOLINE'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC16 049A', 'Combustível', 1, '1873018'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC16 049A', 'Racor', 1, '1518512'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC16 049A', 'Lubrificante', 1, '2057893'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC16 049A', 'Anel rotativo', 1, '1769799'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC16 049A', 'Anel rotativo', 1, '1769800'
    FROM DUMMY

    UNION ALL
    SELECT 'Scania DC16 049A', 'Placa limpeza', 1, '2153365'
    FROM DUMMY

    UNION ALL
    SELECT
        'Scania DC16 049A',
        'Óleo lubrificante',
        NULL,
        'OLEO LUBRIFICANTE TURBO 15W40CI4 LITRO - VALVOLINE'
    FROM DUMMY

    UNION ALL
    SELECT 'Mercedes OM471', 'Combustível', 1, 'A4700900055'
    FROM DUMMY

    UNION ALL
    SELECT 'Mercedes OM471', 'Racor', 1, 'A4700908252'
    FROM DUMMY

    UNION ALL
    SELECT 'Mercedes OM471', 'Lubrificante', 1, 'A4711800209'
    FROM DUMMY

    UNION ALL
    SELECT
        'Mercedes OM471',
        'Óleo lubrificante',
        NULL,
        'OLEO LUBRIFICANTE TURBO 15W40CI4 LITRO - VALVOLINE'
    FROM DUMMY
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

        /* Remove espaços, hífens e barras para pesquisar o óleo */
        REPLACE(
            REPLACE(
                REPLACE(
                    UPPER(IFNULL(I."ItemName", '')),
                    ' ',
                    ''
                ),
                '-',
                ''
            ),
            '/',
            ''
        ) AS "Descricao_Normalizada"

    FROM OITM I

    LEFT JOIN ITM1 P
        ON P."ItemCode" = I."ItemCode"
       AND P."PriceList" = 1
),

CORRELACOES AS
(
    SELECT
        R."Motor",
        R."Categoria",
        R."Qtd_Kit",
        R."Referencia",
        I.*,

        CASE
            WHEN I."ItemCode" IS NULL
            THEN 'Não localizado no cadastro SAP'

            WHEN UPPER(I."ItemCode") = UPPER(R."Referencia")
            THEN 'Código do item coincide exatamente'

            WHEN EXISTS
            (
                SELECT 1
                FROM OSCN C
                WHERE C."ItemCode" = I."ItemCode"
                  AND UPPER(IFNULL(C."Substitute", ''))
                      = UPPER(R."Referencia")
            )
            THEN 'Código alternativo coincide exatamente'

            WHEN R."Categoria" = 'Óleo lubrificante'
            THEN 'Óleo localizado pela descrição - validar especificação e unidade'

            WHEN UPPER(IFNULL(I."ItemName", ''))
                 LIKE '%' || UPPER(R."Referencia") || '%'
            THEN 'Referência localizada na descrição'

            WHEN UPPER(IFNULL(I."FrgnName", ''))
                 LIKE '%' || UPPER(R."Referencia") || '%'
            THEN 'Referência localizada no nome estrangeiro'

            ELSE 'Correlação parcial - validar cadastro'
        END AS "Status_Correlacao"

    FROM REFERENCIAS R

    LEFT JOIN ITENS_SAP I
        ON
        (
            R."Categoria" <> 'Óleo lubrificante'
            AND
            (
                UPPER(I."ItemCode") = UPPER(R."Referencia")

                OR UPPER(IFNULL(I."ItemName", ''))
                   LIKE '%' || UPPER(R."Referencia") || '%'

                OR UPPER(IFNULL(I."FrgnName", ''))
                   LIKE '%' || UPPER(R."Referencia") || '%'

                OR EXISTS
                (
                    SELECT 1
                    FROM OSCN C
                    WHERE C."ItemCode" = I."ItemCode"
                      AND UPPER(IFNULL(C."Substitute", ''))
                          = UPPER(R."Referencia")
                )
            )
        )
        OR
        (
            R."Categoria" = 'Óleo lubrificante'
            AND I."Descricao_Normalizada" LIKE '%VALVOLINE%'
            AND I."Descricao_Normalizada" LIKE '%15W40%'
            AND I."Descricao_Normalizada" LIKE '%CI4%'
            AND I."Descricao_Normalizada" LIKE '%LITRO%'
            AND I."Descricao_Normalizada" NOT LIKE '%DUPLICADO%'
        )
)

SELECT
    C."Motor",
    C."Categoria",
    C."Qtd_Kit",
    C."Referencia" AS "Referencia_Pesquisada",
    C."Status_Correlacao",

    C."ItemCode" AS "Codigo_Item_SAP",
    C."ItemName" AS "Descricao_Item_SAP",

    /* Código alternativo correspondente à referência pesquisada */
    (
        SELECT MIN(A."Substitute")
        FROM OSCN A
        WHERE A."ItemCode" = C."ItemCode"
          AND UPPER(IFNULL(A."Substitute", ''))
              = UPPER(C."Referencia")
    ) AS "Codigo_Alternativo",

    C."DfltWH" AS "Deposito_Padrao",

    C."OnHand" AS "Estoque_Atual",
    C."IsCommited" AS "Estoque_Comprometido",
    C."OnOrder" AS "Estoque_Em_Pedido",
    C."OnHand" - C."IsCommited" AS "Estoque_Disponivel",

    C."AvgPrice" AS "Custo_Medio",
    C."LastPurPrc" AS "Ultimo_Preco_Compra",
    C."LastPurCur" AS "Moeda_Ultima_Compra",
    C."LastPurDat" AS "Data_Ultima_Compra",

    C."Preco_Lista_01",
    C."Moeda_Preco_Lista_01",

    C."Qtd_Kit" * C."Preco_Lista_01" AS "Valor_Kit_Preco_Lista",
    C."Qtd_Kit" * C."AvgPrice" AS "Custo_Kit_Medio"

FROM CORRELACOES C

ORDER BY
    C."Motor",
    C."Categoria",
    C."Referencia",
    C."ItemCode";

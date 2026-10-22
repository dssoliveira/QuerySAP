SELECT
    T0."DocEntry" AS "Num_Interno_NF",

    T0."DocNum" AS "Num_Documento_SAP",

    T0."Serial" AS "Numero_Nota_Fiscal",

    T0."DocDate" AS "Data_Emissao",

    T0."CardCode" AS "Cod_Cliente",

    T0."CardName" AS "Nome_Cliente",

    PV."Pedido_Venda" AS "Pedido_Venda",

    CASE
        WHEN PV."Pedido_Venda" IS NULL
        THEN 'Validar: NF sem vinculo com Pedido de Venda'
        ELSE 'NF vinculada ao Pedido de Venda'
    END AS "Status_Vinculo_Pedido",

    CC."Departamento" AS "Departamento",

    T0."DocTotal" AS "Valor_NFe_ML"

FROM OINV T0

LEFT JOIN (
    SELECT
        X."DocEntryNF",
        STRING_AGG(X."PedidoVendaTexto", ', ') AS "Pedido_Venda"
    FROM (
        SELECT DISTINCT
            I1."DocEntry" AS "DocEntryNF",
            TO_VARCHAR(O0."DocNum") AS "PedidoVendaTexto"
        FROM INV1 I1

        INNER JOIN RDR1 R1
            ON I1."BaseType" = 17
            AND I1."BaseEntry" = R1."DocEntry"
            AND I1."BaseLine" = R1."LineNum"

        INNER JOIN ORDR O0
            ON O0."DocEntry" = R1."DocEntry"
    ) X
    GROUP BY
        X."DocEntryNF"
) PV
    ON PV."DocEntryNF" = T0."DocEntry"

LEFT JOIN (
    SELECT
        Y."DocEntryNF",
        STRING_AGG(Y."DepartamentoTexto", ', ') AS "Departamento"
    FROM (
        SELECT DISTINCT
            I1."DocEntry" AS "DocEntryNF",
            IFNULL(I1."OcrCode", R1."OcrCode") AS "DepartamentoTexto"
        FROM INV1 I1

        LEFT JOIN RDR1 R1
            ON I1."BaseType" = 17
            AND I1."BaseEntry" = R1."DocEntry"
            AND I1."BaseLine" = R1."LineNum"

        WHERE
            IFNULL(I1."OcrCode", R1."OcrCode") IS NOT NULL
    ) Y
    GROUP BY
        Y."DocEntryNF"
) CC
    ON CC."DocEntryNF" = T0."DocEntry"

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'

    AND T0."CANCELED" = 'N'

    AND CC."Departamento" IS NOT NULL

    AND NOT EXISTS (
        SELECT
            1
        FROM INV1 E
        WHERE
            E."DocEntry" = T0."DocEntry"
            AND E."BaseType" = 15
    )

ORDER BY
    T0."DocDate" DESC,
    T0."DocNum";

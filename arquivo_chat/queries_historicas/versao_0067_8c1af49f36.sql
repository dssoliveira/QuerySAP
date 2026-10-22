LEFT JOIN (
    SELECT
        R1."DocEntry",
        R1."OcrCode",

        MIN(R1."Dscription") AS "Dscription",

        ROUND(
            SUM(
                R1."LineTotal" / NULLIF(R1."Quantity", 0)
            ),
            2
        ) AS "ValorMensalCentroCusto",

        MAX(R1."Quantity") AS "QuantidadeParcelas",

        ROUND(
            SUM(R1."LineTotal"),
            2
        ) AS "ValorTotalCentroCusto",

        COUNT(*) AS "QtdLinhasCentroCusto",

        CASE
            WHEN MIN(R1."Quantity") <> MAX(R1."Quantity")
            THEN 'Validar parcelas nas linhas do pedido'
            ELSE ''
        END AS "AlertaLinhaPedido"

    FROM RDR1 R1

    WHERE
        R1."OcrCode" IN ('GERADOR', 'NOBREAK')

    GROUP BY
        R1."DocEntry",
        R1."OcrCode"
) T2
    ON T2."DocEntry" = T1."DocEntry"

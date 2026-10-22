SELECT

    COUNT(DISTINCT T0."ContractID")          AS "Quantidade Contratos",

    ROUND(
        SUM(
            T2."LineTotal" / NULLIF(T2."Quantity",0)
        ),
        2
    )                                        AS "Valor Mensal Total",

    ROUND(
        SUM(T2."LineTotal"),
        2
    )                                        AS "Valor Total Contratos",

    ROUND(
        SUM(
            CASE

                WHEN T0."EndDate" < CURRENT_DATE
                THEN 0

                WHEN T2."Quantity" = 1
                THEN T2."LineTotal"

                ELSE
                    (
                        T2."LineTotal"
                        /
                        NULLIF(T2."Quantity",0)
                    )
                    *
                    CASE

                        WHEN YEAR(T0."EndDate") = YEAR(CURRENT_DATE)
                        THEN
                            CASE
                                WHEN
                                    (
                                        MONTH(T0."EndDate")
                                        - MONTH(CURRENT_DATE)
                                    ) <= 0
                                THEN 1

                                ELSE
                                    (
                                        MONTH(T0."EndDate")
                                        - MONTH(CURRENT_DATE)
                                    )
                            END

                        ELSE
                            (
                                12 - MONTH(CURRENT_DATE)
                            )
                    END
            END
        ),
        2
    )                                        AS "Previsto Ate Final Ano"

FROM OCTR T0

LEFT JOIN ORDR T1
ON T1."DocEntry" = TO_INTEGER(
    REPLACE(
        SUBSTRING(
            T0."Descriptio",
            LOCATE(T0."Descriptio", 'Venda ')
        ),
        'Venda ',
        ''
    )
)

LEFT JOIN RDR1 T2
ON T1."DocEntry" = T2."DocEntry"
AND T2."LineNum" = 0

WHERE
    T0."Status" = 'A'
    AND T0."Descriptio" LIKE '%Pedido de Venda%'
    AND T2."OcrCode" = '[%0]'

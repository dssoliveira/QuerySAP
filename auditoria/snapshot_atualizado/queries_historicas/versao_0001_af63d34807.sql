SELECT
    COUNT(DISTINCT T0."ContractID")
        AS "Quantidade Contratos",

    ROUND(
        SUM(
            ROUND(
                T2."LineTotal" / NULLIF(T2."Quantity", 0),
                2
            )
        ),
        2
    ) AS "Valor Mensal Total",

    ROUND(
        SUM(
            ROUND(T2."LineTotal", 2)
        ),
        2
    ) AS "Valor Total Contratos",

    ROUND(
        SUM(
            ROUND(
                CASE
                    WHEN T0."EndDate" < CURRENT_DATE
                        THEN 0

                    WHEN T2."Quantity" = 1
                        THEN T2."LineTotal"

                    ELSE
                        (
                            T2."LineTotal"
                            / NULLIF(T2."Quantity", 0)
                        )
                        *
                        CASE
                            WHEN YEAR(T0."EndDate") = YEAR(CURRENT_DATE)
                            THEN
                                CASE
                                    WHEN (
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
                                12 - MONTH(CURRENT_DATE)
                        END
                END,
                2
            )
        ),
        2
    ) AS "Previsto Ate Final Ano"

FROM OCTR T0

LEFT JOIN (
    SELECT
        X."U_ContractID",
        MAX(
            TO_INTEGER(X."U_DocEntry")
        ) AS "DocEntry"
    FROM "@LOC1_DOC" X
    WHERE X."U_DocTypeNum" = 17
    GROUP BY
        X."U_ContractID"
) TL
    ON TL."U_ContractID" = T0."ContractID"

LEFT JOIN ORDR T1
    ON T1."DocEntry" = TL."DocEntry"

LEFT JOIN RDR1 T2
    ON T2."DocEntry" = T1."DocEntry"
    AND T2."LineNum" = 0

WHERE
    T0."Status" = 'A'
    AND T2."OcrCode" = '[%0]'

LEFT JOIN (
    SELECT
        P."FIPROJECT",
        P."AbsEntry",
        P."DocNum",
        P."NAME"
    FROM (
        SELECT
            OPMG."FIPROJECT",
            OPMG."AbsEntry",
            OPMG."DocNum",
            OPMG."NAME",

            ROW_NUMBER() OVER (
                PARTITION BY OPMG."FIPROJECT"
                ORDER BY
                    OPMG."AbsEntry" DESC
            ) AS "LinhaControle"

        FROM OPMG

        WHERE
            IFNULL(OPMG."FIPROJECT", '') <> ''
    ) P

    WHERE
        P."LinhaControle" = 1
) PRJ
    ON PRJ."FIPROJECT" = T0."Project"

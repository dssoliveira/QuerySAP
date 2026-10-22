ROUND(
        IFNULL(
            (
                SELECT
                    SUM(
                        CASE
                            WHEN IFNULL(T2."Quantity", 0) > 0
                             AND YEAR(M."Mes") = YEAR(CURRENT_DATE)
                             AND M."Mes" >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                             AND M."Mes"
                                 BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                                     AND ADD_MONTHS(
                                            ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                            TO_INTEGER(T2."Quantity") - 1
                                         )
                            THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                            ELSE 0
                        END
                    )
                FROM (
                    SELECT TO_DATE('2026-01-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-02-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-03-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-04-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-05-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-06-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-07-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-08-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-09-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-10-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-11-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2026-12-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-01-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-02-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-03-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-04-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-05-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-06-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-07-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-08-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-09-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-10-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-11-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY UNION ALL
                    SELECT TO_DATE('2027-12-01', 'YYYY-MM-DD') AS "Mes" FROM DUMMY
                ) M
            ),
            0
        ),
        2
    ) AS "A Faturar Ate 12 Ano Atual",

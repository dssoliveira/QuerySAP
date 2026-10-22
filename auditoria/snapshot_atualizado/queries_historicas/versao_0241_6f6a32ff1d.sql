ROUND(
        (
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-01-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-01-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-02-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-02-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-03-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-03-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-04-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-04-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-05-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-05-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-06-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-06-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-07-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-07-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-08-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-08-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-09-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-09-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-10-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-10-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-11-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-11-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
            +
            CASE
                WHEN YEAR(CURRENT_DATE) = 2026
                 AND IFNULL(T2."Quantity", 0) > 0
                 AND TO_DATE('2026-12-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                 AND TO_DATE('2026-12-01', 'YYYY-MM-DD')
                     BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                         AND ADD_MONTHS(
                                ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                TO_INTEGER(T2."Quantity") - 1
                             )
                THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                ELSE 0
            END
        ),
        2
    ) AS "Previsto Ate Final Ano",

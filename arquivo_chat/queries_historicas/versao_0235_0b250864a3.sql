CASE
    WHEN IFNULL(T2."Quantity", 0) = 1
    THEN ADD_DAYS(T0."EndDate", 1 - DAYOFMONTH(T0."EndDate"))

    WHEN IFNULL(T2."Quantity", 0) > 1
    THEN ADD_MONTHS(
        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
        TO_INTEGER(T2."Quantity") - 1
    )

    ELSE ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
END AS "Mes Fim Provisionamento"

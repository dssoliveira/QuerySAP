ADD_MONTHS(
    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
    TO_INTEGER(T2."Quantity") - 1
) AS "Mes Fim Provisionamento"

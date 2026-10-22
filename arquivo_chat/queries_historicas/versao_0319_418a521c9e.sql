SELECT
    T0.*
FROM OWTQ T0

INNER JOIN OUSR T1
    ON T1."USERID" = T0."UserSign"

WHERE
    T0."DocStatus" = 'O'
    AND T1."USERID" = 11

ORDER BY
    T0."DocDueDate",
    T0."DocNum";

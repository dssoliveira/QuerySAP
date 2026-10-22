SELECT
    L."U_callID" AS "Numero OS",
    L."U_LogDateTime" AS "Data Log",
    L."U_User" AS "Usuario LOC1",
    L."U_Description" AS "Descricao Log"

FROM "@LOC1_SCL7" L

WHERE
    L."U_callID" = 9290

ORDER BY
    L."U_LogDateTime" ASC;

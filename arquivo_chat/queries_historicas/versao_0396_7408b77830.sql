SELECT TOP 10
    H."DocNum" AS "Numero_Saida",
    H."DocDate" AS "Data_Saida",
    H."U_LOC1_CallID" AS "Chamado_LOC1",
    H."U_MM_OS" AS "Numero_OS",
    H."U_MM_Tipo" AS "Tipo_Saida",
    L."ItemCode" AS "Codigo_Item",
    L."Quantity" AS "Quantidade"
FROM OIGE H
INNER JOIN IGE1 L
    ON L."DocEntry" = H."DocEntry"
WHERE L."ItemCode" IN (
    'MA003838',
    'MA004404',
    'MA003628'
)
ORDER BY
    H."DocDate" DESC,
    H."DocNum" DESC;

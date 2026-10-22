SELECT
    I."ItemCode" AS "Codigo_Item",
    I."ItemName" AS "Descricao_Item",
    I."ManSerNum" AS "Controlado_por_Numero_de_Serie",
    I."ManBtchNum" AS "Controlado_por_Lote"
FROM OITM I
WHERE I."ItemCode" IN (
    'MA003838',
    'MA004404',
    'MA003628'
)
ORDER BY
    I."ItemCode";

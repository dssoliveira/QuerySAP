SELECT
    T0."DocNum" AS "Pedido Compra",
    CAST(T0."PickRmrk" AS NVARCHAR(5000)) AS "PickRmrk",
    CAST(T0."Comments" AS NVARCHAR(5000)) AS "Observacoes Externas",
    T0."JrnlMemo" AS "Observacoes Diario"
FROM OPOR T0
WHERE
    T0."DocNum" = 43;

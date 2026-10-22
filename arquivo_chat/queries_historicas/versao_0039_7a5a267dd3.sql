SELECT
    T0."DocNum" AS "Pedido Compra",
    CAST(T0."Header" AS NVARCHAR(5000)) AS "Header",
    CAST(T0."Footer" AS NVARCHAR(5000)) AS "Footer",
    CAST(T0."Comments" AS NVARCHAR(5000)) AS "Comments",
    T0."JrnlMemo" AS "JrnlMemo"
FROM OPOR T0
WHERE
    T0."DocNum" = 43;

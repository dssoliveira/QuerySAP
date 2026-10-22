ROW_NUMBER() OVER (
    PARTITION BY
        NF0."DocEntry",
        I1."BaseEntry",
        IFNULL(I1."OcrCode", R1."OcrCode")
    ORDER BY
        I1."LineNum"
) AS "LinhaControle"

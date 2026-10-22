IFNULL(
    D1."OcrCode",
    IFNULL(F1."OcrCode", R1."OcrCode")
) AS "OcrCode"

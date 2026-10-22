IFNULL(
    F1."OcrCode",
    IFNULL(R1."OcrCode", D1."OcrCode")
) AS "OcrCode"

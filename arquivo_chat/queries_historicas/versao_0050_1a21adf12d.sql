SELECT
    "OcrCode",
    "OcrName"
FROM OOCR
WHERE
    UPPER("OcrName") LIKE '%ELETR%'
    OR UPPER("OcrName") LIKE '%FOTOV%'
    OR UPPER("OcrName") LIKE '%REVENDA%'
    OR UPPER("OcrName") LIKE '%SEMINOV%'
ORDER BY
    "OcrName";

AND (
    LENGTH(TRIM('[%0]')) = 0
    OR UPPER(TRIM(T2."OcrCode")) = UPPER(TRIM('[%0]'))
)

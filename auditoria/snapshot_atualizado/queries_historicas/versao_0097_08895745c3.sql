WHERE
    T0."Status" = 'A'

    /* T2."OcrCode" */
    AND (
        '[%0]' = ''
        OR UPPER(TRIM(T2."OcrCode")) = UPPER(TRIM('[%0]'))
    )

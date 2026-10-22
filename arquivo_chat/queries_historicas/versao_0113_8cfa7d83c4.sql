WHERE
    (
        T2."OcrCode" = '[%0]'
        OR '[%0]' = ''
    )
    AND T0."Status" = 'A'

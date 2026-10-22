AND NOT EXISTS (
    SELECT
        1
    FROM RDR1 EXC
    WHERE
        EXC."DocEntry" = T0."DocEntry"
        AND EXC."ItemCode" IN (
            'SV000045',
            'SV000044'
        )
)

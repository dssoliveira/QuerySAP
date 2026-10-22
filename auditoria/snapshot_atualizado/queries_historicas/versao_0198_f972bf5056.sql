FROM NF_BASE NF
LEFT JOIN (
    /* valores de entrega por centro de custo */
) ENT
    ON ENT."OcrCode" = NF."OcrCode"
GROUP BY
    NF."OcrCode",
    ENT."Jan",
    ENT."Fev",
    ...

CASE
    WHEN T2."OcrCode" = 'GERADOR' THEN 'Gerador'
    WHEN T2."OcrCode" = 'NOBREAK' THEN 'Nobreak'
    ELSE T2."OcrCode"
END AS "Centro de Custo",

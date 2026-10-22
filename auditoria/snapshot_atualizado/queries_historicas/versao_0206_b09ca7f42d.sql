AND IFNULL(
    D1."OcrCode",
    IFNULL(F1."OcrCode", R1."OcrCode")
) IN (
    'GERADOR',
    'NOBREAK',
    'LOCACAO',
    'EXE_ELET',
    'FOTOV',
    'REV_DIRE',
    'SEMINOVO'
)

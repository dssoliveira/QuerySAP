AND IFNULL(
    F1."OcrCode",
    IFNULL(R1."OcrCode", D1."OcrCode")
) IN (
    'GERADOR',
    'NOBREAK',
    'LOCACAO',
    'EXE_ELET',
    'FOTOV',
    'REV_DIRE',
    'SEMINOVO'
)

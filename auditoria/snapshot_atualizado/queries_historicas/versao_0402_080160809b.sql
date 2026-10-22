AND IFNULL(
    T1."OcrCode",
    IFNULL(
        R1."OcrCode",
        IFNULL(D1."OcrCode", R1F."OcrCode")
    )
) IN (
    'GERADOR',
    'NOBREAK',
    'LOCACAO',
    'EXE_ELET',
    'FOTOV',
    'REV_DIRE',
    'SEMINOVO',
    'FILIALSP',
    'ENE_CUBE'
)

WHERE
    I1."BaseType" = 17
    AND I1."OcrCode" IN (
        'GERADOR',
        'NOBREAK',
        'EXE_ELET',
        'FOTOV',
        'LOGI_REV',
        'LOGI_SEM',
        'REV_DIRE'
    )
    AND NF0."Serial" IS NOT NULL

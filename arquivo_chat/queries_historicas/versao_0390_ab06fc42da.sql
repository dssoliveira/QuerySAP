SELECT
    "TableID",
    "AliasID",
    "Descr"
FROM CUFD
WHERE "TableID" IN ('ORDR', 'OWTQ', 'OWTR', 'OIGE')
ORDER BY
    "TableID",
    "AliasID";

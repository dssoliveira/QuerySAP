(
    IFNULL(TRF."ValorTransferenciaEstoque", 0)
    +
    IFNULL(PVG."ValorPedidoVendaGeradoOS", 0)
    +
    IFNULL(PVI."CustoHoraHomemPVGeradoIClass", 0)
) AS "CustoTotalOS"

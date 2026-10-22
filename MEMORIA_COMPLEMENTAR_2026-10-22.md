# Memoria complementar e registro de decisoes

Esta memoria complementa os arquivos de julho e setembro. Fonte: conversa e
anexos disponiveis nesta estacao. Ela distingue fatos observados de propostas.

## Objetivo de preservacao

Danilo quer recuperar o trabalho se o computador quebrar ou for devolvido:
queries, interpretacoes, configuracoes reproduziveis, preferencias, erros e
evidencias. Em 22/10 autorizou publicar os arquivos do projeto no QuerySAP.
Nao confundir publicar arquivos com transferir automaticamente um chat ou
instalar o SAP em outra maquina.

## Preferencias e principios

- Entregar codigo completo pronto para teste quando solicitado.
- Nao modificar estrutura de relatorio aprovado fora do escopo.
- Uma linha por cabecalho quando itens causam duplicacao.
- Criador do pedido de transferencia como primeira coluna.
- Distinguir projeto financeiro (OPRJ) de projeto gerencial/engenharia. O exemplo
  6185 nao autoriza converter automaticamente um codigo financeiro em chave do
  projeto gerencial. A seta de acesso depende de objeto e chave corretos.

## Faturamento e metas

A regra de faturamento e gerencial, relatada pelo usuario, nao um parecer fiscal.
Preservar NF de saida real; excluir NF de venda futura pura; auditar entregas
vinculadas conforme regra validada. CFOP 5922/6922 foi tratado como venda futura;
nao classificar toda NF do mesmo pedido pela classificacao de uma unica NF.
Consultar memoria de setembro para o tratamento de entrega real vinculada.

Exemplo comprovado por export do usuario, pedido 1569:

| DocEntry NF | DocNum SAP | Numero fiscal | CFOP | Valor | Decisao |
|---|---|---|---|---|---|
| 1098 | 643 | 14023 | 5922 | 103.898,62 | Sair: venda futura |
| 2358 | 1409 | 4850 | 5949 | 1.979,53 | Compor: saida |
| 3668 | 2208 | 18608 | 5933 | 27.272,91 | Compor: saida |

NF_BASE da DREXMETAS precisa conter a regra: atualizar a query de NF separada
nao altera automaticamente outra consulta independente. O mapa de relacoes
mostrou valor diferente para documento 2208; o export de linhas acima e a
evidencia fornecida, sem reconciliacao adicional presumida.

FILIALSP e ENE CUBE devem aparecer individualmente e no subtotal geral. Janeiro
e fevereiro sem resultados fornecidos ficam em branco, nao zero inventado.

## Custos, OS e iClass

OSCL representa chamado de servico; `callID` e `DocNum` nao devem ser confundidos.
OWTQ.U_MM_OS foi usado para ligar a OSCL.callID. Itens da OS: itemCode/itemName.
PV gerado por iClass pode estar na aba Documentos relacionados, nao somente no
campo personalizado usado pelo pedido de transferencia. Exemplo: chamado
callID 4306, numero exibido 3514, PV 5654 com SV000045 e 60 minutos.

SV000045 = mao de obra; SV000044 = deslocamento. Usuario pediu ambos no mesmo
campo de itens e soma dos minutos, sem multiplicar a linha da OS. Taxa gerencial
solicitada: R$35/hora; custo = minutos / 60 * 35. Nao interpretar como custo
contabil efetivamente apurado. Validar existencia e unicidade dos vinculos.

Criador LOC1: log @LOC1_CHLO, operacao Add, tabela OSCL. Evidencia para chave
9290: MARIANA ANDREOLLI, 04/09/2026. Mesmo numero tambem existe em ORDR com
LOC1 Suporte em 11/06/2026: filtrar tabela e operacao evita falso vinculo.

Custos de PV: usuario rejeitou rateio por valor da linha e preferiu divisao
igual entre centros de custo (2 = 50% cada, 3 = 1/3 cada). Entretanto a conversa
tambem aponta restricao de atribuicao de MO/alimentacao/hospedagem a revenda:
confirmar elegibilidade na query final antes de aplicar a todos os centros.

## Saidas de bombas injetoras

Escopo: MA003838, MA004404, MA003628. Usuario restringiu a analise a saidas de
mercadorias para descobrir destino e custo. Os tres itens nao sao controlados
por serie nem lote (OITM: N/N). Nao e possivel prometer rastreabilidade fisica
individual a partir de serie inexistente.

Export confirmou seis saidas, quantidade 1 cada, BaseType=-1, sem documento-base:

| Saida DocNum | DocEntry | Data | Item | Observacao |
|---|---|---|---|---|
| 244 | 554 | 08/04/2026 | MA004404 | RETIRADO POR VIOR LIMAO |
| 603 | 1155 | 19/05/2026 | MA003838 | Thiago Torres; observacao menciona 27/04/26 |
| 1604 | 2484 | 07/08/2026 | MA003628 | THIAGO T. |
| 1627 | 2513 | 11/08/2026 | MA003628 | Sem observacao |
| 1693 | 2603 | 19/08/2026 | MA003628 | Sem observacao |
| 1994 | 2961 | 09/09/2026 | MA003628 | Thiago Pelegrina |

Nao atribuir automaticamente OS/PV por coincidencia de item/data/quantidade.
Erro recorrente: `invalid column name: M.BaseRef`; remover a dependencia desse
campo nao confirmado na estrutura usada. Conferir metadados antes de repetir.

## Pesquisa de materiais

Correcoes explicitas: FS1001 substitui FF1001; WF2176 e o filtro de agua pedido
na correcao posterior; placa Scania correta 2153365 substitui 2153635. Anterior
lista citava WF2175, apesar da correcao mencionar WF215: usar intencao final
WF2176 e deixar registrada a divergencia. Incluir em todos os modelos OLEO
LUBRIFICANTE TURBO 15W40CI4 LITRO - VALVOLINE, excluindo cadastro com DUPLICADO.

Motores: Cummins NTA855; Scania DC13 072A; Scania DC16 049A; Mercedes OM471.
Demais referencias originais estao na transcricao. Preco exige lista de precos
identificada e unidade correta; nao deduzir equivalencia so por descricao.

## Lancamentos contabeis de projeto

Usuario quer materiais por transacao e reconciliacao de valor bruto de compra
com liquido apos creditos de impostos. Tela inclui materias-primas, produto
acabado, expedicao e fornecedores. Nao somar debitos/creditos de contas distintas
como custo unico nem repetir bruto em cada parcela de fornecedor. Conciliar
documento, linha, conta e transacao; nao tratar toda diferenca como imposto sem
evidencia. A query completa sugerida no chat precisa de teste documentado.

## Pedidos de transferencia: caminho de compras

Cabecalho OWTQ, linhas WTQ1, usuario criador OUSR via UserSign; projeto OPRJ via
Project, departamento OcrCode. Agregar linhas por DocEntry; projetos ou centros
distintos resultam MULTIPLOS. BPLName normalizado para Sistel Engenharia/Comercio.
Consulta filtra DocStatus='O'. Isso nao constitui novo filtro explicito CANCELED.

Inspecao inicial relatada: 423 pedidos abertos, 1363 linhas; BaseType=-1 em todas;
86 TargetType=67, demais -1; U_MM_NumDoc vazio. A relacao de compras foi localizada
nas referencias PRQ21: RefDocEntr=OWTQ.DocEntry, RefObjType='1250000001',
RefType='S', DocEntry=OPRQ.DocEntry. Segundo export apresentou 106 relacoes,
todas com solicitacao de compra. O numero de relacoes nao e numero de pedidos.

Exemplos: transferencia 809 -> solicitacoes 1689 e 1772; transferencias 850,
851,860 -> solicitacao 1808; transferencia 1103 -> 1970 e 1985.
Uma solicitacao compartilhada gera relacao em nivel de documento, sem provar
que todos os itens de cada transferencia foram comprados.

Caminhos propostos para chegar ao PC:
- POR1.BaseType=1470000113 e BaseEntry=chave da solicitacao.
- Via cotacao PQT1, com POR1.BaseType=540000006 e BaseLine correspondente.
- Referencias POR21/DRF21 para solicitacao (RefObjType='1470000113').
- Esbocos ODRF/DRF1 ObjType='22'; OPOR.draftKey aponta esboco convertido.

Somente o primeiro elo transferencia -> solicitacao recebeu evidencia direta
nos exports analisados. Os demais caminhos propostos exigem conferencia no SAP.

Colunas que usuario mandou retirar: Status Documento, Cancelado, Data Documento,
Status OS, Nome Departamento, Quantidade Solicitacoes Compra, Quantidade Pedidos
Compra, Observacoes Diario, Data Criacao, Hora Criacao. Quantidade Esbocos Compra
nao foi incluida nessa remocao. Criador permanece primeira coluna.

## Aprovacao de compra: estado mais recente

Usuario pediu titulo [Autorizado], data da autorizacao e esboco Recusado.
Consultar OWDD (ObjType='22') e WDD1 por WddCode. A consulta diagnostica foi
executada pelo usuario e exportada no anexo
1dcb3ab6-bad0-44ec-b453-fd8eca156089. Exemplos observados em 05/10/2026:

| Processo | PC | Esboco | ProcesStat | Status solicitacao | Resultado |
|---|---|---|---|---|---|
| 4212 | 3638 | 28747 | P | Y | Autorizado; documento gerado |
| 4195 | 3630 | 28656 | A | Y | Gerado pelo autorizador |
| 4189 | vazio | 28606 | N | N | Recusado |
| 4188 | vazio | 28605 | N | N | Recusado |
| 4213 | vazio | 28748 | W | W | Aguardando aprovacao |

Data exibida nesses exemplos: 05/10/2026 para aprovados/recusados; pendentes sem
data de decisao. O retorno demonstra vinculos e status, mas nao comprova que
MAX(WDD1.UpdateDate) seja sempre o instante de conclusao de todas as etapas.
A query chama a coluna Data Autorizacao a Validar deliberadamente.

Mapas: W pendente, Y aprovado, N recusado, P gerado, A gerado pelo autorizador,
C cancelado, '-' sem processo. P/A indicam geracao e nao devem perder seu
significado original. OWDD.Status e ProcesStat podem divergir (P versus Y no
exemplo). Nao inferir aprovacao somente de DocStatus aberto/fechado do PC.

Vinculos diagnosticos: PC por OWDD.DocEntry quando IsDraft=N ou por
OPOR.draftKey=OWDD.DraftEntry. Esboco por DraftEntry, com fallback DocEntry quando
IsDraft=Y. A consulta expunha todos os processos, com BFType A=criacao e U=update;
uma recusa de alteracao nao invalida automaticamente autorizacao de criacao.

PENDENTE: incorporar aprovacao/data ao relatorio de transferencias, selecionar
processos sem duplicar documentos e validar datas multi-etapas. A conversa
mudou de assunto antes dessa implementacao final; nao registrar como concluida.

## Erros e limites

Mensagens ODBC -2028 (OACT, ECM2) foram apresentadas pelo usuario; o registro
nao comprova uma unica causa definitiva nem correcao executada. SQL com erro
de UNION e M.BaseRef permanece historico para evitar repeticao. Nao reconstruir
uma correcao como aprovada apenas porque foi enviada pelo assistente.

## Fontes oficiais usadas para aprovacao

- https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/OWDD.html
- https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/WDD1.html

## Proxima sessao

Comecar pela tarefa solicitada por Danilo. Se retomar compras, usar export de
aprovacoes e validar processo/data antes de substituir a query oficial.
Nao existe mecanismo de aprendizado automatico que publique novas decisoes
no repositorio: atualizar arquivos e fazer push ao concluir etapas relevantes.

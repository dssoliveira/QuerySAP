# Registro de decisoes, evidencias e evolucao

Fonte: snapshot_atualizado/TRANSCRICAO.md. M = numero de mensagem. Dados de
negocio permanecem exatamente como apresentados nas fontes, sem atualizacao
monetaria ou presuncao de estado atual do SAP.

## Regras permanentes e contexto

| ID | Regra/decisao | Fonte | Estado e motivo |
|---|---|---|---|
| D01 | Manter estrutura das queries aprovadas; alteracao cirurgica | M309,368,373,384,506,704 | Instrucao repetida do usuario; evitar reconstruir base de memoria |
| D02 | Entregar codigo completo para facilitar substituicao | M61,187,405,444,843 | Preferencia explicita; nao cortar uma base extensa |
| D03 | Distinguir DocEntry, DocNum e Serial | M221,754 | Identificadores nao intercambiaveis |
| D04 | Campos originais favorecem setas; agregacoes podem elimina-las | M240,356,489,617,641 | Requisito de interface; acesso requer teste no cliente SAP |
| D05 | Mostrar empresa como Sistel Comercio ou Sistel Engenharia | M107,348,442,659 | Normalizacao de exibicao; nao alterar chave fiscal |
| D06 | Guardar e acumular envios antes de concluir auditoria | M140,248,744/747 | Usuario enviou dados por etapas; evitar conclusao prematura |

## Contratos, resumo e planejamento

| ID | Regra/decisao | Fonte | Estado e evolucao |
|---|---|---|---|
| D07 | Analitico e resumo devem usar a mesma granularidade e base | M19,25,28,29 | Assistente relatou 162 contratos e totais coincidentes; usuario respondeu OK. Preservar como auditoria historica, nao reexecucao atual |
| D08 | Analitico pode repetir contrato por centro e linha pertinente | M109,125 | Usuario rejeitou juntar centros diferentes em uma unica linha |
| D09 | Filtro de centro vazio deve trazer todos | M150,155,171,178 | Houve falhas de parametro e selecao do campo errado; nao considerar qualquer versao intermediaria final |
| D10 | Centro de custo primeiro; remover coluna duplicada de codigo/nome | M127,173 | Codigo apresentado como Centro de Custo |
| D11 | Remover periodicidade e inicio manuais de faturamento | M164,167,168 | Nao eram campos SAP; evitar inventar integracao com planilha |
| D12 | Filtro por centro reconciliado com consolidado | M190,196,199 | Assistente relatou 477 linhas, 385 contratos distintos; os totais por centro nao permitem somar contagens distintas sem checar intersecao |
| D13 | Parcela unica no fim da vigencia foi uma regra intermediaria | M479,483 | Posteriormente substituida pela instrucao M486 |
| D14 | Distribuir desde inicio apenas pela quantidade de parcelas, inclusive parcela 1 | M483,486 | Ultima instrucao explicita: parcela unica no primeiro mes; exemplo 6 parcelas desde marco termina em agosto |
| D15 | Planejamento mensal correto nao homologou previsto anual e setas | M489 | Teste parcial positivo; corrigir previsto ate dezembro e navegacao |
| D16 | Base correta de contratos e o anexo 928b0597, nao a versao reduzida | M501,506,508 | Rejeicao explicita de alteracao de documento e tamanho da query |
| D17 | Calculo com CURRENT_DATE pode variar por ano; alias SQL literal e fixo | M498,501,508 | Assistente explicou limite; nome neutro foi proposta, sem aceite posterior explicito |
| D18 | Resumo operacional deve evitar inflar numero de contratos | M552-555 | Proposta de deduplicar por contrato+centro; escolher uma linha com ROW_NUMBER nao prova que descartar demais valores seja correto |

## Faturamento e DRE

| ID | Regra/decisao | Fonte | Estado e evolucao |
|---|---|---|---|
| D19 | NfeValue e a base fiscal gerencial escolhida pelo usuario | M257,289,306 | DocTotal foi escolha anterior substituida em M289; nao voltar a soma de linhas sem autorizacao |
| D20 | Contar o valor do cabecalho uma vez por NF | M299,302,319,323-325 | Incluir itens repetindo NfeValue foi rejeitado; exige controle de cardinalidade |
| D21 | Documentos diferentes com mesmo valor nao sao duplicacao por si so | M323 | Usuario confirmou 3 NFs RIO PARANA legitimas |
| D22 | Duplicacao de IVAN foi diagnostico distinto | M324,325 | Assistente relatou NF interna 4324, serial14536: 184.500 versus 738.000; excesso553.500. Nao deduplicar por cliente/valor |
| D23 | Manter vinculo com PV e auditar ausencia | M226,297,323 | Sem vinculo deve gerar alerta, nao desaparecer por INNER JOIN sem avaliacao |
| D24 | Separar auditorias de vinculo e transmissao | M622,631 | Status_Vinculo_Pedido e Status_Transmissao_NFSe independentes |
| D25 | NFSe: itens SV e U_MM_NumNFse preenchido como criterio operacional | M622 | Usuario forneceu campo; criterio relatado nao equivale a consultar prefeitura em tempo real |
| D26 | CFOP por linha exige tratamento de documento misto | M291,293,736,754 | Campo foi inicialmente descartado e retomado para auditoria; nao reduzir a regra universal sem conferir linhas |
| D27 | Venda futura pura sai; saidas reais do mesmo PV permanecem | M727,731,752,754,756 | Exemplo PV1569: DocEntry1098 sai,2358/3668 entram; selecao e por NF, nao por PV inteiro |
| D28 | Regra final sugerida: CFOP5922/6922 sem entrega vinculada excluido | M754-758 | Exemplo observado valida separacao; entrega e composicao multi-CFOP ainda exigem teste de abrangencia |
| D29 | Entrega vinculada usa data/valor da entrega e centro rastreado | M402,407,415,417,426,427 | Evolucao para espelhar analitico e DRE; nao somar entrega e NF futura integral simultaneamente |
| D30 | DREXMETAS tem logica propria em NF_BASE | M759-764 | Alterar consulta NF separada nao atualiza automaticamente DRE |
| D31 | FILIALSP e ENE CUBE individualmente e subtotal | M825,828 | Janeiro/fevereiro sem dados ficam NULL/em branco; nao inventar zero |
| D32 | Diferenca entre filtros de datas precisa reconciliar periodo e semantica | M465,467,426 | Datas criacao/emissao/entrega representam eventos diferentes; somas nao sao comparaveis por mes sem alinhamento |

## Pedidos, legado e custos

| ID | Regra/decisao | Fonte | Estado e evolucao |
|---|---|---|---|
| D33 | Status comercial A Faturar/Parcial/Faturado | M211,325 | Derivado dos valores; nao confundir com DocStatus aberto/fechado |
| D34 | No relatorio comercial excluir pre-consumo LOC1 e horas iClass | M446,448 | PV com SV000045/SV000044 nao e venda real para esse relatorio; em relatorio de custos OS esses mesmos itens sao desejados |
| D35 | Manter apenas Ano Competencia Comercial | M538 | Remover texto redundante de competencia |
| D36 | Migracao SIGEM -> SAP exige faturamento legado por pedido | M548 | Valores sao entrada manual do usuario, nao fatos recuperados automaticamente do SAP |
| D37 | Pedido166 legado esta desconhecido | M548,551 | Usuario informou texto; assistente usou zero. Zero nao comprova ausencia de faturamento: pendencia relevante |
| D38 | Exports com linhas vazias nao provam mudanca de programacao | M542,545-547 | Assistente relatou38 pedidos efetivos/663 vazios contra701 da oficial; sem homologacao da base completa |
| D39 | Rateio de custos solicitado por quantidade de centros | M708,710 | Igual por centro, nao proporcional por valor; confirmar elegibilidade de revenda para MO/alimentacao/hospedagem |
| D40 | Rateio do legado de M551 foi proposta proporcional diferente | M550,551 versus M710 | Escopos distintos: nao aplicar a nova regra de custos automaticamente ao faturamento legado |

## Equipamentos, OS e compras

| ID | Regra/decisao | Fonte | Estado e evolucao |
|---|---|---|---|
| D41 | Cartao, contrato e serial/LOC1 podem divergir | M558,568,580,583 | Nao supor campos usados pela integracao; consultar memorias sobre OSRN e @LOC1_SNMO |
| D42 | PV por OS 1:1; transferencias podem ser varias | M605 | Regra operacional relatada; conferir dados e nao multiplicar custo em joins |
| D43 | Projeto gerencial diferente do financeiro | M635,641 | Setas continuavam no financeiro; pedido de seta gerencial nao comprovadamente concluido |
| D44 | Criador como primeira coluna, item da OS sem linhas de consumo | M662,664-666 | Encerramento explicito do relatorio simplificado em M666; novas compras foram tarefa posterior |
| D45 | iClass vinculado em Documentos relacionados | M672 | Versao anterior retornou vazio; nao repetir relacao por campo presumido |
| D46 | Somar minutos MO/deslocamento; taxa35/h | M668,678 | Custo gerencial = minutos/60*35; nao custo contabil apurado |
| D47 | Criador LOC1 por @LOC1_CHLO + OSCL + Add | M683,696 | Mesmo Codigo Dados9290 existe em OSCL e ORDR; chave isolada e ambigua |
| D48 | Transferencia -> PRQ21 -> OPRQ observado | M864,868 | Filtro RefObjType1250000001 e RefType S; pedido compartilhado nao comprova atribuicao por item |
| D49 | Chegar a OPOR por PR/cotacao/referencias e proposta de caminho | M869-872 | Sem comprovacao completa de cada caminho; manter uma linha por transferencia |
| D50 | Datas/status aprovacao por OWDD/WDD1 | M873,875,876 | Diagnostico com retorno; MAX(UpdateDate) ainda exige validacao multi-etapas |
| D51 | Recusa de atualizacao nao cancela por si so criacao aprovada | M875 | Distinguir BFType A/U, Status/ProcesStat e esboco/documento efetivo |

## Materiais e contabilidade

| ID | Regra/decisao | Fonte | Estado e evolucao |
|---|---|---|---|
| D52 | Bombas MA003838/MA004404/MA003628; foco final apenas saidas | M779,792 | Mudanca de escopo explicita; nao exigir relatorio de entrada como produto final atual |
| D53 | Seis saidas sem base e sem serie/lote | M805,807,809 | Limite de rastreabilidade; nao prometer destino por OS sem evidencia adicional |
| D54 | M.BaseRef inexistente na estrutura usada | M784,797,799,814 | Erro repetido; metadados devem preceder nova query |
| D55 | FS1001,WF2176,placa2153365 e oleo sem DUPLICADO | M839,841 | Referencias posteriores prevalecem; nao concluir equivalencia tecnica so pelo texto |
| D56 | Bruto x liquido contabil requer conciliacao por documento/conta | M852 | Creditos de impostos sao hipotese do usuario; validar natureza da diferenca |
| D57 | Curto prazo de locacao nao teve limite acordado | M716,721 | Nao inventar classificacao de30/90dias como regra validada |
| D58 | OACT/ECM2 ODBC-2028 nao tem causa unica comprovada | M698,700 | Sem evidencia de correcao executada; mensagens preservadas |

## Continuidade e seguranca do acervo

| ID | Regra/decisao | Fonte | Estado |
|---|---|---|---|
| D59 | Preservar o trabalho e nao reescrever historico Git | M880 | Inicializacao so ocorreu por .git vazia; remoto vazio na verificacao inicial |
| D60 | Autor QuerySAP e publicacao autorizada | M884 | Configuracao local; e-mail noreply usado no commit |
| D61 | Objetivo e sobreviver a perda do notebook | M887,891 e pedidos seguintes | Arquivos publicados, recuperacao testada; novos trabalhos precisam de commit/push |
| D62 | Nuvem e local sao copias separadas | Conversa posterior a primeira exportacao | Compartilhar repositorio nao transfere automaticamente novas mensagens ou arquivos locais |

## Contradicoes que nao devem ser apagadas

1. DocTotal foi pedido antes; M289 fixou NfeValue para a base fiscal gerencial.
2. Vigencia mensal e parcela unica no fim foram etapas; M486 pediu parcelas
   desde o inicio, inclusive parcela unica no primeiro mes.
3. Header/Footer/PickRmrk como observacao interna de OPOR foram palpites de
   diagnostico, sem resultado posterior que os confirme. Nao ensinar como campo certo.
4. Supostas versoes finais do assistente receberam rejeicoes depois. Priorizar
   usuario e evidencia, nao o adjetivo final no texto do assistente.
5. Sem dados legado do PV166 nao equivale a valor zero validado.

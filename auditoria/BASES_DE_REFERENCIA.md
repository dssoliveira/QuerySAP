# Bases SQL de referencia e estado de validacao

Os links levam a arquivos originais preservados, nao a SQL recomposto nesta
auditoria. As versoes sao referencias de continuidade; aprovacao historica nao
garante vigencia atual. Nenhuma query foi executada no SAP nesta entrega.

| Assunto | Arquivo | Evidencia/estado |
|---|---|---|
| NF, base encerrada antes das revisoes de entrega/CFOP | [versao0155](../arquivo_chat/queries_historicas/versao_0155_2ca58044b8.sql) | M305,M306: usuario disse ok fechamos; regras evoluiram depois |
| NF: base declarada validada pela diretoria | [anexo031](../arquivo_chat/anexos/031_pasted-text.txt) | Anexo3ea334b4,M622; aprovada antes de solicitar NFSe e projeto |
| NF: candidata consolidada com CFOP | [versao0383](../arquivo_chat/queries_historicas/versao_0383_a6fbb1ca68.sql) | M758: enviada para substituir oficial apos exemplo1569; sem retorno posterior homologando todas as linhas |
| DRE: base do usuario para alinhamento fiscal | [anexo059](../arquivo_chat/anexos/059_pasted-text.txt) | M759: original714beaa8; M764 candidata de alteracao |
| DRE: candidata alinhada ao filtro CFOP | [versao0386](../arquivo_chat/queries_historicas/versao_0386_a9097d6a09.sql) | M764; sem teste funcional posterior comprovado |
| DRE: arquivo existente com FILIALSP/ENE CUBE | [arquivo raiz](../FATURAMENTO_DREX_METAS_ATUALIZADA.sql) | Preexistente; preservado; nao declarar automaticamente ultima homologada |
| PV custos: base declarada aprovada | [anexo005](../arquivo_chat/anexos/005_pasted-text.txt) | M704: usuario solicita apenas agregar custos |
| PV: ultima oficial declarada para incluir legado | [anexo125](../arquivo_chat/anexos/125_pasted-text.txt) | M548: f337145b; fornecida antes de mudanca legado |
| Contratos: base exigida apos rejeicao | [anexo071](../arquivo_chat/anexos/071_pasted-text.txt) | M506:928b0597; evitar reescrever base reduzida |
| Contratos: bloco automatizado fornecido | [anexo096](../arquivo_chat/anexos/096_pasted-text.txt) | M501:befb6992; fragmento, nao query completa |
| Transferencia simplificada com item OS | [versao0323](../arquivo_chat/queries_historicas/versao_0323_9ac76daaa3.sql) | M665 query completa; M666 encerramento explicito |
| Transferencia: base operacional colada pelo usuario | [M859](sql_usuario/M0859_fornecida_usuario.sql) | Reabertura do assunto para adicionar compras; fonte integral direta |
| Transferencia/compras: candidata apos retirar colunas | [versao0420](../arquivo_chat/queries_historicas/versao_0420_67cb0a4714.sql) | M872: manter requisito, falta retorno validando cadeia completa |
| Aprovacao PC: diagnostico | [versao0421](../arquivo_chat/queries_historicas/versao_0421_926f991275.sql) | M875; resultado em anexo016, nao integrado ao relatorio final |
| Aprovacao PC: evidencia de execucao pelo usuario | [anexo016](<../arquivo_chat/anexos/016_Texto colado.txt>) | M876: processos4212,4195,4189 etc. |
| Relacao transferencia-solicitacao | [anexo029](<../arquivo_chat/anexos/029_Texto colado.txt>) | Segunda extracao:106 relacoes observadas |
| Bombas: base usada na extracao | [anexo098](<../arquivo_chat/anexos/098_Texto colado.txt>) | M816:c4dd1b5a; nao assumir que resolve vinculos inexistentes |
| Pesquisa materiais: candidata apos correcoes | [versao0413](../arquivo_chat/queries_historicas/versao_0413_5df95c963d.sql) | M844: FS1001,WF2176,2153365 e exclusao DUPLICADO; sem homologacao de precos |

## Como escolher a base

Se Danilo enviar uma nova query oficial, ela prevalece como documento de trabalho
da tarefa, sem apagar as fontes anteriores. Confirmar qual relatorio e qual
granularidade antes de aplicar uma regra de outro assunto. Para assuntos nao
listados, usar CATALOGO_421_QUERIES.csv e o indice de mensagens; nao escolher
automaticamente o maior numero de versao como o mais correto.

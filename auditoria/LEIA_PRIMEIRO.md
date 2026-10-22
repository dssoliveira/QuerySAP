# Auditoria de continuidade — QuerySAP

Data de referencia: 22/10/2026. Este pacote amplia, sem substituir, o arquivo
historico original. A fonte principal e o registro local desta mesma sessao.

## Como encontrar a informacao

| Necessidade | Arquivo |
|---|---|
| Retomar sem reconstruir o projeto | ../CONTINUIDADE.md |
| Regras e limites do agente | ../AGENTS.md |
| Decisoes com origem e conflitos | REGISTRO_DECISOES.md |
| Escolher uma base de SQL conhecida | BASES_DE_REFERENCIA.md |
| Verificar todas as 421 versoes com cerca SQL | CATALOGO_421_QUERIES.csv |
| SQL colado pelo usuario sem cerca | CATALOGO_SQL_USUARIO.csv e sql_usuario/ |
| Navegar por assunto e pedido do usuario | LINHA_DO_TEMPO.md |
| Localizar qualquer mensagem recuperada | INDICE_MENSAGENS.csv |
| Ler a fonte textual mais recente | snapshot_atualizado/TRANSCRICAO.md |
| Localizar anexo e conferir integridade | ../arquivo_chat/INVENTARIO_ANEXOS.csv |
| Anexo posterior ao primeiro backup | INVENTARIO_ANEXOS_ADICIONAIS.csv |
| Diferenciar imagem, planilha, texto e SQL em anexo | CATALOGO_ANEXOS.csv |
| Ver referencias fora da pasta do projeto | INVENTARIO_REFERENCIAS_EXTERNAS.csv |
| Reproduzir a estacao sem copiar segredos | AMBIENTE_E_RECUPERACAO.md |
| Saber exatamente o que nao foi recuperado | LACUNAS_E_PENDENCIAS.md |
| Conferencia reproduzivel de tres exports importantes | CONFERENCIA_EVIDENCIAS.json |

Os numeros M1, M306 etc. referem-se aos cabecalhos da transcricao, e nao ao numero
de uma OS ou documento SAP. O snapshot original de 893 mensagens permanece em
arquivo_chat; esta auditoria registrou 911 mensagens no momento da nova leitura.
Mensagens desta propria entrega posteriores ao snapshot nao estao inclusas nele.

## O que foi classificado

O catalogo tem uma linha para cada um dos 421 blocos SQL distintos da primeira
exportacao; inclui as 473 ocorrencias desses blocos no snapshot, seu primeiro
retorno do usuario, assunto e hashes. Fragmentos e queries completas compartilham
o indice: 421 nao significa 421 relatorios completos nem aprovados.

Classificacao conservadora apos revisar os episodios criticos:

- 2 blocos ligados a encerramento/aceitacao explicita, em momentos historicos
  diferentes. Nao sao declarados a versao atual de todo o projeto.
- 20 blocos pertencentes a entregas com rejeicao ou correcao solicitada.
- 3 blocos de uma entrega com teste parcialmente positivo.
- 1 diagnostico de aprovacao com resultado fornecido.
- 395 blocos sem homologacao individual comprovada nesta auditoria.

Estes numeros nao constituem avaliacao automatica de qualidade SQL. Os 395 nao
sao declarados incorretos: falta evidencia suficiente para promove-los. Uma
mensagem com varios blocos pode conter exemplos, fragmentos e uma query completa.
A classificacao por episodio nao identifica isoladamente a causa de cada erro.

Tambem foram extraidas 12 bases SQL coladas diretamente pelo usuario e
identificados 43 anexos com inicio aparente de SQL, sem executar seu conteudo.
Esses conjuntos podem se sobrepor; nao somar para afirmar total de queries unicas.

## Nivel de revisao

A indexacao, hashes, referencias e contagens cobrem o conjunto enumerado nos
catalogos. A revisao interpretativa se concentrou nos requisitos, mudancas de
regra, rejeicoes explicitas, bases oficiais declaradas e exemplos numericos
listados no registro de decisoes. Nao foi realizada homologacao funcional de
cada bloco, OCR de cada imagem ou nova auditoria de todos os exports tabulares.

As alegacoes historicas do assistente foram preservadas como alegacoes da epoca.
So o usuario pode fornecer aprovacao de negocio; so a execucao autorizada no SAP
pode comprovar o funcionamento real nesse ambiente.

## Conferencia adicional dos resultados preservados

O script scripts/conferir_evidencias.mjs releu tres exports originais. Confirmou
1.363 linhas de 423 transferencias, 106 relacoes de 103 transferencias com
solicitacoes de compra e 3.775 processos distintos de aprovacao. Nesse ultimo
export, todos os processos sao de criacao: ele nao testa a regra de recusas de
alteracao. A distribuicao observada foi P=2.001, A=1.578, N=114, W=80 e Y=2.
Isso e evidencia de arquivo preservado, nao nova consulta ao SAP atual.

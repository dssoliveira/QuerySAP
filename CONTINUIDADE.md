# Como retomar o QuerySAP em outra estacao

Atualizacao: 22/10/2026. Responsavel: Danilo. Repositorio: https://github.com/dssoliveira/QuerySAP

## O que este backup preserva

Este repositorio guarda consultas, memorias tecnicas, uma transcricao textual
extraida do registro local deste chat e copias dos anexos citados que ainda
existiam nesta estacao. `arquivo_chat/INVENTARIO_ANEXOS.csv` identifica cada
origem, copia, tamanho, hash SHA-256 e ausencia. Arquivos ausentes nao foram
reconstituidos por suposicao.

`arquivo_chat/TRANSCRICAO.md` e o registro de mensagens visiveis disponiveis na
sessao local no instante da exportacao. Nao e garantia de transcricao integral
desde a criacao da conta: migracoes e compactacoes podem limitar o registro.
Nao e um arquivo de importacao de chat no Codex. Sua utilidade e permitir
pesquisa, auditoria e recuperacao do contexto por qualquer outro chat.

## Ordem de leitura

1. `AGENTS.md`: preferencias e regras permanentes.
2. `auditoria/LEIA_PRIMEIRO.md`: auditoria ampliada, catalogos e lacunas.
3. `MEMORIA_COMPLEMENTAR_2026-10-22.md`: novos assuntos e pendencias.
4. Memoria de setembro: NF, DREXMETAS, OS, custos e regras fiscais gerenciais.
5. Memoria de julho e contexto em outputs: equipamentos, serial, contratos LOC1.
6. Transcricao e anexos: consultar a origem da decisao e os resultados do teste.

## Arquivos e estado de validacao

- `FATURAMENTO_DREX_METAS_ATUALIZADA.sql`: arquivo que ja estava no projeto;
  preservado sem alteracao. O nome nao prova aprovacao de todas as regras.
- `arquivo_chat/queries_historicas/`: SQL extraido de blocos de mensagens,
  deduplicado por conteudo. O indice aponta mensagem e autor. Inclui tentativas,
  consultas de diagnostico e versoes com erros. Nao executar em lote.
- `arquivo_chat/anexos/`: copias das fontes enviadas pelo usuario, inclusive
  exports que podem conter SQL mais recente que o texto da conversa.
- Memorias: interpretacoes documentadas; confirmar regras pendentes no SAP.

## Recuperacao

Em outra estacao com Git instalado:

```powershell
git clone https://github.com/dssoliveira/QuerySAP.git
cd QuerySAP
git status
```

Autenticar com a propria conta GitHub se solicitado. Abrir essa pasta no Codex
ou selecionar o repositorio no ambiente online conectado ao GitHub. Usar:

> Leia AGENTS.md e CONTINUIDADE.md. Continue o projeto sem reconstruir do zero.
> Consulte as memorias e as evidencias da tarefa. Diferencie versao aprovada de
> tentativa. Antes de alterar uma query, informe qual arquivo e regra usara.

O acesso ao SAP, drivers HANA, VPN, permissoes de banco, plugins e autenticacao
GitHub precisam ser configurados na nova estacao. Eles nao foram copiados.
Nenhuma configuracao secreta e necessaria para ler a documentacao do repositorio.

## Configuracao Git conhecida

- Branch: main; remoto origin: https://github.com/dssoliveira/QuerySAP.git.
- Autor configurado somente neste repositorio: QuerySAP.
- E-mail tecnico de autoria: dssoliveira@users.noreply.github.com.
- Primeiro commit publicado: 55fce369a17ba3db8b3c290d506c10b2bba3af07.
- Nao havia historico Git valido anterior: a pasta .git estava vazia.
- `.gitignore` exclui credenciais, ambientes, caches e temporarios. O diretorio
  outputs tem um documento util explicitamente versionado.

## Rotina para nao perder os proximos trabalhos

Salvar a query final em arquivo, registrar a validacao com data e exemplos,
atualizar a memoria e fazer commit/push. Novas conversas nao sao publicadas
automaticamente. O script `scripts/preservar_chat.ps1` pode exportar mensagens
de uma sessao local explicitamente escolhida; os caminhos da estacao mudam.
Guardar uma segunda copia independente do repositorio e das evidencias em
armazenamento de backup pessoal; este procedimento nao configura sincronizacao
automatica nem garante recuperacao da conta GitHub.

O resultado do teste de recuperacao desta entrega esta em
`VERIFICACAO_RECUPERACAO.md`.

## Auditoria ampliada do mesmo dia

O arquivo original de 893 mensagens foi preservado. Um snapshot posterior com 911
mensagens esta em `auditoria/snapshot_atualizado/TRANSCRICAO.md`. Os 421 blocos SQL
receberam catalogo de origem, retorno e estado; 12 bases sem cerca SQL do usuario
foram extraidas e 43 anexos com SQL aparente foram identificados. Consultar
`auditoria/REGISTRO_DECISOES.md` para 62 decisoes e evolucoes, e
`auditoria/BASES_DE_REFERENCIA.md` para escolher a base correta da tarefa.

Duas fontes externas adicionais foram recuperadas. Seis arquivos historicos
nao foram encontrados mesmo apos pesquisa por nome nas raizes conhecidas:
ver `auditoria/LACUNAS_E_PENDENCIAS.md`. A frase zero ausencias do primeiro pacote
se referia somente aos 238 anexos selecionados, nao a todos os arquivos citados.

O teste ampliado usa `scripts/verificar_pacote.mjs` e manifesto SHA-256 para
conferir todos os arquivos selecionados apos download do GitHub. Para instrucoes
de ambiente, consultar `auditoria/AMBIENTE_E_RECUPERACAO.md`.

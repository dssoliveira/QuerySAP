# Teste de recuperacao do QuerySAP

Data: 22/10/2026.

## Procedimento executado

1. Publicado o commit `a386388dcb20a670252f8a8d436fb1e27b9e8dbf` no GitHub.
2. Feito um clone novo de `https://github.com/dssoliveira/QuerySAP.git` em
   `C:\Users\danilo.santos\Documents\Codex\QuerySAP-recuperacao-20261022`.
   A pasta original do projeto nao foi substituida.
3. Executado `scripts/verificar_recuperacao.ps1` contra essa copia baixada.
4. Conferidos os 238 anexos com seus hashes SHA-256 do inventario.
5. Conferida existencia de seis documentos essenciais (instrucoes, continuidade,
   memoria complementar, transcricao, query de faturamento e README).
6. Executado `git fsck --full`, sem erro.

Resultado: OK. O material arquivado pode ser baixado do remoto, sem depender dos
caminhos originais de anexos ou dos arquivos temporarios desta estacao.

## Conteudo preservado nesta entrega

- 893 mensagens visiveis recuperadas da sessao local, em transcricao textual.
- 421 blocos SQL distintos extraidos com indice de origem.
- 238 anexos citados, em copias com integridade conferida.
- Memorias preexistentes mantidas e memoria complementar de outubro.
- Instrucoes AGENTS.md e roteiro de retomada CONTINUIDADE.md.

O conjunto arquivado ocupa aproximadamente 27,35 MB antes da compressao Git.
A busca textual por formatos comuns de tokens e chaves privadas nao encontrou
ocorrencias. Arquivos de autenticacao e configuracoes secretas do aplicativo
nao foram incluidos no conjunto.

## Limites do teste

Este e um teste de download e integridade de arquivos, nao de execucao no SAP.
Nao instala drivers, VPN, banco ou permissoes. Nao reabre automaticamente a
interface original do chat nem garante que o registro local contenha mensagens
que ja nao estavam disponiveis. Os anexos cobertos sao os selecionados no
inventario; outras referencias externas nao sao declaradas como protegidas.

As proximas mudancas exigem novo commit e push. O script de verificacao pode
ser repetido em outra estacao com PowerShell e Git instalados.

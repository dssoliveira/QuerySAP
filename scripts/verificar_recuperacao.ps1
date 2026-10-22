param([Parameter(Mandatory=$true)][string]$ClonePath)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ClonePath).Path
$inventory = Import-Csv -LiteralPath (Join-Path $root 'arquivo_chat/INVENTARIO_ANEXOS.csv')
$checked = 0
foreach ($record in $inventory) {
    if ($record.estado -ne 'Copiado e conferido') { continue }
    $target = Join-Path $root ('arquivo_chat/'+$record.destino)
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Arquivo ausente: $($record.destino)" }
    $actual = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
    if ($actual -ne $record.sha256) { throw "Hash divergente: $($record.destino)" }
    $checked++
}
$required = @('AGENTS.md','CONTINUIDADE.md','MEMORIA_COMPLEMENTAR_2026-10-22.md','arquivo_chat/TRANSCRICAO.md','FATURAMENTO_DREX_METAS_ATUALIZADA.sql','README.md')
foreach ($file in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $file))) { throw "Documento essencial ausente: $file" }
}
git -C $root fsck --full
if ($LASTEXITCODE -ne 0) { throw 'Falha no git fsck' }
$commit = git -C $root rev-parse HEAD
[pscustomobject]@{commit=$commit;anexos_conferidos=$checked;documentos_essenciais=$required.Count;resultado='OK'} | ConvertTo-Json

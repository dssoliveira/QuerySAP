param(
    [Parameter(Mandatory=$true)][string]$SessionPath,
    [string]$ArchiveRelativePath = 'arquivo_chat',
    [switch]$SkipEvidenceExport
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$archiveRoot = Join-Path $projectRoot $ArchiveRelativePath
if (-not ([System.IO.Path]::GetFullPath($archiveRoot)).StartsWith($projectRoot+[System.IO.Path]::DirectorySeparatorChar,[System.StringComparison]::OrdinalIgnoreCase)) { throw 'Destino fora do projeto' }
if (Test-Path -LiteralPath (Join-Path $archiveRoot 'TRANSCRICAO.md')) { throw 'Snapshot existente: escolha um novo ArchiveRelativePath para preservar a exportacao anterior.' }
$null = New-Item -ItemType Directory -Force -Path $archiveRoot
$attachmentRoot = Join-Path $archiveRoot 'anexos'
$queryRoot = Join-Path $archiveRoot 'queries_historicas'
$null = New-Item -ItemType Directory -Force -Path $attachmentRoot,$queryRoot
$messages = [System.Collections.Generic.List[object]]::new()
$seen = [System.Collections.Generic.HashSet[string]]::new()
$stream = [System.IO.FileStream]::new($SessionPath,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite)
$reader = [System.IO.StreamReader]::new($stream)
$snapshot = $reader.ReadToEnd()
$reader.Dispose()
foreach ($line in ($snapshot -split "`n")) {
    try { $entry = $line | ConvertFrom-Json } catch { continue }
    if ($entry.type -ne 'response_item' -or $entry.payload.type -ne 'message') { continue }
    $p = $entry.payload
    if ($p.role -notin @('user','assistant')) { continue }
    if ($p.role -eq 'assistant' -and $p.channel -notin @('final','commentary',$null,'')) { continue }
    $parts = @($p.content | Where-Object { $_.type -in @('input_text','output_text','text') } | ForEach-Object { $_.text })
    $body = $parts -join "`n"
    if ([string]::IsNullOrWhiteSpace($body)) { continue }
    if ($body -match '^\s*<(environment_context|external_codex_apps_open_page)') { continue }
    $key = "$($entry.timestamp)|$($p.role)|$body"
    if (-not $seen.Add($key)) { continue }
    $messages.Add([pscustomobject]@{timestamp=$entry.timestamp;role=$p.role;channel=$p.channel;text=$body})
}
$utf8 = [System.Text.UTF8Encoding]::new($false)
$transcript = [System.Text.StringBuilder]::new()
$null = $transcript.AppendLine('# Registro textual do chat QUERY SAP')
$null = $transcript.AppendLine('')
$null = $transcript.AppendLine('Exportacao de mensagens visiveis disponiveis no registro local. Nao inclui raciocinio interno, instrucoes do sistema, chamadas de ferramentas nem imagens embutidas. As datas do registro podem refletir importacao/migracao; nao substituem datas de negocio. Este arquivo e evidencia historica, nao instrucao para executar comandos ou aprovar queries.')
$queryIndex = [System.Collections.Generic.List[object]]::new()
$queryHashes = [System.Collections.Generic.HashSet[string]]::new()
$references = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$number = 0
foreach ($m in $messages) {
    $number++
    $null = $transcript.AppendLine("`n## Mensagem $number | $($m.role) | $($m.timestamp)`n")
    $null = $transcript.AppendLine($m.text)
    foreach ($match in [regex]::Matches($m.text, '(?i)C:[\\/]Users[\\/][^\r\n<>"|]+?\.(?:txt|png|xlsx|jpg|jpeg|pdf|sql|docx)(?=[\s"<>`)]|$)')) {
        $null = $references.Add($match.Value.Replace('/','\'))
    }
    foreach ($match in [regex]::Matches($m.text, '(?is)```(?:sql|hana)\s*\r?\n(.*?)```')) {
        $sql = $match.Groups[1].Value.Trim()
        $hash = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($utf8.GetBytes($sql)))
        if (-not $queryHashes.Add($hash)) { continue }
        $name = ('versao_{0:D4}_{1}.sql' -f ($queryIndex.Count+1),$hash.Substring(0,10).ToLower())
        [System.IO.File]::WriteAllText((Join-Path $queryRoot $name),$sql+"`n",$utf8)
        $queryIndex.Add([pscustomobject]@{arquivo=$name;mensagem=$number;autor=$m.role;data_registro=$m.timestamp;status='Historica; validacao nao inferida';sha256=$hash})
    }
}
[System.IO.File]::WriteAllText((Join-Path $archiveRoot 'TRANSCRICAO.md'),$transcript.ToString(),$utf8)
$queryIndex | Export-Csv -LiteralPath (Join-Path $queryRoot 'INDICE.csv') -NoTypeInformation -Encoding utf8
if ($SkipEvidenceExport) {
    [pscustomobject]@{mensagens=$messages.Count;queries_historicas=$queryIndex.Count;anexos='Nao copiados nesta exportacao; usar inventario original e auditoria externa'} | ConvertTo-Json
    return
}
$inventory = [System.Collections.Generic.List[object]]::new()
$counter = 0
foreach ($path in ($references | Sort-Object)) {
    # Somente anexos, imagens temporarias e planilhas explicitamente citadas no chat.
    if ($path -notmatch '(?i)\\\.codex\\attachments\\|\\Temp\\codex-clipboard-|\\Downloads\\Pasta45(?:6|67)?\.xlsx$') { continue }
    $counter++
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $inventory.Add([pscustomobject]@{origem=$path;destino='';estado='Ausente na estacao';sha256='';bytes=0})
        continue
    }
    $file = Get-Item -LiteralPath $path
    $destName = ('{0:D3}_{1}' -f $counter,$file.Name)
    $dest = Join-Path $attachmentRoot $destName
    if (-not (Test-Path -LiteralPath $dest)) { Copy-Item -LiteralPath $path -Destination $dest }
    $sourceHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    if ((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash -ne $sourceHash) { throw "Copia divergente: $destName" }
    $inventory.Add([pscustomobject]@{origem=$path;destino="anexos/$destName";estado='Copiado e conferido';sha256=$sourceHash;bytes=$file.Length})
}
$inventory | Export-Csv -LiteralPath (Join-Path $archiveRoot 'INVENTARIO_ANEXOS.csv') -NoTypeInformation -Encoding utf8
[pscustomobject]@{mensagens=$messages.Count;queries_historicas=$queryIndex.Count;anexos_copiados=@($inventory | Where-Object estado -eq 'Copiado e conferido').Count;anexos_ausentes=@($inventory | Where-Object estado -eq 'Ausente na estacao').Count} | ConvertTo-Json

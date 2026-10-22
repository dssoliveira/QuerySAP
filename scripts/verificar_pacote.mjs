import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const defaultRoot=path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const create=process.argv.includes('--criar-manifesto');
const root=path.resolve(process.argv.find((a,i)=>i>1&&!a.startsWith('--'))??defaultRoot);
const manifestPath=path.join(root,'auditoria','MANIFESTO_SHA256.json');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex').toUpperCase();
const normalize=(b,mode)=>mode==='texto_LF'?Buffer.from(b.toString('utf8').replaceAll('\r\n','\n')):b;
if(create){
 const listed=execFileSync('git',['ls-files','--cached','--others','--exclude-standard','-z'],{cwd:root}).toString('utf8').split('\0').filter(Boolean);
 const records=[...new Set(listed)].filter(f=>f!=='auditoria/MANIFESTO_SHA256.json').sort().map(file=>{
  const bytes=fs.readFileSync(path.join(root,file));
  const mode=/^(?:arquivo_chat|auditoria)\//.test(file)?'bytes':'texto_LF';
  return {arquivo:file,modo:mode,sha256:hash(normalize(bytes,mode))};
 });
 fs.writeFileSync(manifestPath,JSON.stringify({versao:1,data_referencia:'2026-10-22',exclui:'O proprio manifesto; hashes nao substituem controle de acesso',arquivos:records},null,2)+'\n','utf8');
 console.log(JSON.stringify({manifesto_criado:true,arquivos:records.length}));
}
const manifest=JSON.parse(fs.readFileSync(manifestPath,'utf8'));
for(const r of manifest.arquivos){
 const file=path.resolve(root,r.arquivo);
 if(!file.startsWith(root+path.sep))throw new Error('Caminho fora do projeto no manifesto');
 if(!fs.existsSync(file))throw new Error('Ausente: '+r.arquivo);
 if(hash(normalize(fs.readFileSync(file),r.modo))!==r.sha256)throw new Error('Hash divergente: '+r.arquivo);
}
// Verificar completude do inventario em relacao ao checkout recuperado.
const tracked=execFileSync('git',['ls-files','-z'],{cwd:root}).toString('utf8').split('\0').filter(Boolean);
const set=new Set(manifest.arquivos.map(a=>a.arquivo));
for(const file of tracked)if(file!=='auditoria/MANIFESTO_SHA256.json'&&!set.has(file))throw new Error('Arquivo versionado fora do manifesto: '+file);
const source=fs.readFileSync(path.join(root,'auditoria/snapshot_atualizado/TRANSCRICAO.md'),'utf8');
const old=fs.readFileSync(path.join(root,'arquivo_chat/TRANSCRICAO.md'),'utf8');
const sections=text=>[...text.matchAll(/^## Mensagem (\d+) \| (user|assistant) \| ([^\r\n]+)\r?\n/gm)].map((m,i,a)=>({id:m[1],role:m[2],body:text.slice(m.index+m[0].length,a[i+1]?.index??text.length).trim()}));
const older=sections(old),newer=sections(source);
for(let i=0;i<older.length;i++)if(older[i].id!==newer[i]?.id||older[i].role!==newer[i]?.role||older[i].body!==newer[i]?.body)throw new Error('Transcricao antiga divergente no prefixo: '+i);
const stats=JSON.parse(fs.readFileSync(path.join(root,'auditoria/ESTATISTICAS.json'),'utf8'));
if(newer.length!==stats.mensagens_snapshot)throw new Error('Contagem de mensagens divergente');
const sqlFiles=fs.readdirSync(path.join(root,'arquivo_chat/queries_historicas')).filter(f=>f.endsWith('.sql'));
if(sqlFiles.length!==stats.queries_catalogadas)throw new Error('Contagem SQL divergente');
execFileSync('git',['fsck','--full'],{cwd:root,stdio:'pipe'});
const head=execFileSync('git',['rev-parse','HEAD'],{cwd:root}).toString().trim();
console.log(JSON.stringify({resultado:'OK',commit:head,arquivos_conferidos:manifest.arquivos.length,mensagens_originais_preservadas:older.length,mensagens_snapshot:newer.length,SQL_catalogados:sqlFiles.length},null,2));

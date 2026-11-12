Add-Type -AssemblyName System.IO.Compression.FileSystem
$z=[IO.Compression.ZipFile]::OpenRead((Join-Path $PWD 'RES406_Spring2026_Datasheet.xlsx'))
function ReadXml($p){$e=$z.GetEntry($p); if($e){$sr=[IO.StreamReader]::new($e.Open()); $v=$sr.ReadToEnd(); $sr.Close(); return [xml]$v}}
$ss=ReadXml 'xl/sharedStrings.xml'
$strings=@($ss.sst.si | ForEach-Object { $_.InnerText })
$wb=ReadXml 'xl/workbook.xml'; $rels=ReadXml 'xl/_rels/workbook.xml.rels'
$out=[Collections.Generic.List[string]]::new()
foreach($s in $wb.workbook.sheets.sheet){
$rid=$s.GetAttribute('id','http://schemas.openxmlformats.org/officeDocument/2006/relationships'); $t=($rels.Relationships.Relationship | Where-Object Id -eq $rid).Target
$p=if($t.StartsWith('/')){$t.TrimStart('/')}else{'xl/'+$t}
$x=ReadXml $p
$out.Add("SHEET: $($s.name)")
foreach($r in $x.worksheet.sheetData.row){$cells=@(foreach($c in $r.c){$v=$c.v; if($c.t -eq 's'){$v=$strings[[int]$v]}elseif($c.t -eq 'inlineStr'){$v=$c.is.InnerText};if($null -ne $v -and "$v" -ne ''){"$($c.r)=$($v -replace '[\r\n]+',' ')"}});if($cells.Count){$out.Add(($cells -join ' | '))}}
}
$out | Set-Content workbook_inspection.txt
$z.Dispose()


param(
  [Parameter(Mandatory=$true)][string]$Zip,
  [Parameter(Mandatory=$true)][string]$DestRoot
)
Add-Type -AssemblyName System.IO.Compression.FileSystem
if(!(Test-Path -LiteralPath $Zip)){ Write-Error "Nie ma pliku: $Zip"; exit 1 }
$archive = [IO.Compression.ZipFile]::OpenRead($Zip)
$entry   = $archive.Entries | Where-Object { $_.FullName -match '(^|/)+addon\.xml$' } | Select-Object -First 1
if(-not $entry){ $archive.Dispose(); Write-Error "Brak addon.xml w $Zip"; exit 1 }
$sr = New-Object IO.StreamReader ($entry.Open())
[xml]$xml = $sr.ReadToEnd()
$sr.Close(); $archive.Dispose()
$id  = $xml.addon.id
$ver = $xml.addon.version
$destDir = Join-Path $DestRoot $id
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$destZip = Join-Path $destDir ("{0}-{1}.zip" -f $id,$ver)
Copy-Item -LiteralPath $Zip -Destination $destZip -Force
Write-Host "OK -> $destZip"

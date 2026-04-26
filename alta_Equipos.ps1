param([string]$CsvPath)
Write-Host "`nCreacion de Equipos" -ForegroundColor Cyan
$BaseDN = (Get-ADDomain).DistinguishedName
$fichero = Import-Csv -Path $CsvPath -Delimiter ':'
foreach($line in $fichero) {
    $Path = ($line.Path).Trim() -replace 'DC=tirant-res,DC=mylocal', $BaseDN
    $Path = $Path -replace 'DC=tirant,DC=mylocal', $BaseDN
    try {
        if (Get-ADComputer -Filter "Name -eq '$($line.Computer)'" -ErrorAction SilentlyContinue) {
            Write-Host "Equipo $($line.Computer) ya existe" -ForegroundColor Yellow
        } else {
            New-ADComputer -Name $line.Computer -SamAccountName $line.Computer -Path $Path -Enabled $true -ErrorAction Stop
            Write-Host "Equipo $($line.Computer) creado correctamente" -ForegroundColor Green
        }
    } catch { Write-Host "Error creando equipo $($line.Computer): $($_.Exception.Message)" -ForegroundColor Red }
}

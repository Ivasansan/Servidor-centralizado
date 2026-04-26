param([string]$CsvPath)
Write-Host "`nCreacion de Grupos" -ForegroundColor Cyan
$BaseDN = (Get-ADDomain).DistinguishedName
$fichero = Import-Csv -Path $CsvPath -Delimiter ':'
foreach($line in $fichero) {
    $Path = ($line.Path).Trim() -replace 'DC=tirant-res,DC=mylocal', $BaseDN
    $Path = $Path -replace 'DC=tirant,DC=mylocal', $BaseDN
    try {
        if (Get-ADGroup -Filter "Name -eq '$($line.Name)'" -SearchBase $Path -ErrorAction SilentlyContinue) {
            Write-Host "Grupo $($line.Name) ya existe" -ForegroundColor Yellow
        } else {
            New-ADGroup -Name $line.Name -Description $line.Description -GroupCategory $line.Category -GroupScope $line.Scope -Path $Path -ErrorAction Stop
            Write-Host "Grupo $($line.Name) creado correctamente" -ForegroundColor Green
        }
    } catch { Write-Host "Error creando grupo $($line.Name): $($_.Exception.Message)" -ForegroundColor Red }
}

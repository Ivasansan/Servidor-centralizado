$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptsPath = Join-Path $BasePath "scripts"
$CsvPath = Join-Path $BasePath "ficheros-csv"
function Show-Menu {
    Clear-Host
    Write-Host "================ Menu principal - Gestion de objetos Tirant ================" -ForegroundColor Cyan
    Write-Host "1: Crear estructura completa desde CSV."
    Write-Host "2: Consultar objetos del subsistema."
    Write-Host "S: Salir."
}
function Comprobar-ModuloAD { Import-Module ActiveDirectory -ErrorAction Stop }
function Crear-Estructura {
    Clear-Host
    Write-Host "Creacion de estructura completa de Tirant" -ForegroundColor Cyan
    Write-Host "Dominio detectado: $((Get-ADDomain).DNSRoot)"
    Write-Host "Base DN detectado: $((Get-ADDomain).DistinguishedName)"
    & (Join-Path $ScriptsPath "alta_UnidadesOrg.ps1") -CsvPath (Join-Path $CsvPath "unidades_org.csv")
    & (Join-Path $ScriptsPath "alta_Grupos.ps1") -CsvPath (Join-Path $CsvPath "grupos.csv")
    & (Join-Path $ScriptsPath "alta_Equipos.ps1") -CsvPath (Join-Path $CsvPath "equipos.csv")
    & (Join-Path $ScriptsPath "alta_Usuarios.ps1") -CsvPath (Join-Path $CsvPath "usuarios.csv")
    Write-Host "`nProceso finalizado." -ForegroundColor Green
}
function Consultar-Objetos {
    Clear-Host
    $BaseDN = (Get-ADDomain).DistinguishedName
    $TirantDN = "OU=Tirant,$BaseDN"
    Write-Host "Consulta de objetos del subsistema Tirant" -ForegroundColor Cyan
    Write-Host "Ruta consultada: $TirantDN"
    Write-Host "`n--- Unidades Organizativas ---" -ForegroundColor Yellow
    Get-ADOrganizationalUnit -SearchBase $TirantDN -Filter * | Select-Object Name, DistinguishedName | Format-Table -AutoSize
    Write-Host "`n--- Grupos ---" -ForegroundColor Yellow
    Get-ADGroup -SearchBase $TirantDN -Filter * | Select-Object Name, GroupScope, GroupCategory | Format-Table -AutoSize
    Write-Host "`n--- Equipos ---" -ForegroundColor Yellow
    Get-ADComputer -SearchBase $TirantDN -Filter * | Select-Object Name, Enabled | Format-Table -AutoSize
    Write-Host "`n--- Usuarios ---" -ForegroundColor Yellow
    Get-ADUser -SearchBase $TirantDN -Filter * -Properties Department, EmailAddress, Enabled | Select-Object SamAccountName, Name, Department, EmailAddress, Enabled | Format-Table -AutoSize
}
try { Comprobar-ModuloAD } catch { Write-Host "No se encuentra el modulo ActiveDirectory." -ForegroundColor Red; Pause; exit }
do {
    Show-Menu
    $input = Read-Host "Por favor, pulse una opcion"
    switch ($input.ToUpper()) {
        '1' { Crear-Estructura; Pause }
        '2' { Consultar-Objetos; Pause }
        'S' { Write-Host "Salimos de la App"; return }
        default { Write-Host "Opcion no valida" -ForegroundColor Red; Pause }
    }
} until ($input.ToUpper() -eq 'S')

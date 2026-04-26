param([string]$CsvPath)

Write-Host "`nCreacion de Unidades Organizativas" -ForegroundColor Cyan
$BaseDN = (Get-ADDomain).DistinguishedName

function Nueva-OU-Segura {
    param(
        [string]$Name,
        [string]$Description,
        [string]$Path
    )

    $Name = $Name.Trim()
    $Path = $Path.Trim()
    $Description = $Description.Trim()
    $DN = "OU=$Name,$Path"

    try {
        Get-ADOrganizationalUnit -Identity $DN -ErrorAction Stop | Out-Null
        Write-Host "OU $Name ya existe en $Path" -ForegroundColor Yellow
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        try {
            Write-Host "Creando OU $Name en $Path" -ForegroundColor Gray
            New-ADOrganizationalUnit -Name $Name -Description $Description -Path $Path -ProtectedFromAccidentalDeletion:$false -ErrorAction Stop
            Write-Host "OU $Name creada correctamente" -ForegroundColor Green
        }
        catch {
            Write-Host "Error creando OU $Name en $Path -> $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error comprobando OU $Name en $Path -> $($_.Exception.Message)" -ForegroundColor Red
    }
}

# IMPORTANTE:
# No se usa el Path del CSV para crear las UO porque puede venir con caracteres ocultos/codificacion.
# Se construyen las rutas limpias desde el DN real del dominio.
$TirantDN = "OU=Tirant,$BaseDN"

Nueva-OU-Segura -Name "Tirant" -Description "Unidad organizativa principal del centro Tirant" -Path $BaseDN

$Departamentos = @(
    @{Name="ComiteAcceso"; Description="OU Departamento Comite de acceso"},
    @{Name="VisitasGuiadas"; Description="OU Departamento Visitas guiadas"},
    @{Name="ProcesosEvaluacion"; Description="OU Departamento Procesos de evaluacion"},
    @{Name="AdminSistemas"; Description="OU Departamento Administracion de sistemas"}
)

foreach ($dep in $Departamentos) {
    Nueva-OU-Segura -Name $dep.Name -Description $dep.Description -Path $TirantDN
    $DepDN = "OU=$($dep.Name),$TirantDN"
    Nueva-OU-Segura -Name "Usuarios" -Description "OU Usuarios - $($dep.Description)" -Path $DepDN
    Nueva-OU-Segura -Name "Equipos" -Description "OU Equipos - $($dep.Description)" -Path $DepDN
}

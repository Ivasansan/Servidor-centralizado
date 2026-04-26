param([string]$CsvPath)
Write-Host "`nCreacion de Usuarios" -ForegroundColor Cyan
$BaseDN = (Get-ADDomain).DistinguishedName
$fichero = Import-Csv -Path $CsvPath -Delimiter '*'
foreach($linea in $fichero) {
    $Path = ($linea.Path).Trim() -replace 'DC=tirant-res,DC=mylocal', $BaseDN
    $Path = $Path -replace 'DC=tirant,DC=mylocal', $BaseDN
    try {
        if (Get-ADUser -Filter "SamAccountName -eq '$($linea.Account)'" -ErrorAction SilentlyContinue) {
            Write-Host "Usuario $($linea.Account) ya existe" -ForegroundColor Yellow
            continue
        }
        $passAccount = ConvertTo-SecureString $linea.Password -AsPlainText -Force
        $nameLarge = "$($linea.Name) $($linea.Surname) $($linea.'Last Name')"
        $Habilitado = $true
        if($linea.Enabled -match 'N|false') { $Habilitado = $false }
        $timeExp = (Get-Date).AddDays([int]$linea.ExpirationAccount)
        New-ADUser -SamAccountName $linea.Account -UserPrincipalName "$($linea.Account)@$((Get-ADDomain).DNSRoot)" -Name $linea.Account `
            -Surname "$($linea.Surname) $($linea.'Last Name')" -DisplayName $nameLarge -GivenName $linea.Name `
            -Description "Cuenta de $nameLarge" -EmailAddress $linea.Email `
            -Department $linea.Departament -AccountPassword $passAccount -Enabled $Habilitado `
            -CannotChangePassword $false -ChangePasswordAtLogon $true -PasswordNotRequired $false `
            -Path $Path -AccountExpirationDate $timeExp -LogonWorkstations $linea.Computer -ErrorAction Stop
        $horassesion = $linea.NetTime -replace ' ',''
        if ($horassesion) { net user $linea.Account /times:$horassesion /domain | Out-Null }
        if ($linea.Group) { Add-ADGroupMember -Identity $linea.Group -Members $linea.Account -ErrorAction SilentlyContinue }
        Write-Host "Usuario $($linea.Account) creado correctamente" -ForegroundColor Green
    } catch { Write-Host "Error creando usuario $($linea.Account): $($_.Exception.Message)" -ForegroundColor Red }
}

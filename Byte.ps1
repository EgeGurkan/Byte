$storedb = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db"
if (-not (Test-Path $storedb)) { exit }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction SilentlyContinue
}
foreach ($mod in @('NTFSSecurity', 'AdoSQLiteModule')) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Install-Module -Name $mod -Force -Scope CurrentUser -ErrorAction SilentlyContinue
    }
    Import-Module $mod -ErrorAction SilentlyContinue
}

$perm = Get-NTFSAccess -Path $storedb -ErrorAction SilentlyContinue
if ($perm.AccessRights -contains 'FullControl') {
    Invoke-AdoSQLiteNonQuery -Database $storedb -Query 'DELETE FROM SearchProducts' -ErrorAction SilentlyContinue
    Invoke-AdoSQLiteNonQuery -Database $storedb -Query 'DELETE FROM LocalizedProperties' -ErrorAction SilentlyContinue

    Disable-NTFSAccessInheritance -Path $storedb -ErrorAction SilentlyContinue
    Get-NTFSAccess -Path $storedb | ForEach-Object {
        Remove-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Write,Modify,FullControl -ErrorAction SilentlyContinue
        Add-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Read -ErrorAction SilentlyContinue
    }
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
Install-Module -Name NTFSSecurity -Force -Scope CurrentUser
Install-Module -Name AdoSQLiteModule -Force -Scope CurrentUser
Import-Module NTFSSecurity
Import-Module AdoSQLiteModule

$storedb = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db"

$perm = Get-NTFSAccess $storedb

If ($perm[0].AccessRights -eq 'FullControl') {
    Invoke-AdoSQLiteNonQuery -Database $storedb -Query 'DELETE FROM SearchProducts'
    Invoke-AdoSQLiteNonQuery -Database $storedb -Query 'DELETE FROM LocalizedProperties'

    Disable-NTFSAccessInheritance $storedb
    Get-NTFSAccess $storedb | ForEach-Object {
        Remove-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Write,Modify  
        Add-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Read
    }
}
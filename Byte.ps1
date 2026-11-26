$localState = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState"

# store.db veya store-<hash> dosyalarını bul (geçici SQLite dosyalarını hariç tut)
$storeDbs = Get-ChildItem -Path $localState -File -Filter "store*" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '(-wal|-shm|-journal)$' }

if (-not $storeDbs) { exit }

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

# Dosyayı kilitleyen işlemleri sonlandır ve kilidin serbest kalmasını bekle
Stop-Process -Name "WinStore.App", "backgroundTaskHost" -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 500

foreach ($file in $storeDbs) {
    $storedb = $file.FullName
    $perm = Get-NTFSAccess -Path $storedb -ErrorAction SilentlyContinue

    if ($perm.AccessRights -match 'FullControl') {
        # Arka plan görevi yeniden başladıysa tekrar sonlandır
        Stop-Process -Name "backgroundTaskHost" -Force -ErrorAction SilentlyContinue

        Invoke-AdoSQLiteNonQuery -Database $storedb -Query 'DELETE FROM SearchProducts' -ErrorAction SilentlyContinue
        Invoke-AdoSQLiteNonQuery -Database $storedb -Query 'DELETE FROM LocalizedProperties' -ErrorAction SilentlyContinue

        Disable-NTFSAccessInheritance -Path $storedb -ErrorAction SilentlyContinue
        Get-NTFSAccess -Path $storedb | ForEach-Object {
            Remove-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Write,Modify,FullControl -ErrorAction SilentlyContinue
            Add-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Read -ErrorAction SilentlyContinue
        }
    }
}
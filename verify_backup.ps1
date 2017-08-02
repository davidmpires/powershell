$date = Get-Date
$appVersion = "10.3"
$bin_location    = "C:\Program Files\Tableau\Tableau Server\" + $appVersion + "\bin"
$backups_folder  = "C:\Backup\"
$backups_file          = "tabsvc_"+ $date.Year+$date.Month+$date.Day
$tabadmin = $bin_location + "\tabadmin.exe"
$strFileName = $backups_folder+$backups_file+".tsbak"
$file = "C:\Backup\verification.txt"
$Text = Select-String -Path C:\Backup\verification.txt  -Pattern "===== Verify database completed successfully."


#Run backup verification to a txt file


IF (Test-Path $strFileName)
{
& "$tabadmin" verify_database -f $strFileName | Out-File $file
Write-Host "File Found"
    IF($Text -ne $null)
    {
    Write-Host "String Checked"
    exit 0
    }
    ELSE
    {
    Write-Host "Error reading the string"
    exit 20
    }
}
ELSE
{Write-Host "File Not Found"
exit 20
}


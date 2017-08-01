$date = Get-Date
$appVersion = "10.3"
$bin_location    = "C:\Program Files\Tableau\Tableau Server\" + $appVersion + "\bin"
$backups_folder  = "C:\Backup\"
$backups_file          = "tabsvc_"+ $date.Year+$date.Month+$date.Day
$tabadmin = $bin_location + "\tabadmin.exe"
$strFileName = $backups_folder+$backups_file+".tsbak"

#Query file to find string

$Text = Select-String -Path C:\Backup\verification.txt  -Pattern "===== Verify database completed successfully."

 IF($Text -ne $null) 
 {
  Write-Host "Sucess"
  exit 0
 }
 ELSE{
 Write-Host "Error reading the string"
 exit 20
 }
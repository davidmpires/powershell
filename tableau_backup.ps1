#######################################################################################################
#     
#        PROGRAM: TableauBackup.ps1
#
#    DESCRIPTION: Powershell script to run tableau server backups, email results to server admin, 
#                 and purge old backups.
#
#
#     WRITTEN BY:  Glen Robinson (Interworks UK)
#
#
#######################################################################################################


$EmailSubject = "Tableau Server Backup and Log Zip: " + $env:COMPUTERNAME + " " + $date
$smtp_server = "smtprelay.vt.ch"
$smtp_port = 25
$smtp_from = "Tableau_Acceptance@vontobel.ch"
$smtp_to = ""

$date = Get-Date
$CrLf = "`r`n"
$DaysToKeep = 5
$CopyFilesToRemote = $True
$PurgeOldFiles = $True

$appVersion = "10.3"
$bin_location    = "D:\Programs\Tableau\Tableau Server\" + $appVersion + "\bin"
$backups_folder  = "D:\Backup\Tableau\"
$remote_Backups_Folder = "\\RemoteServer\ShareName\"
$backups_file          = "tabsvc_"+ $date.Year+$date.Month+$date.Day
$zipfile               = "logs_"+ $date.Year+$date.Month+$date.Day+".zip"
$tabadmin = $bin_location + "\tabadmin.exe"

#Run Zip Logs
$EmailBody = "***** Zip Log Files *****" +$CrLf
$output = &"$tabadmin" ziplogs -n -p -l -a -f $backups_folder$zipfile
$output = @($output -split '`n')

foreach ($line in $output)
 {
   $emailbody += $line +$CrLf
 }

# Run backups
$Emailbody += $crlf + "***** Backup  Files *****" + $CrLf
$output = &"$tabadmin" backup -v $Backups_folder$Backups_file
$output = @($output -split '`n')

foreach ($line in $output)
 {
   $emailbody += $line +$CrLf
 }

# Run Clean Up
$Emailbody += $crlf + "***** Clean Up old Log Files *****" + $CrLf
$output = &"$tabadmin" cleanup
$output = @($output -split '`n')

foreach ($line in $output)
 {
   $emailbody += $line +$CrLf
 }

<#
If ($CopyFilesToRemote -eq $True)
 {
  copy-Item -path $backups_folder$zipfile -destination $remote_Backups_Folder$zipfile
  copy-Item -path $backups_folder$backups_file".tsbak" -Destination $remote_Backups_Folder$backups_file".tsbak"
 }
#> 

# Delete old backup and zip log Files
If ($PurgeOldFiles -eq $True)
 {
  # Delete local copies of backups and zip logs
  $oldfiles = Get-ChildItem $backups_folder -file | Where-object {$_.LastWriteTime -lt $date.AddDays(-$DaysToKeep)}
  if($oldfiles.count -gt 0)
   {
    $oldfiles.Delete()
   }

<#
  # Delete Remote copies of  Old files
  if ($CopyFilesToRemote -eq $True)
   {
    $oldfiles = Get-ChildItem $remote_backups_folder -file | Where-object {$_.LastWriteTime -lt $date.AddDays(-$DaysToKeep)}
    if($oldfiles.count -gt 0)
     {
      $oldfiles.Delete()
     }
   } 
   #>
 } 

<#  
#Email Results to Admin

$msg = new-object system.net.mail.mailmessage
$smtp = new-object Net.Mail.SmtpClient($smtp_server, $smtp_port)
$smtp.Credentials = New-Object System.Net.NetworkCredential;
$smtp.Timeout = 1000000

$msg.From = $smtp_from
$msg.To.Add($smtp_to)

$msg.subject = $EmailSubject
$msg.body = $EmailBody

$smtp.Send($msg)
$msg.dispose()

#>

#Check Backup Run

$strFileName = $backups_folder+$backups_file+".tsbak"
IF (Test-Path $strFileName)
{Write-Host "Exit 0"
Exit(0)}
 Else
{Write-Host "Exit 20"
Exit(20)}

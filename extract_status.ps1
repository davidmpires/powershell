function Get-ODBCData{  
   param(
         [string]$query,
         [string]$dbServer = "a-tableau.vt.ch",   # DB Server (either IP or hostname)
         [string]$dbName   = "workgroup", # Name of the database
         [string]$dbUser   = "readonly",    # User we'll use to connect to the database/server
         [string]$dbPass   = "v0np@ss",     # Password for the $dbUser
         [string]$port     = "8060"
        )

   $conn = New-Object System.Data.Odbc.OdbcConnection
   $conn.ConnectionString = "Driver={PostgreSQL Unicode(x64)};Server=$dbServer;Port=$port;Database=$dbName;Uid=$dbUser;Pwd=$dbPass;"
   $conn.open()
   $cmd = New-object System.Data.Odbc.OdbcCommand($query,$conn)
   $ds = New-Object system.Data.DataSet
   (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null
   $conn.close()
   $ds.Tables[0]
}



Get-ODBCData -query "Select finish_code
 from _background_tasks 
    where 
    completed_at = (Select Max(completed_at) from _background_tasks
    where job_name = 'Refresh Extracts' and
    subtitle = 'Workbook' and
    title = 'Credit Risk Daily')
" | Out-File D:\Scripts\result.txt

$Text = Select-String -Path D:\Scripts\result.txt  -Pattern 0

IF($Text -ne $null)
    {
    Write-Host "Extract Sucessfull"
    Remove-Item D:\Scripts\result.txt
    exit 0
    }
    ELSE
    {
    Write-Host "Extract Failure"
    exit 1
    }

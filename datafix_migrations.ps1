param(
$databaseUsername,
$databasePassword,
$databaseServerName,
$DataFixMigrationsFolder
)

#Get files in Migrations
Get-ChildItem "$DataFixMigrationsFolder" -Filter *.sql |
ForEach-Object {
    $fileName = [System.IO.Path]::GetFileName($_.FullName)
    $migrationName = $fileName.Split("-")
    $migrationIndex = $migrationName[0]
    #Write-Host = $fileName
    #Write-Host = $migrationIndex
    
    #Check migrations table for Migration Index, if exists dont execute the migration
    #if not execute the migration  #'$migrationIndex'
  
    $results = Invoke-Sqlcmd -ServerInstance $databaseServerName -query "SELECT datafix_migration_index FROM [_datafix-migrations] WHERE datafix_migration_index = '$migrationIndex'" -u $databaseUsername -p $databasePassword -Database BarsDB-Dev -ErrorAction 'Stop'
    
   
    if ($results.count -eq 0)
    {
        Write-Host = "No Datafix Migration Found with Migration Index: $migrationIndex"
        Write-Host = "Added Datafix Migration to _Datafix-Migrations table"
        
      
        
        #Execute the SQL Script in question
        Invoke-Sqlcmd -ServerInstance $databaseServerName -InputFile "$DataFixMigrationsFolder\$fileName" -u $databaseUsername -p $databasePassword -Database BarsDB-Dev -ErrorAction 'Stop'

              #Insert SQL statement
            $insertQuery ="
            INSERT INTO [dbo].[_datafix-migrations]
                        ([datafix_migration_index],
                        [datafix_migration_filename])
            VALUES('$migrationIndex', '$fileName')
                GO
                "
            #Write-Host = $insertQuery
            Invoke-Sqlcmd -ServerInstance $databaseServerName -query $insertQuery -u $databaseUsername -p $databasePassword -Database BarsDB-Dev -ErrorAction 'Stop'        
    }
    
}

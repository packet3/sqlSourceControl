param(
$DataFixMigrationsFolder
)
#get migrations files
$migrationScripts = Get-ChildItem "$DataFixMigrationsFolder" -Filter *.sql
$scriptCount = $migrationScripts.count

$migrationScripts |
ForEach-Object {
    $fileName = [System.IO.Path]::GetFileName($_.FullName)

    #lets check to make sure that the file starts with 5 numbers followed by an underscore followed by capital M and then dash:  00005_DFM-
    #if not fail the build 

    #Test 1 - Do we have a correct FileName format?

    #^([0-9]{5})_([DFM])-(.*)\.sql$  -> This will match 00003_DFM-sdfsdf.sql  but not 8494jjd8j4thisisM.sql
    #$return = $fileName -match '^([0-9]{5})_(DFM{1})-(.*)\.sql$'
    $return = $fileName -match '^([0-9]{5})_(DFM{1})(?:\[AHL])?(?:\[BR])?(?:\[CC])?-(.*)\.sql$'
    #Write-Output $return

    if($return)
    {
        #Test 2 - Is the file sequential named?
        $migrationName = $fileName.Split("_")
        $migrationIndex = $migrationName[0]
        $indextest = $migrationIndex.trimstart('0') -as [int]

        if($lastIndex -gt 0)
        {
            if($indextest  -eq $lastindex )
            {
                #exit writeout duplicate error here
                Write-Output "##vso[task.LogIssue type=error;]There is already a filename with this name: $fileName"
                exit 1
            }

            if($indextest  -gt ($lastindex + 1) )
            {
                #exit writeout gap error here
                Write-Output "##vso[task.LogIssue type=error;]Mismatch in sequntial file we have $scriptCount migration scripts but one file was named grater than the count the file is $fileName"
                exit 1
            }
        }

        $lastIndex = $indextest
      
              

    } else {
        Write-Output "##vso[task.LogIssue type=error;]Incorrect file naming format: $fileName the format should be as an example 00005_DFM-filename.sql"
        exit 1
        
    }

  
    
}
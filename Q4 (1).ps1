function ListFiles
{
    param($folder, $format) 

    if (!$format)  #Part of Q2.2
     {
        $files = get-childitem -Path $folder | Sort-Object BaseName 
     }
     else
     {
         $files = get-childitem -Path $folder `
                 | Where-object {$_.Extension -eq ("." + $format)} `  #Part of Q2.2
                 | Sort-Object BaseName
     }

     $i = 0
     $nFiles = $files.Count

     do 
     {
            #Header with indicator of subset
             Clear-Host
             Header "List of files"
             Write-Host "Folder: " $folder
             Write-Host ("Progress: " + $i.ToString() + "/" + $nFiles)

             $files `
             | select-object BaseName, Extension, ` 
                             @{N = " Size (kb)"; `
                             E = { ($_.Length / 1Kb).ToString("n1").PadLeft(10) } ` 
                             } `
                             -Skip $i ` 
                             -First 10 ` 
             | Format-Table 

             #Press Enter for next batch
             if ($i + 10 -lt $nFiles) 
             {
                $key = Read-Host "Press 'Enter' for next 10 files" 
             }
                $i += 10 
       } while ($i -le $nFiles) 
       } function ListPerFormat
{
     param([string] $downloads) 
     $format = Read-Host "Format" 
     ListFiles $downloads $format 
} 


function DeletePerFormat
{
     param([string] $folder) 
     Clear-Host
     Header "Delete files"
     $format = Read-Host "Format" 

     $files = Get-ChildItem -Path $folder ` 
              |Where-object {$_.Extension -eq ("." + $format)} 

     foreach ($file in $files ) 
     {
         $Confirm = Read-Host `
         -Prompt ("Are you sure you want to delete " + $file + " (Y/N)?") 
         if ($Confirm -eq "Y") 
         {
             Remove-Item ` 
                 -Path $file.Fullname ` 
                 -ErrorAction SilentlyContinue `
                 -ErrorVariable errors
             if ($errors -ne $null) { Write-Host $errors }
             else { Write-Host ($file.Name + " removed") } 
         } #if Confirm
     } # for each file
} #DeletePerFormat 
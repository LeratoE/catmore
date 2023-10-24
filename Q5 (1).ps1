function ListUsers
{
    param ($filter) 
    Clear-Host
    Header "Users"
    #All users
    $users = Get-LocalUser 
    #Account or password expired
     if ($filter -eq "Expired") 
     {
         $users = $users | Where-Object { ( $_.AccountExpires -ne $null `
                                        -and $_.AccountExpires -lt (get-date) )` 
                                     -or ( $_.PasswordExpires -ne $null `
                                        -and $_.Passwordexpires -lt (get-date) )` 
                                       }
    }
    #DescriptIon TPG527C
    if ($filter -eq "TPG527C") 
    {
        $users = $users | Where-Object { $_.Description -eq "TPG527C" } 
    }
    #Select properties and display
    $users | select-object Name, LastLogon, AccountExpires, PasswordExpires ` 
           | Sort Name `
           | Format-Table 
} #ListUsers function AddUser
{
     Clear-Host
     Header "Add user"
     $username = Read-Host "User name" 
     $password = Read-Host -prompt "Password" -AsSecureString 
     $exists = (get-localuser).name -contains $username 

     if (!$exists) 
     {
         $today = get-date 
         $accountExpires = $today.AddDays(-1) 
         new-localuser -name $username ` 
                         -password $password ` 
                         -AccountExpires $accountExpires ` 
                         -Description "TPG527C" 
                         write-host "User " $username " created."
         Add-LocalGroupMember -Group Users -Member $username 
         write-host "User " $username " added to group " Users + "."
     } #Not exists
}#Add user 
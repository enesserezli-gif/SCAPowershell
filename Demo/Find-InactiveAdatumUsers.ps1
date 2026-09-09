$cutoffDate = (Get-Date).AddDays(-30)

Get-ADUser -Server "adatum.com" -Filter * -Properties LastLogonDate, Enabled, UserPrincipalName |
    Where-Object {
        $null -eq $_.LastLogonDate -or $_.LastLogonDate -lt $cutoffDate
    } |
    Select-Object Name, SamAccountName, UserPrincipalName, Enabled, LastLogonDate |
    Sort-Object LastLogonDate, SamAccountName |
    Format-Table -AutoSize
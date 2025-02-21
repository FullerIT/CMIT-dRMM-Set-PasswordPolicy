<# cmit-drmm-set-passwordpolicy.ps1
pellis@cmitsolutions.com
2025-02-20-001

Creates entries for password policy.
Schedule this weekly to ensure it is re-enforced if changed locally.

#>

<# Recommended options:
$PasswordComplexity = 1
$MinimumPasswordLength = 12
$MaximumPasswordAge = 90
$EnableAdminAccount = 0
$EnableGuestAccount = 0
$ClearTextPassword = 0
#>

$PasswordComplexity = $env:drmmPasswordComplexity
$MinimumPasswordLength = $env:drmmMinimumPasswordLength
$MaximumPasswordAge = $env:drmmMaximumPasswordAge
$EnableAdminAccount = $env:drmmEnableAdminAccount
$EnableGuestAccount = $env:drmmEnableGuestAccount
$ClearTextPassword = $env:drmmClearTextPassword

write-host PasswordComplexity: $env:drmmPasswordComplexity
write-host MinimumPasswordLength: $env:drmmMinimumPasswordLength
write-host MaximumPasswordAge: $env:MaximumPasswordAge
write-host EnableAdminAccount: $env:drmmEnableAdminAccount
write-host EnableGuestAccount: $env:drmmEnableGuestAccount
write-host ClearTextPassword: $env:drmmClearTextPassword

<# Testing #>
Function Parse-SecPol($CfgFile){ 
    secedit /export /cfg "$CfgFile" | out-null
    $obj = New-Object psobject
    $index = 0
    $contents = Get-Content $CfgFile -raw
    [regex]::Matches($contents,"(?<=\[)(.*)(?=\])") | %{
        $title = $_
        [regex]::Matches($contents,"(?<=\]).*?((?=\[)|(\Z))", [System.Text.RegularExpressions.RegexOptions]::Singleline)[$index] | %{
            $section = new-object psobject
            $_.value -split "\r\n" | ?{$_.length -gt 0} | %{
                $value = [regex]::Match($_,"(?<=\=).*").value
                $name = [regex]::Match($_,".*(?=\=)").value
                $section | add-member -MemberType NoteProperty -Name $name.tostring().trim() -Value $value.tostring().trim() -ErrorAction SilentlyContinue | out-null
            }
            $obj | Add-Member -MemberType NoteProperty -Name $title -Value $section
        }
        $index += 1
    }
    return $obj
}

Function Set-SecPol($Object, $CfgFile){
   $SecPool.psobject.Properties.GetEnumerator() | %{
        "[$($_.Name)]"
        $_.Value | %{
            $_.psobject.Properties.GetEnumerator() | %{
                "$($_.Name)=$($_.Value)"
            }
        }
    } | out-file $CfgFile -ErrorAction Stop
    secedit /configure /db c:\windows\security\local.sdb /cfg "$CfgFile" /areas SECURITYPOLICY
}

$SecPool = Parse-SecPol -CfgFile C:\Temp.cfg
$SecPool.'System Access'.PasswordComplexity = $PasswordComplexity
$SecPool.'System Access'.MinimumPasswordLength = $MinimumPasswordLength
$SecPool.'System Access'.MaximumPasswordAge = $MaximumPasswordAge
$SecPool.'System Access'.EnableAdminAccount = $EnableAdminAccount
$SecPool.'System Access'.EnableGuestAccount = $EnableGuestAccount
$SecPool.'System Access'.ClearTextPassword = $ClearTextPassword


Set-SecPol -Object $SecPool -CfgFile C:\Temp.cfg
Remove-Item C:\Temp.cfg -Force


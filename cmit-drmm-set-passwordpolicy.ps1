<# cmit-drmm-set-passwordpolicy.ps1
pellis@cmitsolutions.com
2025-01-07-001

Creates entries for password policy.
Schedule this weekly to ensure it is re-enforced if changed locally.

#>

# Define variables for the settings
$complexity = $env:complexity # Boolean, set to 1 to enforce password complexity, 0 to disable
$minAge = $env:minAge # String, Minimum password age in days
$maxAge = $env:maxAge # String, Maximum password age in days
$minLength = $env:minLength # String, Minimum password length
$history = $env:history # String, Password history size

# Enforce password complexity
$complexityKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
$complexityValueName = "PasswordComplexity"
Set-ItemProperty -Path $complexityKey -Name $complexityValueName -Value $complexity -Type DWord

# Set minimum password age
$minAgeKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
$minAgeValueName = "MinimumPasswordAge"
Set-ItemProperty -Path $minAgeKey -Name $minAgeValueName -Value $minAge -Type DWord

# Set maximum password age
$maxAgeKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
$maxAgeValueName = "MaximumPasswordAge"
Set-ItemProperty -Path $maxAgeKey -Name $maxAgeValueName -Value $maxAge -Type DWord

# Enforce password history
$historyKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
$historyValueName = "PasswordHistorySize"
Set-ItemProperty -Path $historyKey -Name $historyValueName -Value $history -Type DWord

# Enforce minimum password length
$minLengthKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
$minLengthValueName = "MinimumPasswordLength"
Set-ItemProperty -Path $minLengthKey -Name $minLengthValueName -Value $minLength -Type DWord
$KeyFile = $PSScriptRoot+ "\AES.key"
$Key = New-Object Byte[] 24   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile


$credential = Get-Credential -Message Password -UserName mvhlab@ger.corp.intel.com
$passwFile = $PSScriptRoot+ '\'+ $credential.UserName+ '.psw'
$credential.Password | ConvertFrom-SecureString -key $Key | Out-File $passwFile

#$credential = Get-Credential -Message Password -UserName ger\mvhlab
#$credential.UserName
#$credential.Password
#$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

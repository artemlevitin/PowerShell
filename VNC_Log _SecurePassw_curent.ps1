$computerList=@{}
$userList=@{}
$currentUtcDate=(Get-Date).ToUniversalTime()

function Run_VNC {

    param ($ComputerName, $compArr)
    
    $pathToConectFile=$PSScriptRoot+ '\ConnectionFolder\' + $ComputerName+ '.vnc'

  "ConnMethod=udp `nHost=$ComputerName" |  Set-Content -Path $pathToConectFile  
   
    & "C:\Program Files\RealVNC\VNC Viewer\vncviewer.exe "  $pathToConectFile      

}

function GetHostName { 
param ($ipAddress)
if (-not $computerList.ContainsKey($ipAddress)) {
try{
        $dnsName = ([System.Net.Dns]::GetHostByAddress($ipAddress)).HostName | ForEach-Object {$_.Substring(0,$_.IndexOf(".")).ToUpper()}
        $computerList[$ipAddress] = $dnsName
        }
catch{ $dnsName = $ipAddress}
        return $dnsName
    } 
    else {
            return $computerList[$ipAddress]
}
 }

 function GetDateInfo{
param($strDate)
$utcDateTime = Get-Date $strDate
return $utcDateTime.ToLocalTime()
 }
 
function GetUserName{
param($loginName)
 if(-not $userList.Contains($loginName) ){
  
 if(-not $loginName.Contains("\")) {
   $userList[$loginName]= $loginName
 }
 else{

 $user = Get-ADuser $loginName.Split('\',2)[1] -server ($loginName.Split('\',2)[0] +'.corp.contoso.com')
 $userList[$loginName]= $user.Name
 }
   return $user.Name
 }
 return $userList[$loginName]
}

function SetCreditinal{
$filePasw = Get-ChildItem -path $PSScriptRoot -filter *.psw -file -ErrorAction silentlycontinue -recurse
$user = $filePasw[0].BaseName
$keyFiles = Get-ChildItem -path $PSScriptRoot -filter AES.key -file -ErrorAction silentlycontinue -recurse 
$key = Get-Content -path $keyFiles[0].Fullname

return New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user, (Get-Content $filePasw[0].FullName | ConvertTo-SecureString -Key $key)
 
}

$numHost= Read-Host -Prompt 'Please type 4 last numbers of host'

if ($numHost-match '^\d{4}$'){
$hostName= 'ha01wvaw'+ $numHost
if((Test-Connection $hostName -Quiet -Count 1)-eq $False){
Write-Host "Host is unreachable"; break}
  $credential = SetCreditinal
  $pathLog = '\\' + $hostName + '\c$\ProgramData\RealVNC-Service'

  New-PSDrive -Name 'VNC_LOG' -PSProvider FileSystem -Root $pathLog -Credential $credential | Out-Null


try{

$pathFile = 'VNC_LOG:\'+ 'vncserver.log'

If((Test-Path -Path $pathFile) -eq $False) 
{
Write-Host "Log folder $hostname is unreachable" break
}
Write-Host 'Log file is:'  $pathLog'\vncserver.log'

$infoLog= Get-Content -path $pathFile 
 
ForEach($item in $infoLog){
 
 if($item -match 'Connections: authenticated:'){
 $itemSplit= $item.Tostring().split(' ')
 $user_Name= GetUsername($itemSplit[9]) 
 
 $connectDate =GetDateInfo($itemSplit[1]) 

 $computer= $itemSplit[6].Substring(0,$itemSplit[6].length-7)

 $color ="white"

 if ($currentUtcDate.DayOfYear -eq $connectDate.DayOfYear){ 
    $computer = GetHostName($computer) 
    $color= "green"   
   }
 
 $info = $connectDate.ToString() + ' '+ $computer + ' '+ $user_Name 
 
 Write-host $info -ForegroundColor $color
 

 } 

 if($item -match 'VNC Viewer closed'){
 $itemSplit= $item.Tostring().split(' ')
  $dissconectDate =GetDateInfo($itemSplit[1]) 
 $computer = $itemSplit[6].Substring(0,$itemSplit[6].length-7)
 if ($currentUtcDate.DayOfYear -eq $dissconectDate.DayOfYear){ 
    $computer = GetHostName($computer)     
    $info = $dissconectDate.ToString()+ ' ' + $computer + ' ('+ $itemSplit[11] +')'
    Write-host $info -ForegroundColor "green"  
 }
  
 }
    }
    }
 catch{ write-host 'Exception;'$_.ScriptStackTrace}


finally{
 Remove-PSDrive 'VNC_LOG'
  }


$nextStep = Read-Host -Prompt 'If need VNC click "Y" '

if($nextStep -like 'y' -or 
$nextStep -like 'yes'){
Run_VNC($hostName)
}

pause
}
else {
write-host "`n You typed no 4 numbers, Run script again and type only 4 last numbers of host `n Example: 2424 for host HA01WVAW2424"
}



$computerList=@{}
$userList=@{}

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

function GetUserName{
param($loginName)
 if(-not $userList.Contains($loginName) ){
 $user = Get-ADuser $loginName.Trim("GER\") 
 $userList[$loginName]= $user.Name
   return $user.Name
 }
 return $userList[$loginName]
}

$numHost= Read-Host -Prompt 'Please type 4 last numbers of host'

if ($numHost-match '^\d{4}$'){
$hostName= 'ha01wvaw'+ $numHost
 
$filePasw= Get-ChildItem -path $PSScriptRoot -filter *.psw -file -ErrorAction silentlycontinue -recurse
$user= $filePasw[0].BaseName

$keyFiles = Get-ChildItem -path $PSScriptRoot -filter AES.key -file -ErrorAction silentlycontinue -recurse 
$key= Get-Content -path $keyFiles[0].Fullname

$credential= New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user, (Get-Content $filePasw[0].FullName | ConvertTo-SecureString -Key $key)

$pathLog= '\\'+ $hostName+ '\c$\ProgramData\RealVNC-Service'

New-PSDrive -Name 'VNC_LOG' -PSProvider FileSystem -Root $pathLog -Credential $credential | Out-Null

try{

$pathFile = 'VNC_LOG:\'+ 'vncserver.log'

#ii $pathFile

$infoLog= Get-Content -path $pathFile 
 
ForEach($item in $infoLog){
 
 if($item -match 'Connections: authenticated:'){
 $itemSplit= $item.Tostring().split(' ')
 $user_Name= GetUsername($itemSplit[9]) 
 
 $date =$itemSplit[1].Replace("T", ' ').Substring(0,$itemSplit[1].length-5)
 $cureDate=Get-Date -Format "yyyy-MM-dd"
 $computer= $itemSplit[6].Substring(0,$itemSplit[6].length-7)

 $color ="white"

 if ($date.Contains($cureDate)){ 
    $computer = GetHostName($computer) 
    $color= "green"   
   }
 
 $info = $itemSplit[1].Replace("T", ' ').Substring(0,$itemSplit[1].length-5)+ ' '+ $computer + ' '+ $user_Name 
 
 Write-host $info -ForegroundColor $color
 

 } 

 if($item -match 'VNC Viewer closed'){
 $itemSplit= $item.Tostring().split(' ')
 $computer = $itemSplit[6].Substring(0,$itemSplit[6].length-7)
 if ($date.Contains($cureDate)){ 
    $computer = GetHostName($computer)    
    $info = $itemSplit[1].Replace("T", ' ').Substring(0,$itemSplit[1].length-5)+ ' ' + $computer + ' ('+ $itemSplit[11] +')'
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



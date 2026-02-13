#Script for Maxim Laptop change password send it to parents  via email 
function Wait-ForConnection {
    param (
        [string]$Target = "gmail.com",
        [int]$Port = 443,
        [int]$Interval = 60
    )

    $connected = $false

    while (-not $connected) {
        try {
            # Quiet returns a simple Boolean ($true/$false)
            if (Test-NetConnection -ComputerName $Target -Port $Port -InformationLevel Quiet) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Connection established to $Target." -ForegroundColor Green
                $connected = $true
            } else {
                throw "Target unreachable"
            }
        }
        catch {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Waiting for internet... Retrying in $Interval seconds." -ForegroundColor Gray
            Start-Sleep -Seconds $Interval
        }
    }
}

Wait-ForConnection -Target "gmail.com" -Interval 60

$Password = Get-Random -Minimum 1000 -Maximum 9999
$UserAccount = Get-LocalUser -Name "Anya"
$UserAccount | Set-LocalUser -Password (ConvertTo-SecureString $Password -AsPlainText -Force)


$SMTP = "smtp.gmail.com"
$From = "artem.levitin@gmail.com"
$To = "artem.levitin@gmail.com, anlevitina@gmail.com"
$Subject = "Code Maxim " + $Password
$Body = $Subject +" Date: " + (Get-Date).ToString()   
$Email = New-Object Net.Mail.SmtpClient($SMTP, 587)
$Email.EnableSsl = $true
$Email.Credentials = New-Object System.Net.NetworkCredential("artem.levitin@gmail.com", "hmfy ckvv bxui fppb");
$Email.Send($From, $To, $Subject, $Body)

$UserAccount | Set-LocalUser -Password (ConvertTo-SecureString $Password -AsPlainText -Force)

# SMTP password hmfy ckvv bxui fppb
# Set Up Your SMTP Client 
# Server Address: smtp.gmail.com
# Port: 465 (SSL) or 587 (TLS)
# Username: Your full Gmail address
# Password: The 16-digit App Password you generated


# https://www.sharepointdiary.com/2022/06/how-to-change-local-user-password-using-powershell.html
# https://techexpert.tips/powershell/powershell-send-email-gmail/

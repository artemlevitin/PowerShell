#Script for Maxim Laptop change password send it to parents  via email 


$Password = Get-Random -Minimum 1000 -Maximum 9999
$UserAccount = Get-LocalUser -Name "Anya"
$UserAccount | Set-LocalUser -Password (ConvertTo-SecureString $Password -AsPlainText -Force)


$SMTP = "smt.gmail.com"
$From = "artem.levitin@gmail.com"
$To = "artem.levitin@gmail.com"
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
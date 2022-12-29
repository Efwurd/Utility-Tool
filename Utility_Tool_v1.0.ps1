<# 
Nicholas West
CSC 248 S1 - Powershell
Final Script
A tool to be implemented in a work environment to improve efficiency. 
Scans and displays common networking information; Simplifies the remoting process;
Cleans broswer files; Makes disabling startup programs easier.
#>

#Clears the console.
Clear-Host

#Banner(Program name, version, creator)
Write-Host "*******************************" -BackgroundColor Gray -ForegroundColor Green
Write-Host "**********UTILITY TOOL*********" -BackgroundColor Gray -ForegroundColor Green
Write-Host "*************v1.0**************" -BackgroundColor Gray -ForegroundColor Green
Write-Host "*******created by: nwest*******" -BackgroundColor Gray -ForegroundColor Green
Write-Host "*******************************" -BackgroundColor Gray -ForegroundColor Green

#Boolean variable turns game on or off.
[bool]$flag=1

#While loop controlled by boolean $flag variable to start at end the program.
while ($flag -eq 1)
{
    #Program Menu.
    Write-Host ""
    Write-Host "Choose a task." 
    Write-Host ""
    Write-Host "1) View startup applications"
    Write-Host "2) Scan for open ports"
    Write-Host "3) Start Remote Session"
    Write-Host "4) Get Local IP address"
    Write-Host "5) Get Public IP address"
    Write-Host "6) Clean up browser files"
    Write-Host "7) Quit"
    Write-Host ""

    $choice = Read-Host "Enter here" #Prompts and reads in new variable.

    #If statement executes based on user input $choice from menu.
    #An invalid choice will notify user and prompt for new input.
    if ($choice -eq 1)
    {
        #Gets list of all startup applications and their filepaths.
        Get-CimInstance Win32_StartupCommand | Select-Object Name | Format-List
        
        #Sub-menu: Prompts user to disable startup programs or log a .txt file.
        Write-Host "1) Disable startup programs"
        Write-Host "2) Log .txt file"
        Write-Host "3) Quit to menu"
        Write-Host ""
        $choice2 = Read-Host "Enter here" #New user-input variable.
        Write-Host ""

        #If statement either start task manager or save a log file based on $choice input.
        if ($choice2 -eq 1)
        {
            taskmgr /7 /startup #Start task manager at startup apps section.
        }
        elseif ($choice2 -eq 2)
        {
            Get-CimInstance Win32_StartupCommand | Select-Object Name, Location, Command, Description | Format-List | Out-File C:\Users\Public\Desktop\startup_log.txt
            Write-Host "File saved to desktop."
            Write-Host ""
        }
        else
        {
        }
    }
    elseif ($choice -eq 2)
    {
        #Displays a table of all open(listening) ports.
        Write-Host ""
        get-nettcpconnection | where-object {$_.state -match '^Listen'}
        Write-Host ""

        #Prompts user to log data and executes according to
        #user input $choice2.
        $choice2 = Read-Host "Log .txt file? (y/n)"
        Write-Host ""
        if ($choice2 -eq "y")
        {
            Get-CimInstance Win32_StartupCommand | Select-Object Name, Location, Command, Description | Format-List | Out-File C:\Users\Public\Desktop\open_ports.txt
            Write-Host "File saved to desktop."
            Write-Host ""
        }
    }
    elseif ($choice -eq 3)
    {
        #Prompts user Remote session is beginning. Reads in two variables,
        #$ipAddr, $user, and$runspace then executes a series of commands
        #completing the remoting process automatically. Quits the program
        #when the user exits the remote session.
        Write-Host ""
        Write-Host "BEGIN REMOTE SESSION" -BackgroundColor DarkRed
        Write-Host "" 
        Write-Host "REMINDER: Run PSRemoting command on target PC" -BackgroundColor DarkRed
        Write-Host "`"Enable-PSRemoting -skipnetworkprofilecheck -force`"" -BackgroundColor DarkRed
        Write-Host "" 
        [string]$ipAddr = Read-Host "Target IP"
        [string]$user = Read-Host "Target User(whoami)"
        Write-Host ""
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ipAddr
        Get-Item WSMan:\localhost\Client\TrustedHosts
        New-PSSession -computername $ipAddr -credential $user
        Get-PSsession | select-object Name
        $runSpace = Read-Host "Enter Runspace number"
        enter-pssession -name "Runspace$runSpace"
        $flag=0
    }
    elseif ($choice -eq 4)
    {
        #Displays local IP address information.
        Write-Host ""
        get-netipaddress | format-table 
        Write-Host ""

        #Prompts user to log data and executes according to
        #user input $choice2.
        $choice2 = Read-Host "Log .txt file? (y/n)"
        Write-Host ""
        if ($choice2 -eq "y")
        {
            Get-CimInstance Win32_StartupCommand | Select-Object Name, Location, Command, Description | Format-List | Out-File C:\Users\Public\Desktop\local_ip.txt
            Write-Host "File saved to desktop."
            Write-Host ""
        }
    }
    elseif ($choice -eq 5)
    {
        #Displays the users public IP address.
        Write-Host ""
        (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
        Write-Host ""

        #Prompts user to log data and executes according to
        #user input $choice2.
        $choice2 = Read-Host "Log .txt file? (y/n)"
        Write-Host ""
        if ($choice2 -eq "y")
        {
            Get-CimInstance Win32_StartupCommand | Select-Object Name, Location, Command, Description | Format-List | Out-File C:\Users\Public\Desktop\public_ip.txt
            Write-Host "File saved to desktop."
            Write-Host ""
        }
    }
    elseif ($choice -eq 6)
    {
        #Notifies user the pc is being cleaned.
        #Then, deletes items in various folders with a user variable $_
        Write-Host "Cleaning PC..." -ForegroundColor Green
        Write-Host "-------------------"
        get-childitem c:\users\ | foreach {
            Write-Host -ForegroundColor green “Clearing Cache for” $_
            Remove-Item -path “C:\Users\$_\AppData\Local\Microsoft\Windows\Temporary Internet Files\*” -Recurse -Force -EA SilentlyContinue
            Remove-Item -path “C:\Users\$_\AppData\Local\Microsoft\Windows\WER\*” -Recurse -Force -EA SilentlyContinue
            Remove-Item -path “C:\Users\$_\AppData\Local\Temp\*” -Recurse -Force -EA SilentlyContinue
            Remove-Item -path “C:\Users\$_\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue
            Remove-Item -path “C:\Users\$_\AppData\Local\Mozilla\Firefox\Profiles\xt9tgm7q.default-release\cache2\entries\*" -Recurse -Force -EA SilentlyContinue
        }

        Start-Sleep -Seconds 2       #Wait 2 seconds
        taskkill /F /IM "chrome.exe" #Stops Chrome from running.
        Start-Sleep -Seconds 3       #Wait 3 seconds.

        #Looks for specific folders in Chrome directory and deletes the contents.
        $Items = @('Archived History',
                    'Cache\*',
                    'Cookies',
                    'History',
                    'Login Data',
                    'Top Sites',
                    'Visited Links',
                    'Web Data')
        $Folder = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default"
        $Items | % { 
        if (Test-Path "$Folder\$_") {
            Remove-Item "$Folder\$_" -Recurse -Force -EA SilentlyContinue 
        }
        }

        taskkill /F /IM "firefox.exe" #Stops Firefox from running.
        Start-Sleep -Seconds 3        #Wait 3 seconds.
    
        #Looks for specific folders in Firefoc directory and deletes the contents.
        $Items = @('Archived History',
                    'Cache\*',
                    'Cookies',
                    'entries',
                    'History',
                    'Login Data',
                    'Top Sites',
                    'Visited Links',
                    'Web Data')
        $Folder = "$($env:LOCALAPPDATA)\Mozilla\Firefox\Profiles\*\cache2\" 
        $Items | % { 
        if (Test-Path "$Folder\$_") 
        {
            Remove-Item "$Folder\$_" -Recurse -Force -EA SilentlyContinue
        }
        }
    }
    elseif ($choice -eq 7) 
    {
        $flag=0 #Ends progran.
    }
    else
    {
        Write-Error "Invalid Input! Try again!" #Notifies invalid input.
    }
}      
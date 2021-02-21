FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL Description="dnsserversecondaryzone" Vendor="DSC Community" Version="1"

# Copy helper PowerShell scripts to container.
# The source paths should be relative from repository root.
COPY /Tests/Docker/xDnsServerSecondaryZone/New-DscCertificate.ps1 /
COPY /Tests/Docker/xDnsServerSecondaryZone/DnsServer_Config.ps1 /

# Copy required PowerShell modules to container.
# Expecting to have Windows PowerShell in the container.
COPY ["/output/xDnsServer/", "/Program Files/WindowsPowerShell/Modules/xDnsServer"]
COPY ["/output/RequiredModules/DscResource.Test/", "/Program Files/WindowsPowerShell/Modules/DscResource.Test"]

# Create certificate used to encrypt configurations.
RUN powershell -Command /New-DscCertificate.ps1

# Configure DNS Server using DSC (using LCM).
RUN powershell -Command /DnsServer_Config.ps1

# Run a command to keep the container running.
CMD [ "ping", "localhost", "-t" ]

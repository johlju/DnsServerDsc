<#
    .SYNOPSIS
        DSC Configuration to configure DNS Server for the test...
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                 = 'localhost'
            CertificateFile          = $env:DscPublicCertificatePath
            Thumbprint               = $env:DscCertificateThumbprint

            # Forward zone.
            ForwardZoneName          = 'dsc.test'

            # Classful reverse zone.
            ClassfulReverseZoneName  = '1.168.192.in-addr.arpa'

            # Classless reverse zone.
            ClasslessReverseZoneName = '64-26.100.168.192.in-addr.arpa'
        }
    )
}

configuration ConfigureDns_Config
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        WindowsFeature 'InstallDnsServer' {
            Name = 'DNS'
        }

        WindowsFeature 'InstallDnsServerRemoteTools' {
            Name = 'RSAT-DNS-Server'
        }

        # Creates a file-backed primary zone using the default values for parameters.
        xDnsServerPrimaryZone 'PrimaryForwardZone'
        {
            Name = $Node.ForwardZoneName
        }

        # Creates a file-backed classful reverse primary zone
        xDnsServerPrimaryZone 'PrimaryClassfulReverseZone'
        {
            Name          = $Node.ClassfulReverseZoneName
        }

        # Creates a file-backed classless reverse primary zone
        xDnsServerPrimaryZone 'PrimaryClasslessReverseZone'
        {
            Name = $Node.ClasslessReverseZoneName
        }
    }
}

ConfigureDns_Config -ConfigurationData $ConfigurationData -OutputPath '/dsc' -Verbose

Start-DscConfiguration -Path '/dsc' -Wait -Verbose

Import-Module -Name 'DscResource.Test'

# Create certificate to secure the DSC configuration.
New-DscSelfSignedCertificate | Out-Null

'Environment variable $env:DscPublicCertificatePath set to ''{0}''' -f $env:DscPublicCertificatePath

'Environment variable $env:DscCertificateThumbprint set to ''{0}''' -f $env:DscCertificateThumbprint

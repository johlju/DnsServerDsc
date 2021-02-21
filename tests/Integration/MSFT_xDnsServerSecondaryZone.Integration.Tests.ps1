$script:dscModuleName = 'xDnsServer'
$script:dscResourceFriendlyName = 'xDnsServerPrimaryZone'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

try
{
    # List available images on the build worker.
    Write-Verbose -Message ('Available docker images: {0}' -f (docker images | Out-String)) -Verbose

    <#
        Set the location to repository root to allow Dockerfile's 'COPY' to get
        to files outside of its normal build context.
    #>
    Set-Location -Path "$PSScriptRoot/../.."

    Write-Verbose -Message 'Building docker image ''dnsserversecondaryzone''.' -Verbose

    <#
        Build the docker container image used in this integration test. Tagging the image
        with the name of the integration test.
    #>
    docker build -f .\Tests\Docker\xDnsServerSecondaryZone\Dockerfile -t dnsserversecondaryzone .

    # Get the image identifier.
    $imageId = docker inspect --format "{{.ID}}" dnsserversecondaryzone

    Write-Verbose -Message ('Built docker image: {0}' -f $imageId) -Verbose

    <#
        Start the container image and return the container identifier. It possible to
        debug the container locally after it has started by running the following:

            Enter-PSSession -ContainerId $containerId -RunAsAdministrator

        It must run with elevated permissions otherwise it throws the exception:
        "...does not exist, or the corresponding container is not running."
    #>
    $containerId = docker run --detach --name dnsserversecondaryzone $imageId

    Write-Verbose -Message ('Started container: {0}' -f $containerId) -Verbose

    # List all the running containers.
    Write-Verbose -Message ('Running docker containers: {0}' -f (docker ps | Out-String)) -Verbose

    # Set location back to script root.
    Set-Location -Path $PSScriptRoot

    # $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    # . $configFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }

        # $configurationName = "$($script:dscResourceName)_AddForwardZoneUsingDefaultValues_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Present'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ForwardZoneName
        #         $resourceCurrentState.ZoneFile      | Should -Be ('{0}.dns' -f $ConfigurationData.AllNodes.ForwardZoneName)
        #         $resourceCurrentState.DynamicUpdate | Should -Be 'None'
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        # Wait-ForIdleLcm -Clear

        # $configurationName = "$($script:dscResourceName)_RemoveForwardZone_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Absent'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ForwardZoneName
        #         $resourceCurrentState.ZoneFile      | Should -BeNullOrEmpty
        #         $resourceCurrentState.DynamicUpdate | Should -BeNullOrEmpty
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        # Wait-ForIdleLcm -Clear

        # $configurationName = "$($script:dscResourceName)_AddForwardZone_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Present'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ForwardZoneName
        #         $resourceCurrentState.ZoneFile      | Should -Be $ConfigurationData.AllNodes.ForwardZoneFile
        #         $resourceCurrentState.DynamicUpdate | Should -Be $ConfigurationData.AllNodes.ForwardZoneDynamicUpdate
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        # Wait-ForIdleLcm -Clear

        # $configurationName = "$($script:dscResourceName)_RemoveForwardZone_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Absent'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ForwardZoneName
        #         $resourceCurrentState.ZoneFile      | Should -BeNullOrEmpty
        #         $resourceCurrentState.DynamicUpdate | Should -BeNullOrEmpty
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        # Wait-ForIdleLcm -Clear

        # $configurationName = "$($script:dscResourceName)_AddClassfulReverseZone_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Present'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ClassfulReverseZoneName
        #         $resourceCurrentState.ZoneFile      | Should -Be $ConfigurationData.AllNodes.ClassfulReverseZoneFile
        #         $resourceCurrentState.DynamicUpdate | Should -Be $ConfigurationData.AllNodes.ClassfulReverseZoneDynamicUpdate
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        # Wait-ForIdleLcm -Clear

        # $configurationName = "$($script:dscResourceName)_RemoveClassfulReverseZone_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Absent'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ClassfulReverseZoneName
        #         $resourceCurrentState.ZoneFile      | Should -BeNullOrEmpty
        #         $resourceCurrentState.DynamicUpdate | Should -BeNullOrEmpty
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        # Wait-ForIdleLcm -Clear

        # $configurationName = "$($script:dscResourceName)_AddClasslessReverseZone_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Present'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ClasslessReverseZoneName
        #         $resourceCurrentState.ZoneFile      | Should -Be ('{0}.dns' -f $ConfigurationData.AllNodes.ClasslessReverseZoneName)
        #         $resourceCurrentState.DynamicUpdate | Should -Be 'None'
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        # Wait-ForIdleLcm -Clear

        # $configurationName = "$($script:dscResourceName)_RemoveClasslessReverseZone_Config"

        # Context ('When using configuration {0}' -f $configurationName) {
        #     It 'Should compile and apply the MOF without throwing' {
        #         {
        #             $configurationParameters = @{
        #                 OutputPath        = $TestDrive
        #                 ConfigurationData = $ConfigurationData
        #             }

        #             & $configurationName @configurationParameters

        #             $startDscConfigurationParameters = @{
        #                 Path         = $TestDrive
        #                 ComputerName = 'localhost'
        #                 Wait         = $true
        #                 Verbose      = $true
        #                 Force        = $true
        #                 ErrorAction  = 'Stop'
        #             }

        #             Start-DscConfiguration @startDscConfigurationParameters
        #         } | Should -Not -Throw
        #     }

        #     It 'Should be able to call Get-DscConfiguration without throwing' {
        #         {
        #             $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
        #         } | Should -Not -Throw
        #     }

        #     It 'Should have set the resource and all the parameters should match' {
        #         $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
        #             $_.ConfigurationName -eq $configurationName `
        #                 -and $_.ResourceId -eq $resourceId
        #         }

        #         $resourceCurrentState.Ensure        | Should -Be 'Absent'
        #         $resourceCurrentState.Name          | Should -Be $ConfigurationData.AllNodes.ClasslessReverseZoneName
        #         $resourceCurrentState.ZoneFile      | Should -BeNullOrEmpty
        #         $resourceCurrentState.DynamicUpdate | Should -BeNullOrEmpty
        #     }

        #     It 'Should return $true when Test-DscConfiguration is run' {
        #         Test-DscConfiguration -Verbose | Should -Be 'True'
        #     }
        # }

        Wait-ForIdleLcm -Clear
    }
}
finally
{
    if ($containerId)
    {
        # Stop the container.
        docker stop $containerId | Out-Null

        # Remove the container.
        docker rm $containerId | Out-Null
    }

    if ($imageId)
    {
        # Remove the container image.
        docker rmi $imageId | Out-Null
    }

    # Make sure location is the $PSScriptRoot if something happen during container creation.
    Set-Location -Path $PSScriptRoot

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

function Add-SCCMChocoApplication
{
     <#

    .SYNOPSIS
    Adds Chocolatey packages to SCCM

    .DESCRIPTION
    Provide URL of Choco repository, sit down and relax.


    .EXAMPLE
    Just add Chocolatey package to SCCM Software Library
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox"

    .EXAMPLE
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users"
    # Add Chocolatey package to SCCM Software Library and deploy to user collection

    .EXAMPLE
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMDeviceCollectionName "All Users"
    # Add Chocolatey package to SCCM Software Library and deploy to device collection

    .EXAMPLE
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users"
    # Add Chocolatey package to SCCM Software Library and deploy to user collection

    .EXAMPLE
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users" -IconsDir "\\SCCMSRV\CMSOURCE\Choco\Icons"
    # Add Chocolatey package to SCCM Software Library, deploy to user collection, save icon in shared folder

    .EXAMPLE
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMInstallDir "C:\Microsoft Configuration Manager\" - CMSiteCode "TST"
    # Add Chocolatey package to SCCM Software Library, specify location of SCCM console and SiteCode
     
    .PARAMETER chocourl
    URL of Choco package, for example: https://chocolatey.org/packages/Firefox

    .PARAMETER CMUserCollectionName
    Name of User Collection to deploy the software
   
    .PARAMETER CMDeviceCollectionName
    Name of Device Collection to deploy the software
    
    .PARAMETER CMSiteCode
     SCCM Site Code

    .PARAMETER CMInstallDir
    SCCM Installation direcotry (console is required due to PowerShell module)
    
    .PARAMETER IconsDir
    Network folder for icons
       
    .PARAMETER CMFolderName
    SCCM folder for Chocolatey applications
   
    .PARAMETER WhatIf
    Just test, don't apply any changes... but Chocolatey repository and NuGet will be configured to download package metadata.

    .NOTES
    To use this module you must have SCCM console installed on your computer.
    Make sure you have PowerShell Gallery installed (https://msdn.microsoft.com/en-us/powershell/gallery/readme). On first run you will be asked to configure NuGet and Chocolatey repository (but don't be afraid, we will do it fo you).  
    This version requires SCCM Agents to have PowerShell Policy configured to Bypass (see screenshot in GitHub repo)

    #>
    [CmdletBinding(DefaultParameterSetName="default")]
    param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^(https://chocolatey.org/packages/)')]
        [string] $chocourl,
        [Parameter(ParameterSetName="DeployToUserCollection",Mandatory=$false)]
        [string] $CMUserCollectionName,
        [Parameter(ParameterSetName="DeployToDeviceCollection",Mandatory=$false)]
        [string] $CMDeviceCollectionName,
        [Parameter(Mandatory=$false)]
        [ValidatePattern('^[A-Z]{2}[A-Z0-9]{1}$')]
        [string] $CMSiteCode,
        [Parameter(Mandatory=$false)]
        [string] $CMInstallDir,
        [Parameter(Mandatory=$false)]
        [string] $IconsDir = $env:temp,
        [Parameter(Mandatory=$false)]
        [string] $CMFolderName = "Chocolatey",
        [Parameter(Mandatory=$false)]
        [switch] $WhatIf
    )



    #region prereqcheck
    Write-Host "Checking if Chocolatey repository is configured: " -NoNewline

    #Register Choco repository if not registered
    if ((Get-PSRepository "Chocolatey" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).count -eq 0)
    {   
        Write-Host "Installation required" -ForegroundColor Yellow
        Write-Host "#####################################" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "# Please install NuGet if requested #" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "# Select [Y] Yes or press enter     #" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "# when asked                        #" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "#####################################" -BackgroundColor Yellow -ForegroundColor Black 
        Register-PSRepository -Name "Chocolatey" -SourceLocation "https://chocolatey.org/api/v2"
        Write-Host "#################################################" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "# Please approve Chocolatey as a package source #" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "# Select [Y] Yes when asked                     #" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "#################################################" -BackgroundColor Yellow -ForegroundColor Black 
        Install-PackageProvider -Name chocolatey 
    }
    if ((Get-PSRepository "Chocolatey" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).count -eq 0)
    {
        Write-Host "Not installed" -ForegroundColor Red
        Throw "Chocolatey reposity must me registered and installed to continue"
    }
    else
    {
        Write-Host "OK" -ForegroundColor Green
    }


    #test if SCCM module is imported
    Write-Host "Checking if SCCM module is imported: " -NoNewline
    if (Get-Module -Name ConfigurationManager) 
    {
        Write-Host "OK" -ForegroundColor Green
    }
    else
    {
        if ($CMInstallDir.Length -gt 0)
        {
            $psdmodulepath = Join-Path -Path $CMInstallDir -ChildPath "AdminConsole\bin\ConfigurationManager.psd1"
        }
        else {
             $psdmodulepath = Join-Path -Path $env:SMS_ADMIN_UI_PATH -ChildPath "..\ConfigurationManager.psd1"
        }
        
        if (Test-Path $psdmodulepath)
        {
            Import-Module $psdmodulepath
            Write-Host "Module loaded" -ForegroundColor Green
        }
        else
        {
            Write-Host "Module cannot be found" -ForegroundColor Red
            Write-Host "Please provide SCCM console installation path (CMInstallDir parameter)" -ForegroundColor Red
            Throw "No SCCM module available"
        }
    }

    #test if already in SCCM context, switch context if required
    Write-Host "Connecting to SCCM site: " -NoNewline
    $location = Get-Location
    if ($location.Provider.Name -eq "CMSite")  
    {
       $CMSiteCode = (Get-Location).Drive.Name
       Write-Host "Already connected" -ForegroundColor Green; 
    }
    elseif($CMSiteCode -eq $null)
    {
       Write-Host "Failed" -ForegroundColor Red
       Write-Host "Please provide SCCM Site Code (CMSiteCode parameter)" -ForegroundColor Red 
    }
    else
    {
        try{
            Set-Location($CMSiteCode + ":") -ErrorAction Stop
            Write-Host "Succesfully connected" -ForegroundColor Green
        }
        catch
        {
            Write-Host "Please verify SCCM Site Code (CMSiteCode parameter)" -ForegroundColor Red 
            Throw "Cannot connect to SCCM site"
        }
        
    }

    #check if folder for Chocolatey applications exists

    $CMFolderPath = Join-Path ($CMSiteCode + ":\Application") -ChildPath $CMFolderName
    Write-Host ("Checking SCCM Folder '" + $CMFolderPath + "' ") -NoNewline
    if (Test-Path $CMFolderPath)
    {
        Write-Host "OK" -ForegroundColor Green
    }
    elseif ($WhatIf)
    {
        Write-Host "Folder has to be created" -ForegroundColor Yellow
    }
    else {
        New-Item $CMFolderPath
        Write-Host "Folder created" -ForegroundColor Yellow
    }
    
    #check if Chocolatey installer exists in SCCM, add if required
    Write-Host "Checking Chocolatey installer: " -NoNewline
    $chocoinstaller = Get-CMApplication -Name "Chocolatey"
    if ($chocoinstaller -ne $null)
    {
        Write-Host "OK" -ForegroundColor Green
    }
    elseif (($chocoinstaller -eq $null) -and ($WhatIf))
    {
        Write-Host "Doesn't exit in SCCM, will be added" -ForegroundColor Yellow
    }
    else
    {
        Write-Host "Adding Chocolatey installer to SCCM" -ForegroundColor Yellow 
        try
        {
            $iconfileico = $IconsDir + "\chocolatey.ico"
            if ((-not $WhatIf) -and (-not (test-path $iconfileico)))
            {
                Copy-Item (join-path $PSScriptRoot "chocolatey.ico") $IconsDir -ErrorAction SilentlyContinue
            }   
            $chocoinstaller = New-CMApplication -Name "Chocolatey" -Description "Chocolatey package manager" `
                -Publisher "Chocolatey.org" -AutoInstall $true -IconLocationFile $iconfileico
            
            $command = 'powershell -executionpolicy RemoteSigned -command "iwr https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression"'
            $detect = 'if (test-path "C:\ProgramData\Chocolatey\choco.exe"){Write-host "installed"}'

            Add-CMScriptDeploymentType -ApplicationName "Chocolatey" -DeploymentTypeName "Chcolatey installer" `
                -Comment "Do not remove. This is Chocolatey installer" -InstallCommand $command -ScriptLanguage PowerShell -ScriptContent $detect `
                | Out-Null
            Move-CMObject -InputObject $chocoinstaller -FolderPath $CMFolderPath
            Write-Host "Success" -ForegroundColor Green
        }
        catch 
        {
            Write-Host "Failed" -ForegroundColor Red
            throw "Cannot add Chocolatey installer to SCCM"
        }
    }
    
    #endregion

    #region getpackageinfo

    #get package name
    $packageid = $chocourl.Split("/")[-1]

    #find package
    $package = Find-Package -Name $packageid -ProviderName chocolatey
    if ($package -eq $null)
    {
        throw "###########   Cannot find package, please verify if the URL is valid. ############"
    }


    #get icon url
    [xml]$swid = $package.SwidTagText
    $iconurl = (($swid.SoftwareIdentity.Link | ?{$_.rel -match "icon"}).href.split("?")[0])
    #endregion

    #region prepareicon
    #try to build ico file from BMP
    Write-Host "Preparing icon: " -NoNewl
    
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null 
    $iconfilepng = $env:temp +"\"+ $iconUrl.Split("/")[-1]
    $iconfileico = $IconsDir +"\"+ $packageid + ".ico"

    $client = new-object System.Net.WebClient
    try{
        $client.DownloadFile($iconUrl,$iconfilepng)

        $icon = new-object System.Drawing.Bitmap($iconfilepng); 
        if ($icon.Width -gt 250 -or $icon.Height -gt 250)
        {
            $icon = new-object System.Drawing.Bitmap($icon, 250, 250)
        }
        if (-not $WhatIf)
        {
            $icon.Save($iconfileico,"Icon")
        }
        $icon.Dispose();
        Write-Host "OK" -ForegroundColor Green
    }
    catch
    {
        #this is hit when there is no icon or icon is in vector format
        $iconfileico = $IconsDir + "\chocolatey.ico"
        if ((-not $WhatIf) -and (-not (test-path $iconfileico)))
        {
            Copy-Item -Path (join-path $PSScriptRoot "chocolatey.ico") -Destination filesystem::$iconfileico -ErrorAction SilentlyContinue
        }

        Write-Host " couldn't prepare icon, using default one:" -ForegroundColor Yellow
        Write-Host $iconfileico -ForegroundColor Yellow
        Write-Host "Please update icon manually using SCCM console" -ForegroundColor Yellow
    }
    #endregion

    #region addSCCMapp
    
    $CMApp = Get-CMApplication -Name $package.Name
    if ($CMApp -ne $null)
    {
        Write-Host ("Application " +$package.Name + " already exists.") -ForegroundColor Yellow
    }
    elseif ($WhatIf)
    {
        Write-Host ("Application " + $package.Name + " will be added (WhatIf enabled)")
    }
    else
    {
        Write-Host ("Adding " + $package.Name + " to SCCM Applications" )
        #Add application
        $CMAppParams = @{
            Name = $package.Name
            AutoInstall = $true 
            Description = $chocourl
            IconLocationFile =$iconfileico
            LocalizedName =$swid.SoftwareIdentity.Meta.title
            LocalizedDescription = $package.Summary
        }
        $CMapp = New-CMApplication @CMAppParams 
        Write-host "Adding deployment type"
       
        #Add application deployment type
        $CMAppDeplParams = @{
            ApplicationName =$package.Name
            DeploymentTypeName = ($package.Name +"-choco")
            InstallCommand = ("c:\ProgramData\chocolatey\bin\choco install {0} -y" -f $package.name )
            ScriptLanguage = "PowerShell"
            ScriptContent = 
                '$packacgename = "'+$package.name+'" 
                try{
                    c:\ProgramData\chocolatey\bin\choco list --local-only | ?{$_ -match $packacgename} | Out-Null
                    if($matches[0] -gt 0)
                    {
                        Write-Host "installed"
                    }
                }
                catch{}
                '
            UninstallCommand = ("c:\ProgramData\chocolatey\bin\choco uninstall {0} -y" -f $package.name)
            InstallationBehaviorType = "InstallForSystem"
            LogonRequirementType = "WhetherOrNotUserLoggedOn" 
            Comment = $chocourl
        }
 
        $CMDeplType = Add-CMScriptDeploymentType @CMAppDeplParams | Out-Null
        $CMDeplType = Get-CMDeploymentType -ApplicationName $package.Name -DeploymentTypeName ($package.Name+"-choco")

        #Add dependencies (install Choco before installing the app)
        Write-host "Adding dependencies"
        $CMDepGroup = New-CMDeploymentTypeDependencyGroup -GroupName "Choco" -InputObject $CMDeplType
        Add-CMDeploymentTypeDependency -DeploymentTypeDependency (Get-CMDeploymentType -ApplicationName "Chocolatey")`
            -InputObject $CMDepGroup -IsAutoInstall $true | Out-Null
            
        Write-host "Moving object"    
        Move-CMObject -FolderPath $CMFolderPath -InputObject $CMapp
    }
    #endregion

    #region deploy
    $CMDeplColl
    if (($PsCmdlet.ParameterSetName -eq "DeployToUserCollection") -and  ($CMUserCollectionName.Length -gt 0))
    {
        Write-Host "Getting User Collection: " -NoNewline
        $CMDeplColl = Get-CMCollection -Name $CMUserCollectionName -CollectionType User   
    }
    elseif (($PsCmdlet.ParameterSetName -eq "DeployToDeviceCollection") -and  ($CMDeviceCollectionName.Length -gt 0))
    {
        Write-Host "Getting Device Collection: " -NoNewline
        $CMDeplColl = Get-CMCollection -Name $CMDeviceCollectionName -CollectionType Device   
    }

    if ($CMDeplColl -ne $null)
    {
        Write-Host "Ok" -ForegroundColor Green
        Write-Host "Starting Deployment"
        if (-not $WhatIf)
        {
            try{
                #'Start-CMApplicationDeployment' has been deprecated in 1702 and may be removed in a future release.
                #The cmdlet 'New-CMApplicationDeployment' may be used as a replacement.
                Start-CMApplicationDeployment -Collection $CMDeplColl.Name -Name $package.Name -DeployAction Install -DeployPurpose Available 
                Write-Host "Ok" -ForegroundColor Green | Out-Null
            }
            catch
            {
                Write-Host "Failed" -ForegroundColor Red
            }
        }
        else
        {
            Write-Host "Simulation-only (WhatIf)" -ForegroundColor Yellow
        }
    }
    #endregion

    #return to initial location, leave things tidy behind yourself
    Set-Location $location
}
# SIG # Begin signature block
# MIIXeQYJKoZIhvcNAQcCoIIXajCCF2YCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFCJZfPClrUaIz8/d6mkhABVR
# elugghJlMIIDuzCCAqOgAwIBAgIDBETAMA0GCSqGSIb3DQEBBQUAMH4xCzAJBgNV
# BAYTAlBMMSIwIAYDVQQKExlVbml6ZXRvIFRlY2hub2xvZ2llcyBTLkEuMScwJQYD
# VQQLEx5DZXJ0dW0gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxIjAgBgNVBAMTGUNl
# cnR1bSBUcnVzdGVkIE5ldHdvcmsgQ0EwHhcNMDgxMDIyMTIwNzM3WhcNMjkxMjMx
# MTIwNzM3WjB+MQswCQYDVQQGEwJQTDEiMCAGA1UEChMZVW5pemV0byBUZWNobm9s
# b2dpZXMgUy5BLjEnMCUGA1UECxMeQ2VydHVtIENlcnRpZmljYXRpb24gQXV0aG9y
# aXR5MSIwIAYDVQQDExlDZXJ0dW0gVHJ1c3RlZCBOZXR3b3JrIENBMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4/t9o3K6wvDJFIf1awFO4W5AB7ptJ11/
# 91sts1rHUV+rpDKmYYe2bg+G0jACl/jXaVehGDldamR5xgFZrDwxSjh80gTSSyjo
# IF87B6LMTXPb865Px1bVWqeWifrzq2jUI4ZZJ88JJ7ysbnKDHDBy3+Ci6dLhdHUZ
# vSqeexVUBBvXQzmtVSjF4hq79MDkrjhJM8x2hZ85RdKknvISjFH4fOQtf/WsX+sW
# n7Et0brMkUJ3TCXJkDhv2/DM+44el1k+1WBO5gUo7Ul5E0u6SNsv+XLTOcr+H9g0
# cvW0QM8xAcPs3hEtF10fuFDRXhmnad4HMyjKUJX5p1TLVIZQRan5SQIDAQABo0Iw
# QDAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQIds3LB/8k9sXN7buQvOKEN0Z1
# 9zAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQEFBQADggEBAKaorSLOAT2mo/9i
# 0Eidi15ysHhE49wcrwn9I0j6vSrEuVUEtRCjjSfeC4Jj0O7eDDd5QVsisrCaQVym
# cODU0HfLI9MA4GxWL+FpDQ3Zqr8hgVDZBqWo/5U30Kr+4rP1mS1FhIrlQgnXdAIv
# 94nYmem8J9RHjboNRhx3zxSkHLmkMcScKHQDNP8zGSal6Q10tz6XxnboJ5ajZt3h
# rvJBW8qYVoNzcOSGGtIxQbovvi0TWnZvTuhOgQ4/WwMioBK+ZlgRSssDxLQqKi2W
# F+A5VLxI03YnnZotBqbJ7DnSq9ufmgsnAjUpsUCV5/nonFWIGUbWtzT1fs45mtk4
# 8VH3TywwggSZMIIDgaADAgECAg8WiPA5JV5jjmkUOQfmMwswDQYJKoZIhvcNAQEF
# BQAwgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBM
# YWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UE
# CxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZp
# cnN0LU9iamVjdDAeFw0xNTEyMzEwMDAwMDBaFw0xOTA3MDkxODQwMzZaMIGEMQsw
# CQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQH
# EwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEqMCgGA1UEAxMh
# Q09NT0RPIFNIQS0xIFRpbWUgU3RhbXBpbmcgU2lnbmVyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEA6ek939c3CMkeOLJSU0JtIvGxxAYEa579gnRQQ33G
# oLsfTvkCcSax70PYg4xI/OcPl3qa65zepqMOOxxEGHWOeKUXaf5JGKTiu1xO/o4q
# VHpQ8NX2zJHnmXnX3nmU15Yz/g6DviK/YxYso90oG689q+qX0vG/BBDnPUhF/R9o
# ZcF/WZlpwCIxDGJup1xlASGwY8QiGCfu5vzSAD1HLqi4hlZdBNwTFyVuHN9EDxXN
# t9ulV3ZCbwBogpnS48He8IuUV0zsCJAiIc4iK5gMQuZCk5SYk+/9Btk/vFubVDwg
# se5q1kd6xauA6TCa3vGkP1VNCgk0inUp0mmtlw9Qv/jKCQIDAQABo4H0MIHxMB8G
# A1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2LPMnYMB0GA1UdDgQWBBSOay0za/Qz
# p5OzE5ql4Ar3EjVqiDAOBgNVHQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3Js
# LnVzZXJ0cnVzdC5jb20vVVROLVVTRVJGaXJzdC1PYmplY3QuY3JsMDUGCCsGAQUF
# BwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0LmNvbTAN
# BgkqhkiG9w0BAQUFAAOCAQEAujMkQECMfNtYn7NgmLL1wDH+6x9uUPYK4OTmga0m
# h6Lf/bPa9HPzAPspG4kbFT7ba1KTK8SsOYHXPGdXmjk24CgImuM5T5uJCX97xWF/
# WYkyJQpqrho+8KInqLbDuIf3FgRIQT1c2OyfTSAxBNlloe3NaQdTFj3dNgIKiOtA
# 5QYwC7gWS9zvvFUJ/8Y+Ei52s9zOQu/5dlfhtwoFQJhYml1xFpNxjGWB6m/ziff7
# c62057/Zjm+qC08l87jh1d11mGiB+KrA0YDCxMQ5icH2yZ5s13T52Zf4T8KaCs1e
# j/gZ6eCln8TwkiHmLXklySL5w/A6hFetOhb0Y5QQHV3QxjCCBN4wggPGoAMCAQIC
# EGsyag8DKNN6HVML/SO9SOIwDQYJKoZIhvcNAQELBQAwfjELMAkGA1UEBhMCUEwx
# IjAgBgNVBAoTGVVuaXpldG8gVGVjaG5vbG9naWVzIFMuQS4xJzAlBgNVBAsTHkNl
# cnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEiMCAGA1UEAxMZQ2VydHVtIFRy
# dXN0ZWQgTmV0d29yayBDQTAeFw0xNTEwMjkxMTMwMjlaFw0yNzA2MDkxMTMwMjla
# MIGAMQswCQYDVQQGEwJQTDEiMCAGA1UECgwZVW5pemV0byBUZWNobm9sb2dpZXMg
# Uy5BLjEnMCUGA1UECwweQ2VydHVtIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MSQw
# IgYDVQQDDBtDZXJ0dW0gQ29kZSBTaWduaW5nIENBIFNIQTIwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQC326jYyOO82tqDurm/1tVXU0G3QLoXDESV1Olm
# O3+0vpCjlAmlrSEgF4BGtEMmPo5LGmTsDkAyQ/yCn/9KLeqU3VoRNoth7+wW1EkD
# 2Oddw2Vb8k4LK8PBU/pALcKrMyQFgXB+yIdMn9GAwhh7DhS9TgNDyyhIsC3mNt8b
# PYvDjJ03nuEG1yVQ33k92rdf60a+dig2uAIARgPQNBt4tCjHUcfIlT9ujYkY3Enx
# wg8a9IGBx23UBHfFIaMuU/l3z9ypm8PB5dVnLzG8wMJonEqW5R/x80g1DvbkscXv
# h4A64oAMNJ36FGRx5ByhqrLPAKfjN3L5QK2eKJUCDc6Q41vFAgMBAAGjggFTMIIB
# TzAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTAe7TIt25WpwlImvhyT9fXJCw2
# PjAfBgNVHSMEGDAWgBQIds3LB/8k9sXN7buQvOKEN0Z19zAOBgNVHQ8BAf8EBAMC
# AQYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwLwYDVR0fBCgwJjAkoCKgIIYeaHR0cDov
# L2NybC5jZXJ0dW0ucGwvY3RuY2EuY3JsMGsGCCsGAQUFBwEBBF8wXTAoBggrBgEF
# BQcwAYYcaHR0cDovL3N1YmNhLm9jc3AtY2VydHVtLmNvbTAxBggrBgEFBQcwAoYl
# aHR0cDovL3JlcG9zaXRvcnkuY2VydHVtLnBsL2N0bmNhLmNlcjA5BgNVHSAEMjAw
# MC4GBFUdIAAwJjAkBggrBgEFBQcCARYYaHR0cDovL3d3dy5jZXJ0dW0ucGwvQ1BT
# MA0GCSqGSIb3DQEBCwUAA4IBAQCq5T92VAJMcA4pqTmWBg8xtwvxpotS+xCPT0Jb
# jL0xIwFmnegpoU3DUPr3+EUOHYLX/P6mMgRz/XHszIgPo5IIxYFYAv0LaTvNuD9J
# PdCNHBMUaC6bDZqtsBnintJ8OXeIbyP9e4T8RG21umtwklVslLHYN/2pWR20Y7Lc
# E814jiU1wZqPN4Qu1EXM4/XMjXOo4zpt55WUcFeRULZt73NyTy8Ch2Di6iKh7T79
# 0YtmjS5ybU/GXTXuk6iY0mdq6doZzQKD+XT8X3oYBCge3SIzO3ZsRwVd1VL+Drp2
# 84MQx24wX6dgx/p0JzGbKIPtIYob8SNShO2VvK06paNCAZ28MIIFIzCCBAugAwIB
# AgIQNGXbuSUdZ4NOHRYr/KzTNzANBgkqhkiG9w0BAQsFADCBgDELMAkGA1UEBhMC
# UEwxIjAgBgNVBAoMGVVuaXpldG8gVGVjaG5vbG9naWVzIFMuQS4xJzAlBgNVBAsM
# HkNlcnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEkMCIGA1UEAwwbQ2VydHVt
# IENvZGUgU2lnbmluZyBDQSBTSEEyMB4XDTE3MDcxMDAwMDAwMFoXDTE4MDcxMDAw
# MDAwMFowgYsxCzAJBgNVBAYTAlBMMR4wHAYDVQQKDBVPcGVuIFNvdXJjZSBEZXZl
# bG9wZXIxMDAuBgNVBAMMJ09wZW4gU291cmNlIERldmVsb3BlciwgSmFrdWIgU2lh
# dGtvd3NraTEqMCgGCSqGSIb3DQEJARYba3ViYStjZXJ0dW1AaW50ZXJrcmVhY2ph
# LnBsMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn1LnQ2xA2hqyhHpb
# 3Be7nLfXIznzVekMOnAFdz5DLbqaBSk9y/J3cwlAR8W+J4txFPvCt7koUqXz4Uo4
# JzL73XzAY2ttPc/SD92MwNB/enOeo6CbllzmQCThpmE1qWnDnEvejZTX1Lmrl6J7
# vJC2UVp2GQNTOEWKfsxy7tKWvy9aOPj8itLzockpjdZ6KbuTVAmchM12QVGgkcJW
# 9LhaBM68Yca2zfpjammRoDM5QrhYvwdozHXOO++2DJYEKKYUBhuUSTjrJYjn8fj/
# o46NcX9N3cX7z/5sBiAqfWtfsYw27h6eMRaS3k9WUT/AccP4q3odiW6Pet7293bF
# jB0pzwIDAQABo4IBijCCAYYwDAYDVR0TAQH/BAIwADAyBgNVHR8EKzApMCegJaAj
# hiFodHRwOi8vY3JsLmNlcnR1bS5wbC9jc2Nhc2hhMi5jcmwwcQYIKwYBBQUHAQEE
# ZTBjMCsGCCsGAQUFBzABhh9odHRwOi8vY3NjYXNoYTIub2NzcC1jZXJ0dW0uY29t
# MDQGCCsGAQUFBzAChihodHRwOi8vcmVwb3NpdG9yeS5jZXJ0dW0ucGwvY3NjYXNo
# YTIuY2VyMB8GA1UdIwQYMBaAFMB7tMi3blanCUia+HJP19ckLDY+MB0GA1UdDgQW
# BBQ65PkRc5AONPhnJQyCAvH7j8aAAzAdBgNVHRIEFjAUgRJjc2Nhc2hhMkBjZXJ0
# dW0ucGwwDgYDVR0PAQH/BAQDAgeAMEsGA1UdIAREMEIwCAYGZ4EMAQQBMDYGCyqE
# aAGG9ncCBQEEMCcwJQYIKwYBBQUHAgEWGWh0dHBzOi8vd3d3LmNlcnR1bS5wbC9D
# UFMwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDQYJKoZIhvcNAQELBQADggEBAIrR6AVM
# wKAfvJp7PXSuAmScOOqW/gRh90k+966APKuWY/dDXrI9Rc76zcxYkQ0Dwff+fele
# 89JoTJBaSuowPUcmG6ClLaERSxYvfeE1/W6JZ9DuoAAMh6TTbOcyyfErGjvSFr8j
# 3tGmBq4fTwjVF4SrlrhH/qILAZyw47CdoSDsXDa0vrbxvmjTMtb0aPfCvXyeKLQU
# /LxuQNICayM4Ap1sc0gTPE0epO0Sr3FVoXS2al0pBp843s1aI++FcdG0twL9gJM0
# UsneZkWm0D6lWdCyIlXDE+8k4Sywg+ufb3/AyCDursh6OdM0Mhy8GVjsBBGbGSRV
# AWqEIybqYoO7EdIxggR+MIIEegIBATCBlTCBgDELMAkGA1UEBhMCUEwxIjAgBgNV
# BAoMGVVuaXpldG8gVGVjaG5vbG9naWVzIFMuQS4xJzAlBgNVBAsMHkNlcnR1bSBD
# ZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEkMCIGA1UEAwwbQ2VydHVtIENvZGUgU2ln
# bmluZyBDQSBTSEEyAhA0Zdu5JR1ng04dFiv8rNM3MAkGBSsOAwIaBQCgeDAYBgor
# BgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEE
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQv
# r7nXvN79V0YkvChdm97+QmvMGDANBgkqhkiG9w0BAQEFAASCAQA2rTjNAyCXoW9T
# oTww2d4wbDsR4uLd9MQb8jPl9ocM0sj5P/MTuvRl1bb1B66GBpUY6QBfOkQBtLbA
# EjAiLjTrUnA5VVQiB6k9RZ/70YzTGVSgFM5rjwZcT9ktEHkDVq91kXJyn00Jp06K
# 1axDB5eRGvt7y4FO+tTq7INMHiyCOT01wJWGgieLLwi1NW2jVU8p/e3rasR60qdQ
# zU3HJsJ7UtlbchygrZxOslUe0HNynfvxIFwCX523b9x26Pv+z0VgwHr0jwdQxEvL
# sDmGoCh50+ObHTpywEtX+GvHsNkXy9E1FNv4RhAHT69oTqFdVwXHiY/+L2h2QBvV
# 6PuoH7dIoYICQzCCAj8GCSqGSIb3DQEJBjGCAjAwggIsAgEBMIGpMIGVMQswCQYD
# VQQGEwJVUzELMAkGA1UECBMCVVQxFzAVBgNVBAcTDlNhbHQgTGFrZSBDaXR5MR4w
# HAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxITAfBgNVBAsTGGh0dHA6Ly93
# d3cudXNlcnRydXN0LmNvbTEdMBsGA1UEAxMUVVROLVVTRVJGaXJzdC1PYmplY3QC
# DxaI8DklXmOOaRQ5B+YzCzAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqG
# SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcxMDE2MjA0NDQ0WjAjBgkqhkiG9w0B
# CQQxFgQU0FGdB4Te2lhfd0QLtkU7FNyc4CMwDQYJKoZIhvcNAQEBBQAEggEAS1sk
# tcs9QcC8M/eI6gB6qUm5E+S3uuWMVptaeVyFMUvEC6kO2FYyfW1f0JrwIfO276CE
# f+EpMvDZ7Z599eHd6FmVGpzhjnL++YgamYYNAiIioeL2vmBMY8oK2AEzN+41sXBn
# fT5YICWwcvMK9xMOr8pwaa3mVpY/18VuZ2G8CXPfo5mcdhPRuxrVSAONh1K9/lYh
# KhmocQ+suDO0qPNXOYJ+sxUwujQGKooS2cTSFOkKOpcSjQP8ZCXYM6N/7kw+lJ+P
# mRIu+04uX1UO1oUvdmRutPlN6EjXTr9R/xrzxiwoPH1ZaxU0yE+8Ggc1TD8fnX0d
# AinEGTFdi19ej3/Y7A==
# SIG # End signature block

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
# MIIbPQYJKoZIhvcNAQcCoIIbLjCCGyoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUf2F3Q+w52uQUEMOt9GqxXFaj
# 8LegghZhMIIDuzCCAqOgAwIBAgIDBETAMA0GCSqGSIb3DQEBBQUAMH4xCzAJBgNV
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
# 8VH3TywwggPuMIIDV6ADAgECAhB+k+v7fMZOWepLmnfUBvw7MA0GCSqGSIb3DQEB
# BQUAMIGLMQswCQYDVQQGEwJaQTEVMBMGA1UECBMMV2VzdGVybiBDYXBlMRQwEgYD
# VQQHEwtEdXJiYW52aWxsZTEPMA0GA1UEChMGVGhhd3RlMR0wGwYDVQQLExRUaGF3
# dGUgQ2VydGlmaWNhdGlvbjEfMB0GA1UEAxMWVGhhd3RlIFRpbWVzdGFtcGluZyBD
# QTAeFw0xMjEyMjEwMDAwMDBaFw0yMDEyMzAyMzU5NTlaMF4xCzAJBgNVBAYTAlVT
# MR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50
# ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsayzSVRLlxwSCtgleZEiVypv3LgmxENza8K/LlBa
# +xTCdo5DASVDtKHiRfTot3vDdMwi17SUAAL3Te2/tLdEJGvNX0U70UTOQxJzF4KL
# abQry5kerHIbJk1xH7Ex3ftRYQJTpqr1SSwFeEWlL4nO55nn/oziVz89xpLcSvh7
# M+R5CvvwdYhBnP/FA1GZqtdsn5Nph2Upg4XCYBTEyMk7FNrAgfAfDXTekiKryvf7
# dHwn5vdKG3+nw54trorqpuaqJxZ9YfeYcRG84lChS+Vd+uUOpyyfqmUg09iW6Mh8
# pU5IRP8Z4kQHkgvXaISAXWp4ZEXNYEZ+VMETfMV58cnBcQIDAQABo4H6MIH3MB0G
# A1UdDgQWBBRfmvVuXMzMdJrU3X3vP9vsTIAu3TAyBggrBgEFBQcBAQQmMCQwIgYI
# KwYBBQUHMAGGFmh0dHA6Ly9vY3NwLnRoYXd0ZS5jb20wEgYDVR0TAQH/BAgwBgEB
# /wIBADA/BgNVHR8EODA2MDSgMqAwhi5odHRwOi8vY3JsLnRoYXd0ZS5jb20vVGhh
# d3RlVGltZXN0YW1waW5nQ0EuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA4GA1Ud
# DwEB/wQEAwIBBjAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIw
# NDgtMTANBgkqhkiG9w0BAQUFAAOBgQADCZuPee9/WTCq72i1+uMJHbtPggZdN1+m
# Up8WjeockglEbvVt61h8MOj5aY0jcwsSb0eprjkR+Cqxm7Aaw47rWZYArc4MTbLQ
# MaYIXCp6/OJ6HVdMqGUY6XlAYiWWbsfHN2qDIQiOQerd2Vc/HXdJhyoWBl6mOGoi
# EqNRGYN+tjCCBKMwggOLoAMCAQICEA7P9DjI/r81bgTYapgbGlAwDQYJKoZIhvcN
# AQEFBQAwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0
# aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENB
# IC0gRzIwHhcNMTIxMDE4MDAwMDAwWhcNMjAxMjI5MjM1OTU5WjBiMQswCQYDVQQG
# EwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xNDAyBgNVBAMTK1N5
# bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgU2lnbmVyIC0gRzQwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCiYws5RLi7I6dESbsO/6HwYQpTk7CY
# 260sD0rFbv+GPFNVDxXOBD8r/amWltm+YXkLW8lMhnbl4ENLIpXuwitDwZ/YaLSO
# QE/uhTi5EcUj8mRY8BUyb05Xoa6IpALXKh7NS+HdY9UXiTJbsF6ZWqidKFAOF+6W
# 22E7RVEdzxJWC5JH/Kuu9mY9R6xwcueS51/NELnEg2SUGb0lgOHo0iKl0LoCeqF3
# k1tlw+4XdLxBhircCEyMkoyRLZ53RB9o1qh0d9sOWzKLVoszvdljyEmdOsXF6jML
# 0vGjG/SLvtmzV4s73gSneiKyJK4ux3DFvk6DJgj7C72pT5kI4RAocqrNAgMBAAGj
# ggFXMIIBUzAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4G
# A1UdDwEB/wQEAwIHgDBzBggrBgEFBQcBAQRnMGUwKgYIKwYBBQUHMAGGHmh0dHA6
# Ly90cy1vY3NwLndzLnN5bWFudGVjLmNvbTA3BggrBgEFBQcwAoYraHR0cDovL3Rz
# LWFpYS53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNlcjA8BgNVHR8ENTAzMDGg
# L6AthitodHRwOi8vdHMtY3JsLndzLnN5bWFudGVjLmNvbS90c3MtY2EtZzIuY3Js
# MCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC0yMB0GA1Ud
# DgQWBBRGxmmjDkoUHtVM2lJjFz9eNrwN5jAfBgNVHSMEGDAWgBRfmvVuXMzMdJrU
# 3X3vP9vsTIAu3TANBgkqhkiG9w0BAQUFAAOCAQEAeDu0kSoATPCPYjA3eKOEJwdv
# GLLeJdyg1JQDqoZOJZ+aQAMc3c7jecshaAbatjK0bb/0LCZjM+RJZG0N5sNnDvcF
# pDVsfIkWxumy37Lp3SDGcQ/NlXTctlzevTcfQ3jmeLXNKAQgo6rxS8SIKZEOgNER
# /N1cdm5PXg5FRkFuDbDqOJqxOtoJcRD8HHm0gHusafT9nLYMFivxf1sJPZtb4hbK
# E4FtAC44DagpjyzhsvRaqQGvFZwsL0kb2yK7w/54lFHDhrGCiF3wPbRRoXkzKy57
# udwgCRNx62oZW8/opTBXLIlJP7nPf8m/PiJoY1OavWl0rMUdPH+S4MO8HNgEdTCC
# BN4wggPGoAMCAQICEGsyag8DKNN6HVML/SO9SOIwDQYJKoZIhvcNAQELBQAwfjEL
# MAkGA1UEBhMCUEwxIjAgBgNVBAoTGVVuaXpldG8gVGVjaG5vbG9naWVzIFMuQS4x
# JzAlBgNVBAsTHkNlcnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEiMCAGA1UE
# AxMZQ2VydHVtIFRydXN0ZWQgTmV0d29yayBDQTAeFw0xNTEwMjkxMTMwMjlaFw0y
# NzA2MDkxMTMwMjlaMIGAMQswCQYDVQQGEwJQTDEiMCAGA1UECgwZVW5pemV0byBU
# ZWNobm9sb2dpZXMgUy5BLjEnMCUGA1UECwweQ2VydHVtIENlcnRpZmljYXRpb24g
# QXV0aG9yaXR5MSQwIgYDVQQDDBtDZXJ0dW0gQ29kZSBTaWduaW5nIENBIFNIQTIw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC326jYyOO82tqDurm/1tVX
# U0G3QLoXDESV1OlmO3+0vpCjlAmlrSEgF4BGtEMmPo5LGmTsDkAyQ/yCn/9KLeqU
# 3VoRNoth7+wW1EkD2Oddw2Vb8k4LK8PBU/pALcKrMyQFgXB+yIdMn9GAwhh7DhS9
# TgNDyyhIsC3mNt8bPYvDjJ03nuEG1yVQ33k92rdf60a+dig2uAIARgPQNBt4tCjH
# UcfIlT9ujYkY3Enxwg8a9IGBx23UBHfFIaMuU/l3z9ypm8PB5dVnLzG8wMJonEqW
# 5R/x80g1DvbkscXvh4A64oAMNJ36FGRx5ByhqrLPAKfjN3L5QK2eKJUCDc6Q41vF
# AgMBAAGjggFTMIIBTzAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTAe7TIt25W
# pwlImvhyT9fXJCw2PjAfBgNVHSMEGDAWgBQIds3LB/8k9sXN7buQvOKEN0Z19zAO
# BgNVHQ8BAf8EBAMCAQYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwLwYDVR0fBCgwJjAk
# oCKgIIYeaHR0cDovL2NybC5jZXJ0dW0ucGwvY3RuY2EuY3JsMGsGCCsGAQUFBwEB
# BF8wXTAoBggrBgEFBQcwAYYcaHR0cDovL3N1YmNhLm9jc3AtY2VydHVtLmNvbTAx
# BggrBgEFBQcwAoYlaHR0cDovL3JlcG9zaXRvcnkuY2VydHVtLnBsL2N0bmNhLmNl
# cjA5BgNVHSAEMjAwMC4GBFUdIAAwJjAkBggrBgEFBQcCARYYaHR0cDovL3d3dy5j
# ZXJ0dW0ucGwvQ1BTMA0GCSqGSIb3DQEBCwUAA4IBAQCq5T92VAJMcA4pqTmWBg8x
# twvxpotS+xCPT0JbjL0xIwFmnegpoU3DUPr3+EUOHYLX/P6mMgRz/XHszIgPo5II
# xYFYAv0LaTvNuD9JPdCNHBMUaC6bDZqtsBnintJ8OXeIbyP9e4T8RG21umtwklVs
# lLHYN/2pWR20Y7LcE814jiU1wZqPN4Qu1EXM4/XMjXOo4zpt55WUcFeRULZt73Ny
# Ty8Ch2Di6iKh7T790YtmjS5ybU/GXTXuk6iY0mdq6doZzQKD+XT8X3oYBCge3SIz
# O3ZsRwVd1VL+Drp284MQx24wX6dgx/p0JzGbKIPtIYob8SNShO2VvK06paNCAZ28
# MIIFIzCCBAugAwIBAgIQNGXbuSUdZ4NOHRYr/KzTNzANBgkqhkiG9w0BAQsFADCB
# gDELMAkGA1UEBhMCUEwxIjAgBgNVBAoMGVVuaXpldG8gVGVjaG5vbG9naWVzIFMu
# QS4xJzAlBgNVBAsMHkNlcnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEkMCIG
# A1UEAwwbQ2VydHVtIENvZGUgU2lnbmluZyBDQSBTSEEyMB4XDTE3MDcxMDAwMDAw
# MFoXDTE4MDcxMDAwMDAwMFowgYsxCzAJBgNVBAYTAlBMMR4wHAYDVQQKDBVPcGVu
# IFNvdXJjZSBEZXZlbG9wZXIxMDAuBgNVBAMMJ09wZW4gU291cmNlIERldmVsb3Bl
# ciwgSmFrdWIgU2lhdGtvd3NraTEqMCgGCSqGSIb3DQEJARYba3ViYStjZXJ0dW1A
# aW50ZXJrcmVhY2phLnBsMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# n1LnQ2xA2hqyhHpb3Be7nLfXIznzVekMOnAFdz5DLbqaBSk9y/J3cwlAR8W+J4tx
# FPvCt7koUqXz4Uo4JzL73XzAY2ttPc/SD92MwNB/enOeo6CbllzmQCThpmE1qWnD
# nEvejZTX1Lmrl6J7vJC2UVp2GQNTOEWKfsxy7tKWvy9aOPj8itLzockpjdZ6KbuT
# VAmchM12QVGgkcJW9LhaBM68Yca2zfpjammRoDM5QrhYvwdozHXOO++2DJYEKKYU
# BhuUSTjrJYjn8fj/o46NcX9N3cX7z/5sBiAqfWtfsYw27h6eMRaS3k9WUT/AccP4
# q3odiW6Pet7293bFjB0pzwIDAQABo4IBijCCAYYwDAYDVR0TAQH/BAIwADAyBgNV
# HR8EKzApMCegJaAjhiFodHRwOi8vY3JsLmNlcnR1bS5wbC9jc2Nhc2hhMi5jcmww
# cQYIKwYBBQUHAQEEZTBjMCsGCCsGAQUFBzABhh9odHRwOi8vY3NjYXNoYTIub2Nz
# cC1jZXJ0dW0uY29tMDQGCCsGAQUFBzAChihodHRwOi8vcmVwb3NpdG9yeS5jZXJ0
# dW0ucGwvY3NjYXNoYTIuY2VyMB8GA1UdIwQYMBaAFMB7tMi3blanCUia+HJP19ck
# LDY+MB0GA1UdDgQWBBQ65PkRc5AONPhnJQyCAvH7j8aAAzAdBgNVHRIEFjAUgRJj
# c2Nhc2hhMkBjZXJ0dW0ucGwwDgYDVR0PAQH/BAQDAgeAMEsGA1UdIAREMEIwCAYG
# Z4EMAQQBMDYGCyqEaAGG9ncCBQEEMCcwJQYIKwYBBQUHAgEWGWh0dHBzOi8vd3d3
# LmNlcnR1bS5wbC9DUFMwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDQYJKoZIhvcNAQEL
# BQADggEBAIrR6AVMwKAfvJp7PXSuAmScOOqW/gRh90k+966APKuWY/dDXrI9Rc76
# zcxYkQ0Dwff+fele89JoTJBaSuowPUcmG6ClLaERSxYvfeE1/W6JZ9DuoAAMh6TT
# bOcyyfErGjvSFr8j3tGmBq4fTwjVF4SrlrhH/qILAZyw47CdoSDsXDa0vrbxvmjT
# Mtb0aPfCvXyeKLQU/LxuQNICayM4Ap1sc0gTPE0epO0Sr3FVoXS2al0pBp843s1a
# I++FcdG0twL9gJM0UsneZkWm0D6lWdCyIlXDE+8k4Sywg+ufb3/AyCDursh6OdM0
# Mhy8GVjsBBGbGSRVAWqEIybqYoO7EdIxggRGMIIEQgIBATCBlTCBgDELMAkGA1UE
# BhMCUEwxIjAgBgNVBAoMGVVuaXpldG8gVGVjaG5vbG9naWVzIFMuQS4xJzAlBgNV
# BAsMHkNlcnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEkMCIGA1UEAwwbQ2Vy
# dHVtIENvZGUgU2lnbmluZyBDQSBTSEEyAhA0Zdu5JR1ng04dFiv8rNM3MAkGBSsO
# AwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqG
# SIb3DQEJBDEWBBQa4j/hgNzM0Elum9aCv+98ifMNrDANBgkqhkiG9w0BAQEFAASC
# AQAIkLTYudGzml7evrWlycyzi2v27jrKm4MA0G0GXkXFY3oZ50wf9ShzRNBXEy5D
# DFwBzrusBbHnk/B+Yk0LQCt1cfQqD0sohM7CvP7up9vvnkxsCa5+3hpvHQIxCncX
# VVptTVjXbxcsAlHv/0eGy2owxdzmXSML8dNT+mucr71KwRQYYUP6I86NtYI/2sMd
# h4cavthNAnvqqotUcYXtQvOjOqvg98tEjEDaqsbzMnE2kalObLQxh/BI7QaceZFr
# CwUH1hCYdn2PcFmfrl/M7E2e6p/KuY9jDumC/g0VDw2E1zI6FFDknf5wxsvq3nRJ
# UhUpUZb7m3DTIgCpCqBVI+kJoYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0AgEB
# MHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9u
# MTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0g
# RzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzEL
# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE3MDcxMTE0MTE0MlowIwYJKoZI
# hvcNAQkEMRYEFEZ6pn61yNFRq6EnSXtOxUkCiELyMA0GCSqGSIb3DQEBAQUABIIB
# AHueSEHOBFbl7yJe2Da5l6PdIRLij2rF7GqSUaTHJ6JBAUsfoUGbqBOjKTXYX2bC
# vK/ibzxy+iCmppoTkGJSTX4UxxD922pHT/DF+Ro4HUDDqwmNHjWJDmitOzqFiwOA
# 6rmOQtifWra45CMtRN+sETFSctM9qU+skVWhDd/w3jIBXLKhYjjcp1prb2WZmuDj
# dV7vKErsJyuYIRZh9qohkONSCSUMy2x+PflbvFG5Dxn1fjaPpln3YvI9gzRuwW9c
# bHVoQsdduhg2k0ZrHkMx93Y8leSHxGFv2E1Zjxq2nhTLhDdREElw4++CQ1Ojtb1r
# o+03TT7cnRk64W8xYX7OP0w=
# SIG # End signature block

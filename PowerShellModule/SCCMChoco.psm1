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
    You must have SCCM console installed on your computer. On first run you will be asked to configure NuGet and Chocolatey repository (but don't be afraid, we will do it fo you). 
    Make sure you have PowerShell Gallery installed (https://msdn.microsoft.com/en-us/powershell/gallery/readme). 
    This version requires clients to have PowerShell Policy configured to Bypass for SCCM Agent (see screenshot in github repo)

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
        [ValidatePattern('^[A-Z]{2}[A-Z0-9]{1}$')]
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

    #test if already in SCCM context, switch context
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
    #check if Chocolatey installer exists in SCCM
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
    #Build ico file from BMP
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
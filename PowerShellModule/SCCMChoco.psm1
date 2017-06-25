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
    Add Chocolatey package to SCCM Software Library and deploy to user collection
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users"

    .EXAMPLE
    Add Chocolatey package to SCCM Software Library and deploy to device collection
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMDeviceCollectionName "All Users"

    .EXAMPLE
    Add Chocolatey package to SCCM Software Library and deploy to user collection
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users"

    .EXAMPLE
    Add Chocolatey package to SCCM Software Library, deploy to user collection, save icon in shared folder
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users" -IconsDir "\\SCCMSRV\CMSOURCE\Choco\Icons"

    .EXAMPLE
    Add Chocolatey package to SCCM Software Library, specify location of SCCM console and SiteCode
    Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMInstallDir "C:\Microsoft Configuration Manager\" - CMSiteCode "TST"
     
    .NOTES
    You must have SCCM console installed on your computer. On first run you will be asked to configure NuGet and Chocolatey repository (but don't be afraid, we will do it fo you). Make sure you have PowerShell Gallery installed (https://msdn.microsoft.com/en-us/powershell/gallery/readme)

    #>
    [CmdletBinding(DefaultParameterSetName="default")]
    param(
        [Parameter(Mandatory=$true,HelpMessage="Please provide URL of Choco package, for example: https://chocolatey.org/packages/Firefox")]
        [ValidatePattern('^(https://chocolatey.org/packages/)')]
        [string] $chocourl,
        [Parameter(ParameterSetName="DeployToUserCollection",Mandatory=$false,HelpMessage="Name of User Collection to deploy the software")]
        [string] $CMUserCollectionName,
        [Parameter(ParameterSetName="DeployToDeviceCollection",Mandatory=$false,HelpMessage="Name of Device Collection to deploy the software")]
        [string] $CMDeviceCollectionName,
        [Parameter(Mandatory=$false,HelpMessage="SCCM Site Code")]
        [ValidatePattern('^[A-Z]{2}[A-Z0-9]{1}$')]
        [string] $CMSiteCode,
        [Parameter(Mandatory=$false,HelpMessage="SCCM Installation direcotry (console is required due to PowerShell module)")]
        [ValidatePattern('^[A-Z]{2}[A-Z0-9]{1}$')]
        [string] $CMInstallDir,
        [Parameter(Mandatory=$false,HelpMessage="Network folder for icons")]
        [string] $IconsDir = $env:temp,
        [Parameter(Mandatory=$false,HelpMessage="SCCM folder for Chocolatey applications")]
        [string] $CMFolderName = "Chocolatey",
        [Parameter(Mandatory=$false,HelpMessage="Just test, don't actually make any permanent changes")]
        [switch] $WhatIf

    )



    #region prereqcheck
    Write-Host "Checking if Chocolatey repository is configured: " -NoNewline
    #Register Choco repository if not registered
    if ((Get-PSRepository "Chocolatey" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).count -eq 0)
    {   
        Write-Host "Installation required" -ForegroundColor Yellow
        if (-not $WhatIf)
        {
            Write-Host "#####################################" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "# Please install NuGet if requested #" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "# Select [Y] Yes or press enter     #" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "#####################################" -BackgroundColor Yellow -ForegroundColor Black 
            Register-PSRepository -Name "Chocolatey" -SourceLocation "https://chocolatey.org/api/v2"
            Write-Host "#################################################" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "# Please approve Chocolatey as a package source #" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "# Select [Y] Yes                                #" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "#################################################" -BackgroundColor Yellow -ForegroundColor Black 
            Install-PackageProvider -Name chocolatey
        }
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
        if ($CMInstallDir -ne $null)
        {
            $psdmodulepath = Join-Path -Path $CMInstallDir -ChildPath "AdminConsole\bin\ConfigurationManager.psd1"
        }
        else {
             $psdmodulepath = Join-Path -Path $env:SMS_ADMIN_UI_PATH -ChildPath "..\ConfigurationManager.psd1"
        }
        
        if ((Test-Path $psdmodulepath) -and (-not $WhatIf))
        {
            Import-Module $psdmodulepath
            Write-Host "Module loaded" -ForegroundColor Green
        }
        elseif ((Test-Path $psdmodulepath) -and $WhatIf)
        {
            Write-Host "Module available, not loaded (WhatIf enabled)" -ForegroundColor Green
        }
        else
        {
            Write-Host "Module cannot be found" -ForegroundColor Red
            Write-Host "Please provide SCCM console installation path (CMInstallDir parameter)" -ForegroundColor Red
            Throw "No SCCM module available"
        }
    }

    #test if already in SCCM context
    Write-Host "Connecting to SCCM site: " -NoNewline
    $location = Get-Location
    if ($location.Provider.Name -eq "CMSite")  
    {
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


    #endregion

    #region getpackageinfo

    #get package name
    $packageid = $chocourl.Split("/")[-1]

    #find package
    $package = Find-Package -Name $packageid -ProviderName chocolatey | Out-Null
    if ($package -eq $null)
    {
        throw "###########   Cannot find package, please verify if the URL is valid. ############"
    }


    #get icon url
    [xml]$swid = $package.SwidTagText
    #$swid.SoftwareIdentity.Meta.description
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
        Write-Host "OK" -BackgroundColor Green
    }
    catch
    {
        $iconfileico = $IconsDir + "\chocolatey.ico"
        if ((-not $WhatIf) -and (-not (test-path $iconfileico)))
        {
            Copy-Item "chocolatey.ico" $IconsDir -ErrorAction SilentlyContinue
        }

        Write-Host " couldn't prepare icon, using default one:" -ForegroundColor Yellow
        Write-Host $iconfileico -ForegroundColor Yellow
        Write-Host "Please update icon manually using SCCM console" -ForegroundColor Yellow
    }
    #endregion

    #return to initial location, leave things tidy behind yourself
    Set-Location $location
}
# SCCMChoco
## Description
PowerShell module integrating Chocolatey with SCCM. Provide URL of Chocolatey package, sit down, relax and wait for new applications to apprear in Software Center. 
Applications are built using PowerShell wrappers to download all content from Internet. Nothing is stored on SCCM distribution points, all software is available immidiately 

## Requirements
### Computer running the module:
- PowerShell Gallery installed - at least Windows 10 or Windows 7 with WMF 5.0 (https://msdn.microsoft.com/en-us/powershell/gallery/readme).
- SCCM Console installed
- NuGet and Chocolatey repository configured (module does it automatically)

### SCCM clients
- SCCM agent configured to bypass PowerShell execution policy. This settings affects only SCCM PowerShell environment it won't change execution policy for your system.
- Screenshots of settings:

https://github.com/kubasiatkowski/SCCMChoco/blob/master/PoweShellSettings.PNG

https://github.com/kubasiatkowski/SCCMChoco/blob/master/ClientSettings-big.jpg
- Further reading (search for "PowerShell execution policy"):

https://docs.microsoft.com/en-us/sccm/core/clients/deploy/about-client-settings#computer-agent


## How to use
1. Download Module content from https://github.com/kubasiatkowski/SCCMChoco/tree/master/PowerShellModule
2. Open PowerShell
3. Import module:

` import-module c:\*pathtodownloadedfiles*\PowerShellModule\SCCMChoco.psm1 `

4. Check examples and ejnoy :)

## Examples

- Just add Chocolatey package to SCCM Software Library

` Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" `

- Add Chocolatey package to SCCM Software Library and deploy to user collection

` Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users" `

- Add Chocolatey package to SCCM Software Library and deploy to device collection

` Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMDeviceCollectionName "All Users" `

 - Add Chocolatey package to SCCM Software Library, deploy to user collection, save icon in shared folder

` Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMUserCollectionName "All Users" -IconsDir "\\SCCMSRV\CMSOURCE\Choco\Icons" `

- Add Chocolatey package to SCCM Software Library, specify location of SCCM console and SiteCode

` Add-SCCMChocoApplication -chocourl "https://chocolatey.org/packages/Firefox" -CMInstallDir "C:\Microsoft Configuration Manager\" - CMSiteCode "TST" `

## ToDo

- Nice installer
- Integration with SCCM GUI
- Code signing

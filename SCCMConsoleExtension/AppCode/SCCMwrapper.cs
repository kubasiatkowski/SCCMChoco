using System;
using System.IO;
using Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation;
using Microsoft.ConfigurationManagement.ApplicationManagement;
using Microsoft.ConfigurationManagement.ManagementProvider;
using Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine;
using Microsoft.ConfigurationManagement.ApplicationManagement.Serialization;
using SCCMConsoleExtension.srChocolatey;

namespace SCCMConsoleExtension
{ 
    class SCCMWrapper
    {
        WqlConnectionManager connection;
        SmsNamedValuesDictionary namedValues;

        //constructor, connect to SCCM server
        public SCCMWrapper(string servername)
        {
            try
            {
                namedValues = new SmsNamedValuesDictionary();
                connection = new WqlConnectionManager(namedValues);
                connection.Connect(servername.ToUpper());
            }
            catch (Exception exc)
            {
                throw exc;
            }
        }

        //ToDo
        // -add Icon
        // -move to Chocolatey folder
        // -test
        // -Exception handling

        public void AddChocolatey()
        {
            NamedObject.DefaultScope = "SCCMChoco";
            Application application = new Application { Title ="Chocolatey"};
            AppDisplayInfo appDisplayInfo = new AppDisplayInfo { Title ="Chocolatey", Description = "Chocolatey package manager", Language = "en -US", Publisher = "Chocolatey.org" };
            //appDisp.Icon 
            //appDisplayInfo.
            application.DisplayInfo.Add(appDisplayInfo);

            //Add deployment type
            ScriptInstaller installer = new ScriptInstaller();
            installer.InstallCommandLine = ("powershell -executionpolicy RemoteSigned -command \"iwr https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression\"");


            //Add detection method           
            String detectionScript = "if (test-path \"C:\\ProgramData\\Chocolatey\\choco.exe\"){Write-host \"installed\"}";
            installer.DetectionScript = new Script { Text = detectionScript, Language = ScriptLanguage.PowerShell.ToString() };

            //Add deployment type
            DeploymentType dt = new DeploymentType(installer, ScriptInstaller.TechnologyId, NativeHostingTechnology.TechnologyId);
            dt.Title = "Chocolatey Installer";
            application.DeploymentTypes.Add(dt);

            //Save to SCCM
            ApplicationFactory factory = new ApplicationFactory();
            AppManWrapper wrapper = AppManWrapper.Create(connection, factory) as AppManWrapper;
            wrapper.InnerAppManObject = application;
            factory.PrepareResultObject(wrapper);
            wrapper.InnerResultObject.Put();

        }


        //ToDo
        // -add dependencies
        // -add icon
        // -move to Chocolatey folder
        //Exception handling
        public int AddApplication(V2FeedPackage package)
           // package.Title, package.Summary, package.Authors, package.PackageSourceUrl
        {
            //Add application 
            NamedObject.DefaultScope ="SCCMChoco";
            Application application = new Application { Title = package.Title };
            AppDisplayInfo appDisplayInfo = new AppDisplayInfo { Title = package.Title, Description = package.Summary, Language = "en-US" };
            //appDisp.Icon 
            //appDisplayInfo.
            application.DisplayInfo.Add(appDisplayInfo);

            //Add deployment type
            ScriptInstaller installer = new ScriptInstaller();
            installer.InstallCommandLine = ("c:\\ProgramData\\chocolatey\\bin\\choco install "+ package.Id + " -y") ;
            installer.UninstallCommandLine = ("c:\\ProgramData\\chocolatey\\bin\\choco uninstall " + package.Id + " -y");

            //Add detection method
            String detectionScript = "$packacgename = \"" + package.Id + "\"; try {";
            detectionScript += "c:\\ProgramData\\chocolatey\\bin\\choco list --local-only | ?{$_ -match ";
            detectionScript += "$packacgename} | Out-Null; if ($matches[0] -gt 0){Write-Host \"installed\"}";
            detectionScript += "}catch { }";         
            installer.DetectionScript = new Script { Text = detectionScript, Language = ScriptLanguage.PowerShell.ToString() };

            //build deployment type
            DeploymentType dt = new DeploymentType(installer, ScriptInstaller.TechnologyId, NativeHostingTechnology.TechnologyId);
            dt.Title = package.Id;
            application.DeploymentTypes.Add(dt);
            
            //Add to SCCM
            ApplicationFactory factory = new ApplicationFactory();
            AppManWrapper wrapper = AppManWrapper.Create(connection, factory) as AppManWrapper;
            wrapper.InnerAppManObject = application;
            factory.PrepareResultObject(wrapper);
            wrapper.InnerResultObject.Put();

            return 0;
        }

    }
}

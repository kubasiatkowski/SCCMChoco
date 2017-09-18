using System;
using System.IO;
using Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation;
using Microsoft.ConfigurationManagement.ApplicationManagement;
using Microsoft.ConfigurationManagement.ManagementProvider;
using Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine;
using Microsoft.ConfigurationManagement.ApplicationManagement.Serialization;

namespace SCCMConsoleExtension
{ 
    class SCCMWrapper
    {
        WqlConnectionManager connection;
        SmsNamedValuesDictionary namedValues;
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

        public int AddApplication(string title, string description)
        {
            //Add application 
            NamedObject.DefaultScope ="SCCMChoco";
            Application application = new Application { Title = title };
            application.DisplayInfo.Add(new AppDisplayInfo { Title = title, Description = description, Language = "en-US"});

            //Add deployment type
                ScriptInstaller installer = new ScriptInstaller();
            installer.InstallCommandLine = ("choco install title" + title) ;
       
            
            //Add detection method
            installer.DetectionScript = new Script { Text = title, Language = ScriptLanguage.PowerShell.ToString() };

            //build deployment type
            DeploymentType dt = new DeploymentType(installer, ScriptInstaller.TechnologyId, NativeHostingTechnology.TechnologyId);
            dt.Title = title;

            application.DeploymentTypes.Add(dt);



            ApplicationFactory factory = new ApplicationFactory();
            AppManWrapper wrapper = AppManWrapper.Create(connection, factory) as AppManWrapper;
            wrapper.InnerAppManObject = application;
            factory.PrepareResultObject(wrapper);
            wrapper.InnerResultObject.Put();

            return 0;
        }
    }
}

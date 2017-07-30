using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.ConfigurationManagement.ApplicationManagement;
using Microsoft.ConfigurationManagement.ManagementProvider;
using Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine;

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
    }
}

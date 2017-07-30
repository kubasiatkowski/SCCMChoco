using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SCCMConsoleExtension
{
    class REGHelper
    {
        const string userRoot = "";


        public REGHelper()
        { }

        public string read(string key, string valueName)
        {
            return (string)Registry.GetValue(key, valueName, null);
        } 
        public string read(string valueName)
        {
            return (string)Registry.GetValue(@"HKEY_CURRENT_USER\Software\SCCMChoco", valueName, null);
        }
        public void write(string key, string valueName, string value)
        {

        }

        public void write(string valueName, string value)
        {
            Registry.SetValue(@"HKEY_CURRENT_USER\Software\SCCMChoco", valueName, value);
        }
  
    }
}

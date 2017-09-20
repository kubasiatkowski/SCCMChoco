using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SCCMConsoleExtension
{
    public partial class SCCMChocoGUI : Form
    {
        string cmServerName;
        SCCMWrapper sccmWrapper;
        srChocolatey.V2FeedPackage package;
        public SCCMChocoGUI(string[] args)
        {
            InitializeComponent();
            REGHelper regHelper = new REGHelper();
            
            //read last server used by SCCM console
            cmServerName = regHelper.read("cmServerName");
            if (cmServerName == null)
            {
                cmServerName = regHelper.read(@"HKEY_CURRENT_USER\SOFTWARE\Microsoft\ConfigMgr10\AdminUI\MRU\1", "ServerName");
                regHelper.write("cmServerName", cmServerName);
            }
            updateStatusBar();               
        }

        //connect to SCCM and show connection status 
        //ToDo
        //-rename to be more meaningful
        //-error handling
        public void updateStatusBar()
        {
            REGHelper regHelper = new REGHelper();
            cmServerName = regHelper.read("cmServerName");
            try
            {
                sccmWrapper = new SCCMWrapper(cmServerName);
                stulblStatus.Text = "Connected to: " + cmServerName;
            }
            catch
            {
                stulblStatus.Text = "Cannot connect to: " + cmServerName + " check settings";
            }
        }

        //search packages in public Chocolatey repository
        private void cmdSearch_Click(object sender, EventArgs e)
        {
            var srChoco = new srChocolatey.FeedContext_x0060_1(new System.Uri("https://chocolatey.org/api/v2"));
            int i = 0;
            srChoco.Packages.Execute();
            dgdSearchResults.Rows.Clear();
            rtfPackageDetails.Clear();
            cmdAddToSCCM.Enabled = false;
            foreach (var package in srChoco.Packages.Where(c => c.Title.Contains(txtSearch.Text) && c.IsLatestVersion == true).OrderByDescending(c => c.DownloadCount))
            {
                dgdSearchResults.Rows.Add(package.Title, package.Version, package.DownloadCount, package);

                i++;
            }
            stulblStatus.Text = "Found: " + i + " packages";
        }

        //show details of selected package
        //ToDo:
        //-better handling of icons which cannot be displayed (broken URL, SVG files, etc.)
        private void dgdSearchResults_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            DataGridView dgv = (DataGridView)sender;
            //highlight full row
            dgv.Rows[dgv.SelectedCells[0].RowIndex].Selected = true;

            //get package object
            package = (srChocolatey.V2FeedPackage)dgv.Rows[dgv.SelectedCells[0].RowIndex].Cells[3].Value;

            //display basic package details
            cmdAddToSCCM.Enabled = true;
            lblPackageName.Text = package.Title;
            rtfPackageInfo.Text = "Version: " + package.Version + Environment.NewLine;
            rtfPackageInfo.AppendText("Last updated: " + package.LastUpdated + Environment.NewLine);
            rtfPackageInfo.AppendText("Downloads: " + package.DownloadCount);
            try
            {
                picIcon.LoadAsync(package.IconUrl);
            }
            catch {
               // picIcon.Image = (Image)(Properties.Resources.ResourceManager.GetObject("SCCMChoco.ico"));
            }

            //show all metadata
            rtfPackageDetails.Clear();
            rtfPackageDetails.DeselectAll();
           
            foreach (PropertyInfo propertyInfo in package.GetType().GetProperties())
            {
                rtfPackageDetails.SelectionFont = new Font(rtfPackageDetails.SelectionFont, FontStyle.Bold);
                rtfPackageDetails.AppendText(propertyInfo.Name + ": ");
                rtfPackageDetails.SelectionFont = new Font(rtfPackageDetails.SelectionFont, FontStyle.Regular);
                rtfPackageDetails.AppendText(propertyInfo.GetValue(package) + Environment.NewLine);         
            }

        }

        //initiate search by pressing "enter"
        private void txtSearch_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                cmdSearch_Click(sender, e);
            }
        }

        //show settings dialog
        private void settingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Settings s = new Settings();
            s.FormClosing += new FormClosingEventHandler(settingsToolStripMenuItem_FormClosing);
            s.Show();
        }

        //update status when closing settings dialog
        private void settingsToolStripMenuItem_FormClosing(object sender, EventArgs e)
        {
            this.updateStatusBar();
        }
        //exit applicaion
        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        //show about dialog
        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            About a = new About();
            a.Show();
        }

        //add application o SCCM
        private void cmdAddToSCCM_Click(object sender, EventArgs e)
        {
            //ToDo
            //-better progress display
            //-do something with exceptions
            try
            {
                sccmWrapper.AddApplication(package);
            }
            catch
            {

            }
            stulblStatus.Text = package.Title + " added to SCCM";
        }
    }
}

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
        string[] args;
        string cmSiteCode;
        string cmServerName;
        public SCCMChocoGUI(string[] args)
        {
            InitializeComponent();
            this.args = args;
            foreach (string arg in args)
            {
                rtfPackageDetails.Text += arg;
            }
            cmSiteCode = (string)Registry.GetValue(@"HKEY_CURRENT_USER\SOFTWARE\Microsoft\ConfigMgr10\AdminUI\MRU\1", "SiteCode", null);
            cmServerName = (string)Registry.GetValue(@"HKEY_CURRENT_USER\SOFTWARE\Microsoft\ConfigMgr10\AdminUI\MRU\1", "ServerName", null);

            stulblStatus.Text += " Connected to: " + cmServerName + " Site: " + cmSiteCode;
        }


        private void menuStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

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

        private void dgdSearchResults_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            DataGridView dgv = (DataGridView)sender;
            dgv.Rows[dgv.SelectedCells[0].RowIndex].Selected = true;
            srChocolatey.V2FeedPackage package = (srChocolatey.V2FeedPackage)dgv.Rows[dgv.SelectedCells[0].RowIndex].Cells[3].Value;
            cmdAddToSCCM.Enabled = true;
            lblPackageName.Text = package.Title;
            rtfPackageInfo.Text = "Version: " + package.Version + Environment.NewLine;
            rtfPackageInfo.AppendText("Last updated: " + package.LastUpdated + Environment.NewLine);
            rtfPackageInfo.AppendText("Downloads: " + package.DownloadCount);
            try
            {
                picIcon.LoadAsync(package.IconUrl);
            }
            catch { }
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

        private void txtSearch_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                cmdSearch_Click(sender, e);
            }
        }

        private void onlineHelpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OnlineHelp f = new OnlineHelp();
            f.Show();
        }
    }
}

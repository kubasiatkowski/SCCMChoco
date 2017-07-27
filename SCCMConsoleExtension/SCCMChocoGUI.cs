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
        public SCCMChocoGUI()
        {
            InitializeComponent();
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

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.WindowsAPICodePack.Dialogs;
using Microsoft.ConfigurationManagement.ManagementProvider;
using System.Windows;

namespace SCCMConsoleExtension
{
    public partial class Settings : Form
    {
        public Settings()
        {
            InitializeComponent();
            REGHelper regHelper = new REGHelper();
            string saveIcons = regHelper.read("saveIcons");
            if (saveIcons == "1")
            {
                chkIcons.Checked = true;
            }
            txtIconsDir.Text = regHelper.read("iconsDir");

        }

        private void cmdBrowse_Click(object sender, EventArgs e)
        {
          
            CommonOpenFileDialog dialog = new CommonOpenFileDialog();
            dialog.InitialDirectory = txtIconsDir.Text;
            dialog.IsFolderPicker = true;
            this.TopMost = false;
            if (dialog.ShowDialog() == CommonFileDialogResult.Ok)
            {
                txtIconsDir.Text=dialog.FileName;
            }
            this.TopMost = true;
        }


        private void chkIcons_CheckedChanged(object sender, EventArgs e)
        {

            if (chkIcons.Checked)
            {
                pnlIcons.Enabled = true;
            }
            else
            {
                pnlIcons.Enabled = false;
            }
        }

        private void cmdCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void cmdSave_Click(object sender, EventArgs e)
        {
            SCCMWrapper sccmWrapper;
            //WqlConnectionManager connectionManager = new WqlConnectionManager();
            try
            {
                sccmWrapper = new SCCMWrapper(txtServer.Text);
                REGHelper regHelper = new REGHelper();
                regHelper.write("cmServerName",txtServer.Text);
                if (chkIcons.Checked)
                {
                    regHelper.write("iconsDir", txtIconsDir.Text);
                    regHelper.write("saveIcons","1");
                }
                else
                    regHelper.write("saveIcons", "0");
                this.Close();
            }
            catch (SmsException ex)
            {
                //MessageBox.Show("Failed to Connect. Error: " + ex.Message + txtServer.Text.ToUpper());


                string caption = "Failed to connect";
                string message = "Cannot connect to: " + txtServer.Text;
                message += "\n\rCheck server name and connectivity \n\r \n\r";
                message += ex.Message;
                MessageBoxButtons buttons = MessageBoxButtons.OKCancel;
                MessageBoxIcon icon = MessageBoxIcon.Error;
                MessageBox.Show(message, caption, buttons, icon);
            }
            catch (UnauthorizedAccessException ex)
            {
                string caption = "Failed to authenticate";
                string message = "Check your credentials.";
                MessageBoxButtons buttons = MessageBoxButtons.OKCancel;
                MessageBoxIcon icon = MessageBoxIcon.Error;
                MessageBox.Show(message, caption, buttons, icon);
               // MessageBox.Show("Failed to authenticate. Error:" + ex.Message);
            }



        }

        private void Settings_Load(object sender, EventArgs e)
        {
            REGHelper regHelper = new REGHelper();
            txtServer.Text = regHelper.read("cmServerName");
        }
    }
}

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SCCMConsoleExtension
{
    public partial class About : Form
    {
        public About()
        {
            InitializeComponent();
            lblVer.Text += Application.ProductVersion;
        }

        private void lnkProjectPage_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(lnkProjectPage.Text);
        }

        private void cmdClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}

namespace SCCMConsoleExtension
{
    partial class Settings
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.lblServer = new System.Windows.Forms.Label();
            this.txtServer = new System.Windows.Forms.TextBox();
            this.txtIconsDir = new System.Windows.Forms.TextBox();
            this.lblIconsDir = new System.Windows.Forms.Label();
            this.cmdSave = new System.Windows.Forms.Button();
            this.cmdCancel = new System.Windows.Forms.Button();
            this.cmdBrowse = new System.Windows.Forms.Button();
            this.chkIcons = new System.Windows.Forms.CheckBox();
            this.pnlIcons = new System.Windows.Forms.Panel();
            this.pnlIcons.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblServer
            // 
            this.lblServer.AutoSize = true;
            this.lblServer.Location = new System.Drawing.Point(15, 18);
            this.lblServer.Name = "lblServer";
            this.lblServer.Size = new System.Drawing.Size(57, 13);
            this.lblServer.TabIndex = 0;
            this.lblServer.Text = "Site server";
            // 
            // txtServer
            // 
            this.txtServer.Location = new System.Drawing.Point(15, 34);
            this.txtServer.Name = "txtServer";
            this.txtServer.Size = new System.Drawing.Size(256, 20);
            this.txtServer.TabIndex = 1;
            // 
            // txtIconsDir
            // 
            this.txtIconsDir.Location = new System.Drawing.Point(0, 25);
            this.txtIconsDir.Name = "txtIconsDir";
            this.txtIconsDir.Size = new System.Drawing.Size(257, 20);
            this.txtIconsDir.TabIndex = 5;
            // 
            // lblIconsDir
            // 
            this.lblIconsDir.AutoSize = true;
            this.lblIconsDir.Location = new System.Drawing.Point(0, 9);
            this.lblIconsDir.Name = "lblIconsDir";
            this.lblIconsDir.Size = new System.Drawing.Size(76, 13);
            this.lblIconsDir.TabIndex = 4;
            this.lblIconsDir.Text = "Icons directory";
            // 
            // cmdSave
            // 
            this.cmdSave.Location = new System.Drawing.Point(15, 226);
            this.cmdSave.Name = "cmdSave";
            this.cmdSave.Size = new System.Drawing.Size(75, 23);
            this.cmdSave.TabIndex = 6;
            this.cmdSave.Text = "Save";
            this.cmdSave.UseVisualStyleBackColor = true;
            this.cmdSave.Click += new System.EventHandler(this.cmdSave_Click);
            // 
            // cmdCancel
            // 
            this.cmdCancel.Location = new System.Drawing.Point(197, 226);
            this.cmdCancel.Name = "cmdCancel";
            this.cmdCancel.Size = new System.Drawing.Size(75, 23);
            this.cmdCancel.TabIndex = 7;
            this.cmdCancel.Text = "Cancel";
            this.cmdCancel.UseVisualStyleBackColor = true;
            this.cmdCancel.Click += new System.EventHandler(this.cmdCancel_Click);
            // 
            // cmdBrowse
            // 
            this.cmdBrowse.Location = new System.Drawing.Point(0, 51);
            this.cmdBrowse.Name = "cmdBrowse";
            this.cmdBrowse.Size = new System.Drawing.Size(75, 23);
            this.cmdBrowse.TabIndex = 8;
            this.cmdBrowse.Text = "Browse";
            this.cmdBrowse.UseVisualStyleBackColor = true;
            this.cmdBrowse.Click += new System.EventHandler(this.cmdBrowse_Click);
            // 
            // chkIcons
            // 
            this.chkIcons.AutoSize = true;
            this.chkIcons.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.chkIcons.Location = new System.Drawing.Point(15, 62);
            this.chkIcons.Name = "chkIcons";
            this.chkIcons.Size = new System.Drawing.Size(80, 17);
            this.chkIcons.TabIndex = 9;
            this.chkIcons.Text = "Save Icons";
            this.chkIcons.UseVisualStyleBackColor = true;
            this.chkIcons.CheckedChanged += new System.EventHandler(this.chkIcons_CheckedChanged);
            // 
            // pnlIcons
            // 
            this.pnlIcons.Controls.Add(this.lblIconsDir);
            this.pnlIcons.Controls.Add(this.txtIconsDir);
            this.pnlIcons.Controls.Add(this.cmdBrowse);
            this.pnlIcons.Enabled = false;
            this.pnlIcons.Location = new System.Drawing.Point(15, 80);
            this.pnlIcons.Name = "pnlIcons";
            this.pnlIcons.Size = new System.Drawing.Size(269, 94);
            this.pnlIcons.TabIndex = 10;
            // 
            // Settings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(284, 261);
            this.Controls.Add(this.pnlIcons);
            this.Controls.Add(this.chkIcons);
            this.Controls.Add(this.cmdCancel);
            this.Controls.Add(this.cmdSave);
            this.Controls.Add(this.txtServer);
            this.Controls.Add(this.lblServer);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Settings";
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Settings";
            this.TopMost = true;
            this.Load += new System.EventHandler(this.Settings_Load);
            this.pnlIcons.ResumeLayout(false);
            this.pnlIcons.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblServer;
        private System.Windows.Forms.TextBox txtServer;
        private System.Windows.Forms.TextBox txtIconsDir;
        private System.Windows.Forms.Label lblIconsDir;
        private System.Windows.Forms.Button cmdSave;
        private System.Windows.Forms.Button cmdCancel;
        private System.Windows.Forms.Button cmdBrowse;
        private System.Windows.Forms.CheckBox chkIcons;
        private System.Windows.Forms.Panel pnlIcons;
    }
}
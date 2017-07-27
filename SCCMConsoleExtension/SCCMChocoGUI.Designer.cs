namespace SCCMConsoleExtension
{
    partial class SCCMChocoGUI
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
            this.txtSearch = new System.Windows.Forms.TextBox();
            this.cmdSearch = new System.Windows.Forms.Button();
            this.dgdSearchResults = new System.Windows.Forms.DataGridView();
            this.mnuMenu = new System.Windows.Forms.MenuStrip();
            this.toolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.editToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.settingsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.onlineHelpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.cmdAddToSCCM = new System.Windows.Forms.Button();
            this.rtfPackageDetails = new System.Windows.Forms.RichTextBox();
            this.stuStatus = new System.Windows.Forms.StatusStrip();
            this.stulblStatus = new System.Windows.Forms.ToolStripStatusLabel();
            this.picIcon = new System.Windows.Forms.PictureBox();
            this.lblPackageName = new System.Windows.Forms.Label();
            this.rtfPackageInfo = new System.Windows.Forms.RichTextBox();
            this.packageName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.version = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.downloads = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.chocoObject = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dgdSearchResults)).BeginInit();
            this.mnuMenu.SuspendLayout();
            this.stuStatus.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picIcon)).BeginInit();
            this.SuspendLayout();
            // 
            // txtSearch
            // 
            this.txtSearch.Location = new System.Drawing.Point(3, 30);
            this.txtSearch.Name = "txtSearch";
            this.txtSearch.Size = new System.Drawing.Size(213, 20);
            this.txtSearch.TabIndex = 1;
            this.txtSearch.KeyUp += new System.Windows.Forms.KeyEventHandler(this.txtSearch_KeyUp);
            // 
            // cmdSearch
            // 
            this.cmdSearch.Location = new System.Drawing.Point(222, 29);
            this.cmdSearch.Name = "cmdSearch";
            this.cmdSearch.Size = new System.Drawing.Size(72, 23);
            this.cmdSearch.TabIndex = 2;
            this.cmdSearch.Text = "Search";
            this.cmdSearch.UseVisualStyleBackColor = true;
            this.cmdSearch.Click += new System.EventHandler(this.cmdSearch_Click);
            // 
            // dgdSearchResults
            // 
            this.dgdSearchResults.AllowUserToAddRows = false;
            this.dgdSearchResults.AllowUserToDeleteRows = false;
            this.dgdSearchResults.AllowUserToOrderColumns = true;
            this.dgdSearchResults.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dgdSearchResults.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgdSearchResults.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.packageName,
            this.version,
            this.downloads,
            this.chocoObject});
            this.dgdSearchResults.Location = new System.Drawing.Point(3, 56);
            this.dgdSearchResults.MultiSelect = false;
            this.dgdSearchResults.Name = "dgdSearchResults";
            this.dgdSearchResults.ReadOnly = true;
            this.dgdSearchResults.RowHeadersVisible = false;
            this.dgdSearchResults.RowTemplate.ReadOnly = true;
            this.dgdSearchResults.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dgdSearchResults.ShowEditingIcon = false;
            this.dgdSearchResults.Size = new System.Drawing.Size(417, 380);
            this.dgdSearchResults.TabIndex = 3;
            this.dgdSearchResults.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgdSearchResults_CellContentClick);
            this.dgdSearchResults.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgdSearchResults_CellContentClick);
            this.dgdSearchResults.CellContentDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgdSearchResults_CellContentClick);
            this.dgdSearchResults.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgdSearchResults_CellContentClick);
            // 
            // mnuMenu
            // 
            this.mnuMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem1,
            this.editToolStripMenuItem,
            this.helpToolStripMenuItem});
            this.mnuMenu.Location = new System.Drawing.Point(0, 0);
            this.mnuMenu.Name = "mnuMenu";
            this.mnuMenu.Size = new System.Drawing.Size(884, 24);
            this.mnuMenu.TabIndex = 1;
            this.mnuMenu.Text = "menuStrip1";
            this.mnuMenu.ItemClicked += new System.Windows.Forms.ToolStripItemClickedEventHandler(this.menuStrip1_ItemClicked);
            // 
            // toolStripMenuItem1
            // 
            this.toolStripMenuItem1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitToolStripMenuItem});
            this.toolStripMenuItem1.Name = "toolStripMenuItem1";
            this.toolStripMenuItem1.Size = new System.Drawing.Size(37, 20);
            this.toolStripMenuItem1.Text = "File";
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(92, 22);
            this.exitToolStripMenuItem.Text = "Exit";
            // 
            // editToolStripMenuItem
            // 
            this.editToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.settingsToolStripMenuItem});
            this.editToolStripMenuItem.Name = "editToolStripMenuItem";
            this.editToolStripMenuItem.Size = new System.Drawing.Size(39, 20);
            this.editToolStripMenuItem.Text = "Edit";
            // 
            // settingsToolStripMenuItem
            // 
            this.settingsToolStripMenuItem.Name = "settingsToolStripMenuItem";
            this.settingsToolStripMenuItem.Size = new System.Drawing.Size(116, 22);
            this.settingsToolStripMenuItem.Text = "Settings";
            // 
            // helpToolStripMenuItem
            // 
            this.helpToolStripMenuItem.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right;
            this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.onlineHelpToolStripMenuItem,
            this.aboutToolStripMenuItem});
            this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
            this.helpToolStripMenuItem.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.helpToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.helpToolStripMenuItem.Text = "Help";
            // 
            // onlineHelpToolStripMenuItem
            // 
            this.onlineHelpToolStripMenuItem.Name = "onlineHelpToolStripMenuItem";
            this.onlineHelpToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
            this.onlineHelpToolStripMenuItem.Text = "Online help";
            this.onlineHelpToolStripMenuItem.Click += new System.EventHandler(this.onlineHelpToolStripMenuItem_Click);
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(135, 22);
            this.aboutToolStripMenuItem.Text = "About";
            // 
            // cmdAddToSCCM
            // 
            this.cmdAddToSCCM.Enabled = false;
            this.cmdAddToSCCM.Location = new System.Drawing.Point(789, 85);
            this.cmdAddToSCCM.Name = "cmdAddToSCCM";
            this.cmdAddToSCCM.Size = new System.Drawing.Size(83, 23);
            this.cmdAddToSCCM.TabIndex = 1;
            this.cmdAddToSCCM.Text = "Add to SCCM";
            this.cmdAddToSCCM.UseVisualStyleBackColor = true;
            // 
            // rtfPackageDetails
            // 
            this.rtfPackageDetails.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.rtfPackageDetails.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rtfPackageDetails.Location = new System.Drawing.Point(426, 114);
            this.rtfPackageDetails.Name = "rtfPackageDetails";
            this.rtfPackageDetails.ReadOnly = true;
            this.rtfPackageDetails.Size = new System.Drawing.Size(446, 322);
            this.rtfPackageDetails.TabIndex = 0;
            this.rtfPackageDetails.Text = "";
            // 
            // stuStatus
            // 
            this.stuStatus.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.stulblStatus});
            this.stuStatus.Location = new System.Drawing.Point(0, 439);
            this.stuStatus.Name = "stuStatus";
            this.stuStatus.Size = new System.Drawing.Size(884, 22);
            this.stuStatus.SizingGrip = false;
            this.stuStatus.TabIndex = 4;
            this.stuStatus.Text = "statusStrip1";
            // 
            // stulblStatus
            // 
            this.stulblStatus.Name = "stulblStatus";
            this.stulblStatus.Size = new System.Drawing.Size(272, 17);
            this.stulblStatus.Text = "https://github.com/kubasiatkowski/SCCMChoco/";
            // 
            // picIcon
            // 
            this.picIcon.Location = new System.Drawing.Point(426, 30);
            this.picIcon.Name = "picIcon";
            this.picIcon.Size = new System.Drawing.Size(69, 78);
            this.picIcon.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picIcon.TabIndex = 5;
            this.picIcon.TabStop = false;
            // 
            // lblPackageName
            // 
            this.lblPackageName.AutoSize = true;
            this.lblPackageName.Font = new System.Drawing.Font("Segoe UI Semibold", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPackageName.Location = new System.Drawing.Point(501, 30);
            this.lblPackageName.Name = "lblPackageName";
            this.lblPackageName.Size = new System.Drawing.Size(58, 30);
            this.lblPackageName.TabIndex = 6;
            this.lblPackageName.Text = "label";
            // 
            // rtfPackageInfo
            // 
            this.rtfPackageInfo.BackColor = System.Drawing.SystemColors.Control;
            this.rtfPackageInfo.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.rtfPackageInfo.Location = new System.Drawing.Point(506, 63);
            this.rtfPackageInfo.Name = "rtfPackageInfo";
            this.rtfPackageInfo.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.None;
            this.rtfPackageInfo.Size = new System.Drawing.Size(277, 45);
            this.rtfPackageInfo.TabIndex = 8;
            this.rtfPackageInfo.Text = "";
            // 
            // packageName
            // 
            this.packageName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.packageName.FillWeight = 317F;
            this.packageName.HeaderText = "Name";
            this.packageName.MinimumWidth = 300;
            this.packageName.Name = "packageName";
            this.packageName.ReadOnly = true;
            this.packageName.Width = 300;
            // 
            // version
            // 
            this.version.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.version.HeaderText = "Version";
            this.version.Name = "version";
            this.version.ReadOnly = true;
            this.version.Visible = false;
            this.version.Width = 67;
            // 
            // downloads
            // 
            this.downloads.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.downloads.HeaderText = "Downloads";
            this.downloads.MinimumWidth = 100;
            this.downloads.Name = "downloads";
            this.downloads.ReadOnly = true;
            // 
            // chocoObject
            // 
            this.chocoObject.HeaderText = "ChocoObject";
            this.chocoObject.Name = "chocoObject";
            this.chocoObject.ReadOnly = true;
            this.chocoObject.Visible = false;
            // 
            // SCCMChocoGUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(884, 461);
            this.Controls.Add(this.rtfPackageInfo);
            this.Controls.Add(this.lblPackageName);
            this.Controls.Add(this.picIcon);
            this.Controls.Add(this.stuStatus);
            this.Controls.Add(this.mnuMenu);
            this.Controls.Add(this.cmdAddToSCCM);
            this.Controls.Add(this.rtfPackageDetails);
            this.Controls.Add(this.txtSearch);
            this.Controls.Add(this.cmdSearch);
            this.Controls.Add(this.dgdSearchResults);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.HelpButton = true;
            this.MaximizeBox = false;
            this.Name = "SCCMChocoGUI";
            this.Text = "SCCMChoco";
            ((System.ComponentModel.ISupportInitialize)(this.dgdSearchResults)).EndInit();
            this.mnuMenu.ResumeLayout(false);
            this.mnuMenu.PerformLayout();
            this.stuStatus.ResumeLayout(false);
            this.stuStatus.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picIcon)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
        private System.Windows.Forms.TextBox txtSearch;
        private System.Windows.Forms.Button cmdSearch;
        private System.Windows.Forms.DataGridView dgdSearchResults;
        private System.Windows.Forms.Button cmdAddToSCCM;
        private System.Windows.Forms.RichTextBox rtfPackageDetails;
        private System.Windows.Forms.MenuStrip mnuMenu;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem1;
        private System.Windows.Forms.StatusStrip stuStatus;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem editToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem settingsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem onlineHelpToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
        private System.Windows.Forms.ToolStripStatusLabel stulblStatus;
        private System.Windows.Forms.PictureBox picIcon;
        private System.Windows.Forms.Label lblPackageName;
        private System.Windows.Forms.RichTextBox rtfPackageInfo;
        private System.Windows.Forms.DataGridViewTextBoxColumn packageName;
        private System.Windows.Forms.DataGridViewTextBoxColumn version;
        private System.Windows.Forms.DataGridViewTextBoxColumn downloads;
        private System.Windows.Forms.DataGridViewTextBoxColumn chocoObject;
    }
}


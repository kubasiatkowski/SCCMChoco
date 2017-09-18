namespace SCCMConsoleExtension
{
    partial class About
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
            this.lblTitle = new System.Windows.Forms.Label();
            this.lblVer = new System.Windows.Forms.Label();
            this.lnkProjectPage = new System.Windows.Forms.LinkLabel();
            this.cmdClose = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.AutoSize = true;
            this.lblTitle.Font = new System.Drawing.Font("Microsoft Sans Serif", 16.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblTitle.Location = new System.Drawing.Point(27, 19);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(274, 51);
            this.lblTitle.TabIndex = 0;
            this.lblTitle.Text = "SCCMChoco";
            // 
            // lblVer
            // 
            this.lblVer.AutoSize = true;
            this.lblVer.Location = new System.Drawing.Point(33, 81);
            this.lblVer.Name = "lblVer";
            this.lblVer.Size = new System.Drawing.Size(45, 13);
            this.lblVer.TabIndex = 1;
            this.lblVer.Text = "Version:";
            // 
            // lnkProjectPage
            // 
            this.lnkProjectPage.AutoSize = true;
            this.lnkProjectPage.Location = new System.Drawing.Point(33, 152);
            this.lnkProjectPage.Name = "lnkProjectPage";
            this.lnkProjectPage.Size = new System.Drawing.Size(244, 13);
            this.lnkProjectPage.TabIndex = 2;
            this.lnkProjectPage.TabStop = true;
            this.lnkProjectPage.Text = "https://github.com/kubasiatkowski/SCCMChoco/";
            this.lnkProjectPage.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.lnkProjectPage_LinkClicked);
            // 
            // cmdClose
            // 
            this.cmdClose.Location = new System.Drawing.Point(146, 194);
            this.cmdClose.Name = "cmdClose";
            this.cmdClose.Size = new System.Drawing.Size(75, 23);
            this.cmdClose.TabIndex = 3;
            this.cmdClose.Text = "Ok";
            this.cmdClose.UseVisualStyleBackColor = true;
            this.cmdClose.Click += new System.EventHandler(this.cmdClose_Click);
            // 
            // About
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(486, 229);
            this.Controls.Add(this.cmdClose);
            this.Controls.Add(this.lnkProjectPage);
            this.Controls.Add(this.lblVer);
            this.Controls.Add(this.lblTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "About";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "About";
            this.TopMost = true;
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.Label lblVer;
        private System.Windows.Forms.LinkLabel lnkProjectPage;
        private System.Windows.Forms.Button cmdClose;
    }
}
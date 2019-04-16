namespace TestAsyncInFormsApp
{
    partial class Form1
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
            this.components = new System.ComponentModel.Container();
            this.btnError = new System.Windows.Forms.Button();
            this.btnWarn = new System.Windows.Forms.Button();
            this.btnAudit = new System.Windows.Forms.Button();
            this.btnTrace = new System.Windows.Forms.Button();
            this.tmrClock = new System.Windows.Forms.Timer(this.components);
            this.lblClock = new System.Windows.Forms.Label();
            this.lblErrorIC = new System.Windows.Forms.Label();
            this.btnErrorAwait = new System.Windows.Forms.Button();
            this.btnWarnAwait = new System.Windows.Forms.Button();
            this.btnAuditAwait = new System.Windows.Forms.Button();
            this.btnTraceAwait = new System.Windows.Forms.Button();
            this.lblWarnIC = new System.Windows.Forms.Label();
            this.lblAuditIC = new System.Windows.Forms.Label();
            this.lblTraceIC = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // btnError
            // 
            this.btnError.Location = new System.Drawing.Point(12, 21);
            this.btnError.Name = "btnError";
            this.btnError.Size = new System.Drawing.Size(83, 35);
            this.btnError.TabIndex = 0;
            this.btnError.Text = "Test Error";
            this.btnError.UseVisualStyleBackColor = true;
            this.btnError.Click += new System.EventHandler(this.btnError_Click);
            // 
            // btnWarn
            // 
            this.btnWarn.Location = new System.Drawing.Point(111, 21);
            this.btnWarn.Name = "btnWarn";
            this.btnWarn.Size = new System.Drawing.Size(83, 35);
            this.btnWarn.TabIndex = 1;
            this.btnWarn.Text = "Test Warning";
            this.btnWarn.UseVisualStyleBackColor = true;
            this.btnWarn.Click += new System.EventHandler(this.btnWarn_Click);
            // 
            // btnAudit
            // 
            this.btnAudit.Location = new System.Drawing.Point(209, 21);
            this.btnAudit.Name = "btnAudit";
            this.btnAudit.Size = new System.Drawing.Size(83, 35);
            this.btnAudit.TabIndex = 2;
            this.btnAudit.Text = "Test Audit";
            this.btnAudit.UseVisualStyleBackColor = true;
            this.btnAudit.Click += new System.EventHandler(this.btnAudit_Click);
            // 
            // btnTrace
            // 
            this.btnTrace.Location = new System.Drawing.Point(308, 21);
            this.btnTrace.Name = "btnTrace";
            this.btnTrace.Size = new System.Drawing.Size(83, 35);
            this.btnTrace.TabIndex = 3;
            this.btnTrace.Text = "Test Trace";
            this.btnTrace.UseVisualStyleBackColor = true;
            this.btnTrace.Click += new System.EventHandler(this.btnTrace_Click);
            // 
            // tmrClock
            // 
            this.tmrClock.Enabled = true;
            this.tmrClock.Interval = 25;
            this.tmrClock.Tick += new System.EventHandler(this.tmrClock_Tick);
            // 
            // lblClock
            // 
            this.lblClock.AutoSize = true;
            this.lblClock.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblClock.Location = new System.Drawing.Point(468, 62);
            this.lblClock.Name = "lblClock";
            this.lblClock.Size = new System.Drawing.Size(18, 20);
            this.lblClock.TabIndex = 4;
            this.lblClock.Text = "0";
            // 
            // lblErrorIC
            // 
            this.lblErrorIC.AutoSize = true;
            this.lblErrorIC.Location = new System.Drawing.Point(12, 108);
            this.lblErrorIC.Name = "lblErrorIC";
            this.lblErrorIC.Size = new System.Drawing.Size(73, 13);
            this.lblErrorIC.TabIndex = 5;
            this.lblErrorIC.Text = "Incident Code";
            // 
            // btnErrorAwait
            // 
            this.btnErrorAwait.Location = new System.Drawing.Point(12, 62);
            this.btnErrorAwait.Name = "btnErrorAwait";
            this.btnErrorAwait.Size = new System.Drawing.Size(83, 35);
            this.btnErrorAwait.TabIndex = 6;
            this.btnErrorAwait.Text = "Await Error";
            this.btnErrorAwait.UseVisualStyleBackColor = true;
            this.btnErrorAwait.Click += new System.EventHandler(this.btnErrorAwait_Click);
            // 
            // btnWarnAwait
            // 
            this.btnWarnAwait.Location = new System.Drawing.Point(111, 62);
            this.btnWarnAwait.Name = "btnWarnAwait";
            this.btnWarnAwait.Size = new System.Drawing.Size(83, 35);
            this.btnWarnAwait.TabIndex = 7;
            this.btnWarnAwait.Text = "Await Warning";
            this.btnWarnAwait.UseVisualStyleBackColor = true;
            this.btnWarnAwait.Click += new System.EventHandler(this.btnWarnAwait_Click);
            // 
            // btnAuditAwait
            // 
            this.btnAuditAwait.Location = new System.Drawing.Point(209, 62);
            this.btnAuditAwait.Name = "btnAuditAwait";
            this.btnAuditAwait.Size = new System.Drawing.Size(83, 35);
            this.btnAuditAwait.TabIndex = 8;
            this.btnAuditAwait.Text = "Await Audit";
            this.btnAuditAwait.UseVisualStyleBackColor = true;
            this.btnAuditAwait.Click += new System.EventHandler(this.btnAuditAwait_Click);
            // 
            // btnTraceAwait
            // 
            this.btnTraceAwait.Location = new System.Drawing.Point(308, 62);
            this.btnTraceAwait.Name = "btnTraceAwait";
            this.btnTraceAwait.Size = new System.Drawing.Size(83, 35);
            this.btnTraceAwait.TabIndex = 9;
            this.btnTraceAwait.Text = "Await Trace";
            this.btnTraceAwait.UseVisualStyleBackColor = true;
            this.btnTraceAwait.Click += new System.EventHandler(this.btnTraceAwait_Click);
            // 
            // lblWarnIC
            // 
            this.lblWarnIC.AutoSize = true;
            this.lblWarnIC.Location = new System.Drawing.Point(108, 108);
            this.lblWarnIC.Name = "lblWarnIC";
            this.lblWarnIC.Size = new System.Drawing.Size(73, 13);
            this.lblWarnIC.TabIndex = 10;
            this.lblWarnIC.Text = "Incident Code";
            // 
            // lblAuditIC
            // 
            this.lblAuditIC.AutoSize = true;
            this.lblAuditIC.Location = new System.Drawing.Point(206, 108);
            this.lblAuditIC.Name = "lblAuditIC";
            this.lblAuditIC.Size = new System.Drawing.Size(73, 13);
            this.lblAuditIC.TabIndex = 11;
            this.lblAuditIC.Text = "Incident Code";
            // 
            // lblTraceIC
            // 
            this.lblTraceIC.AutoSize = true;
            this.lblTraceIC.Location = new System.Drawing.Point(305, 108);
            this.lblTraceIC.Name = "lblTraceIC";
            this.lblTraceIC.Size = new System.Drawing.Size(73, 13);
            this.lblTraceIC.TabIndex = 12;
            this.lblTraceIC.Text = "Incident Code";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(561, 140);
            this.Controls.Add(this.lblTraceIC);
            this.Controls.Add(this.lblAuditIC);
            this.Controls.Add(this.lblWarnIC);
            this.Controls.Add(this.btnTraceAwait);
            this.Controls.Add(this.btnAuditAwait);
            this.Controls.Add(this.btnWarnAwait);
            this.Controls.Add(this.btnErrorAwait);
            this.Controls.Add(this.lblErrorIC);
            this.Controls.Add(this.lblClock);
            this.Controls.Add(this.btnTrace);
            this.Controls.Add(this.btnAudit);
            this.Controls.Add(this.btnWarn);
            this.Controls.Add(this.btnError);
            this.Name = "Form1";
            this.Text = "Just Testing That Log Calls Don\'t Block UI";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnError;
        private System.Windows.Forms.Button btnWarn;
        private System.Windows.Forms.Button btnAudit;
        private System.Windows.Forms.Button btnTrace;
        private System.Windows.Forms.Timer tmrClock;
        private System.Windows.Forms.Label lblClock;
        private System.Windows.Forms.Label lblErrorIC;
        private System.Windows.Forms.Button btnErrorAwait;
        private System.Windows.Forms.Button btnWarnAwait;
        private System.Windows.Forms.Button btnAuditAwait;
        private System.Windows.Forms.Button btnTraceAwait;
        private System.Windows.Forms.Label lblWarnIC;
        private System.Windows.Forms.Label lblAuditIC;
        private System.Windows.Forms.Label lblTraceIC;
    }
}


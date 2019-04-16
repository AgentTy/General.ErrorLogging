using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TestAsyncInFormsApp
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            ErrorReporter.ReportTrace("Loading Test Form App for Error Logger");
        }

        static int clock = 0;
        private void tmrClock_Tick(object sender, EventArgs e)
        {
            lblClock.Text = (clock++).ToString();
        }

        private void btnError_Click(object sender, EventArgs e)
        {
            try
            {
                long intTest = 42424242242423342;
                short test = Convert.ToInt16(intTest);
            }
            catch (Exception ex)
            {
                ErrorReporter.ReportError(ex, "Form Test Error 1", strDetails: "these are more details").ContinueWith((task) =>
                {
                    Console.WriteLine(task.Result.IncidentCode);
                });
                lblErrorIC.Text = "fire and forget";
            }
        }

        private async void btnErrorAwait_Click(object sender, EventArgs e)
        {
            try
            {
                long intTest = 42424242242423342;
                short test = Convert.ToInt16(intTest);
            }
            catch (Exception ex)
            {
                lblErrorIC.Text = "logging...";
                var response = await ErrorReporter.ReportError(ex, "Form Test Error 2", strDetails: "these are more details");
                if (response.Success)
                    lblErrorIC.Text = response.IncidentCode;
                else
                    lblErrorIC.Text = response.Message;
            }
        }

        private void btnWarn_Click(object sender, EventArgs e)
        {
            ErrorReporter.ReportWarningLowSeverity("Random Warning 1").ContinueWith((task) =>
            {
                Console.WriteLine(task.Result.IncidentCode);
            });
            lblWarnIC.Text = "fire and forget";
        }

        private async void btnWarnAwait_Click(object sender, EventArgs e)
        {
            lblWarnIC.Text = "logging...";
            var response = await ErrorReporter.ReportWarningLowSeverity("Random Warning 2", strDetails: "these are more details");
            if (response.Success)
                lblWarnIC.Text = response.IncidentCode;
            else
                lblWarnIC.Text = response.Message;
        }

        private void btnAudit_Click(object sender, EventArgs e)
        {
            ErrorReporter.ReportAudit("Random Audit 1").ContinueWith((task) =>
            {
                Console.WriteLine(task.Result.IncidentCode);
            });
            lblAuditIC.Text = "fire and forget";
        }

        private async void btnAuditAwait_Click(object sender, EventArgs e)
        {
            lblAuditIC.Text = "logging...";
            var response = await ErrorReporter.ReportAuditHighSeverity("Random Audit 2", strDetails: "these are more details");
            if (response.Success)
                lblAuditIC.Text = response.IncidentCode;
            else
                lblAuditIC.Text = response.Message;
        }

        private void btnTrace_Click(object sender, EventArgs e)
        {
            ErrorReporter.ReportTraceNormalSeverity("Random Trace 1").ContinueWith((task) =>
            {
                Console.WriteLine(task.Result.IncidentCode);
            });
            lblTraceIC.Text = "fire and forget";
        }

        private async void btnTraceAwait_Click(object sender, EventArgs e)
        {
            lblTraceIC.Text = "logging...";
            var response = await ErrorReporter.ReportTrace("Random Trace 2", strDetails: "these are more details");
            if (response.Success)
                lblTraceIC.Text = response.IncidentCode;
            else
                lblTraceIC.Text = response.Message;
        }
    }
}

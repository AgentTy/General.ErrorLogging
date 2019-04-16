using System.Web;
using System.Web.Optimization;

namespace General.ErrorLogging.GUI
{
    public class BundleConfig
    {
        // For more information on Bundling, visit http://go.microsoft.com/fwlink/?LinkId=254725
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging").Include( "~/Scripts/General.ErrorLogging.js"));

            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging.GUI").Include(
                        "~/Scripts/General.ErrorLogging.GUI.js" ));
            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging.GUI.ErrorLog").Include(
                        "~/Scripts/General.ErrorLogging.GUI.ErrorLog.js"));
            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging.GUI.Error404").Include(
                        "~/Scripts/General.ErrorLogging.GUI.Error404.js"
                        , "~/Scripts/General.ErrorLogging.GUI.Error404Redirect.AddUpdate.js"));
            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging.GUI.Error404Redirect").Include(
                        "~/Scripts/General.ErrorLogging.GUI.Error404Redirect*"));
            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging.GUI.ViewOccurrence").Include(
                        "~/Scripts/General.ErrorLogging.GUI.ViewOccurrence.js"));
            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging.GUI.FilterManager").Include(
                        "~/Scripts/General.ErrorLogging.GUI.LoggingFilter.js"
                        , "~/Scripts/General.ErrorLogging.GUI.LoggingFilter.AddUpdate.js"));
            bundles.Add(new ScriptBundle("~/bundles/General.ErrorLogging.GUI.FilterEditor").Include(
                        "~/Scripts/General.ErrorLogging.GUI.LoggingFilter.js"
                        , "~/Scripts/General.ErrorLogging.GUI.LoggingFilter.AddUpdate.js"
                        , "~/Scripts/General.ErrorLogging.Gui.LoggingFilter.Draggables.js"
                        , "~/Scripts/General.ErrorLogging.Gui.LoggingFilter.Configure.js"));

            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"
                        , "~/Scripts/jquery.cookie.js"));

           // bundles.Add(new ScriptBundle("~/bundles/jqueryui").Include("~/Scripts/jquery-ui-{version}.js"));
            bundles.Add(new ScriptBundle("~/bundles/jqueryui").Include(
                        "~/Scripts/jquery-ui.js",
                        "~/Scripts/jquery.ui.touch-punch.min.js",
                        "~/Scripts/simplePagination/jquery.simplePagination.js",
                        "~/Scripts/spin.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.unobtrusive*",
                        "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/knockoutjs").Include(
                        "~/Scripts/knockout-{version}.js"
                        , "~/Scripts/knockout.SubscribeToViewModel.js"
                        , "~/Scripts/knockout.mapping-latest.js"));

            bundles.Add(new ScriptBundle("~/bundles/moment").Include(
                        "~/Scripts/moment-with-locales.js"));

            bundles.Add(new ScriptBundle("~/bundles/OboeJS").Include(
                        "~/Scripts/oboe-browser.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new StyleBundle("~/Content/css").Include("~/Content/site.css").Include("~/Content/EventView.css"));

            bundles.Add(new StyleBundle("~/Content/themes/base/css").Include(
                "~/Content/themes/base/jquery-ui.css",
                "~/Scripts/simplePagination/simplePagination.css"));
            /*bundles.Add(new StyleBundle("~/Content/themes/base/css").Include(
                        "~/Content/themes/base/jquery.ui.core.css",
                        "~/Content/themes/base/jquery.ui.resizable.css",
                        "~/Content/themes/base/jquery.ui.selectable.css",
                        "~/Content/themes/base/jquery.ui.accordion.css",
                        "~/Content/themes/base/jquery.ui.autocomplete.css",
                        "~/Content/themes/base/jquery.ui.button.css",
                        "~/Content/themes/base/jquery.ui.dialog.css",
                        "~/Content/themes/base/jquery.ui.slider.css",
                        "~/Content/themes/base/jquery.ui.tabs.css",
                        "~/Content/themes/base/jquery.ui.datepicker.css",
                        "~/Content/themes/base/jquery.ui.progressbar.css",
                        "~/Content/themes/base/jquery.ui.theme.css"));
            */
        }
    }
}
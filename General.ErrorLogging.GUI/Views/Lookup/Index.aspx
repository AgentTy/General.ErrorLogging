<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    View Event Occurrence
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.ViewOccurrence") %>

    <style type="text/css">
        
    </style>

    <script type="text/javascript">
        var vm = {
            Event: new EventOccurrenceModel()
        };

        ShowLoading();
        $().ready(function () {
            ko.applyBindings(vm);

            var strRequestedIC = '<%: ViewBag.IncidentCode %>';
            DoLookup(strRequestedIC);
            UpdateLoadingProgress();
        });

        function DoLookup(strIC)
        {
            if (strIC) {
                ShowLoading();
                GetOccurrenceData(strIC, null, function (data) {
                    UpdateLoadingProgress();
                    if (data.ID) {
                        //Format dates into local time
                        var firstTime = moment(data.FirstTime).local();
                        var lastTime = moment(data.LastTime).local();
                        var timeStamp = moment(data.TimeStamp).local();
                        data.FirstTimeString = firstTime.format('lll');
                        data.LastTimeString = lastTime.format('lll');
                        data.TimeStampString = timeStamp.format('lll');

                        ko.mapping.fromJS(data, null, vm.Event);
                        InitExpandableText($('#vwEvent'));
                        $('#vwEvent').show();
                    }
                    else
                    {
                        $('#vwEvent').hide();
                        $('#txtLookup').focus();
                        alert(data);
                    }
                });
            }
            else {
                $('#vwEvent').hide();
                $('#txtLookup').focus();
            }
        }

        function CycleSeverity()
        {
            if (vm.Event.Severity() == 10)
                vm.Event.Severity(1);
            else if (vm.Event.Severity() == 5)
                vm.Event.Severity(10);
            else if (vm.Event.Severity() == 1)
                vm.Event.Severity(5);
        }
    </script>
</asp:Content>

<asp:Content ID="indexFeatured" ContentPlaceHolderID="FeaturedContent" runat="server">
    <section class="featured">
        <div class="content-wrapper">
            <hgroup class="title">
                <h1 onclick="CycleSeverity();"><span data-bind="text: Event.AppName"></span> Incident #<span data-bind="text: Event.IncidentCode"></span></h1>
                <div id="LookupForm" style="float:right;">
                    <input id="txtIC" type="text" name="IC" placeholder="Incident Code" onkeypress="if(ListenForEnterKey(event)) { DoLookup(txtIC.value); }" />
                    <input type="submit" value="Lookup" onclick="DoLookup(txtIC.value);" />
                </div><div style="clear:both;"></div>
            </hgroup>
        </div>
    </section>
</asp:Content>

<asp:Content ID="indexContent" ContentPlaceHolderID="MainContent" runat="server">
    <%: Html.Partial("_ViewEventOccurrence") %>
</asp:Content>

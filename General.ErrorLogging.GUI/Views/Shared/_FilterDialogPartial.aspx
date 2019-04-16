<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>

<% if (Request.IsAuthenticated) { %>
<div id="dialog-form" title="Add/Update Logging Filter" class="ShowTooltips">
  <p class="validateTips">Fields with * are required.</p>
  <form>
    <section id="filter-normal">
        <fieldset>
            <label for="txtFilterName_Dialog">Name*</label>
            <input type="text" name="txtFilterName_Dialog" id="txtFilterName_Dialog" value="" class="text ui-widget-content ui-corner-all" placeholder="give this filter a useful name">

            <label for="chkFilterEnabled_Dialog">Enabled</label>
            <input type="checkbox" name="chkFilterEnabled_Dialog" id="chkFilterEnabled_Dialog" class="text ui-widget-content ui-corner-all" checked><br />

            <label for="txtFilterStartDate_Dialog">Start Date (optional)</label>
            <input type="text" name="txtFilterStartDate_Dialog" id="txtFilterStartDate_Dialog" value="" class="text ui-widget-content ui-corner-all" placeholder="the filter will become active on this date"><br />

            <label for="txtFilterEndDate_Dialog">End Date (optional)</label>
            <input type="text" name="txtFilterEndDate_Dialog" id="txtFilterEndDate_Dialog" value="" class="text ui-widget-content ui-corner-all" placeholder="the filter will shut down on this date"><br />

            <label for="txtFilterEmail_Dialog">Email (optional)</label>
            <input type="text" name="txtFilterEmail_Dialog" id="txtFilterEmail_Dialog" value="" class="text ui-widget-content ui-corner-all" placeholder="receive notification by email"><br />

            <label for="txtFilterSMS_Dialog">SMS (optional)</label>
            <input type="text" name="txtFilterSMS_Dialog" id="txtFilterSMS_Dialog" value="" class="text ui-widget-content ui-corner-all" placeholder="receive notification by SMS"><br />

            <a onclick="ShowFilterHelp();" style="text-decoration:none;position:absolute;bottom:10px;right:10px;">[learn more]</a>
            <!-- Allow form submission with keyboard without duplicating the dialog button -->
            <br /><input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
        </fieldset>
    </section>
    <section id="filter-help" style="display:none;">
        <p>To setup a new filter, you only need to give it a name and click Create. Start Date/End Date are optional. If you enter an email or phone number you will receive a notification every time an event is recorded through this filter.</p>
    </section>
    <section id="filter-success" style="display:none;">
        <h3>Your filter has been saved, but still needs to be configured. <a id="lnkPostFilterCreateGoToConfig">Click Here</a> to finish the setup.</h3>
    </section>
  </form>
</div>
<% } else { %>
    <h2>You must login!</h2>
<% } %>
<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>

<% if (Request.IsAuthenticated) { %>
<div id="dialog-form" title="Add/Update 404 Redirect" class="ShowTooltips">
  <p class="validateTips">Fields with * are required.</p>
  <form>
    <section id="redirect-normal">
        <fieldset>
            <label for="ddnRedirectType_Dialog">Redirect Type*</label>
            <select id="ddnRedirectType_Dialog" name="ddnRedirectType_Dialog" class="text ui-widget-content ui-corner-all">
                <option value="301">301 Permanent</option>
                <option value="307">307 Temporary</option>
            </select><br /><br />

            <label for="txtRedirectFrom_Dialog">From*</label>
            <input type="text" name="txtRedirectFrom_Dialog" id="txtRedirectFrom_Dialog" value="" class="text ui-widget-content ui-corner-all" placeholder="/MyFolder/MyPage.*">

            <label for="txtRedirectTo_Dialog">To*</label>
            <input type="text" name="txtRedirectTo_Dialog" id="txtRedirectTo_Dialog" value="" class="text ui-widget-content ui-corner-all" placeholder="/NewFolder/NewPage.htm">

            <div id="divClientIDDialog">
                <label for="txtClientID_Dialog">Client ID</label>
                <input type="text" name="txtClientID_Dialog" id="txtClientID_Dialog" value="" class="text ui-widget-content ui-corner-all" style="width:180px;"> (optional)
            </div>

            <a onclick="ShowRedirectHelp();" style="text-decoration:none;position:absolute;bottom:10px;right:10px;">[learn more]</a>
            <!-- Allow form submission with keyboard without duplicating the dialog button -->
            <br /><input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
        </fieldset>
    </section>
    <section id="redirect-help" style="display:none;">
        <p>For redirects within the same site, start with / and leave out the domain.</p>
    </section>
    <section id="redirect-success" style="display:none;">
        <h3>Done!</h3>
        <a id="lnkRedirectTest" class="redirect-test" target="_blank">Click here</a> to test your redirect right now! 
    </section>
  </form>
</div>
<% } else { %>
    <h2>You must login!</h2>
<% } %>
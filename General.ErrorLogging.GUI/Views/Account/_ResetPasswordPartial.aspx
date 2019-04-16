<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage<General.ErrorLogging.GUI.Models.RegisterModel>" %>

<p>
    If you forgot your password, you can reset it using the user registration access code.
</p>

<% using (Html.BeginForm("Forgot", "Account")) { %>
    <%: Html.AntiForgeryToken() %>
    <%: Html.ValidationSummary() %>

    <fieldset>
        <legend>Reset Password Form</legend>
        <ol>
            <li>
                <%: Html.LabelFor(m => m.AccessCode) %>
                <%: Html.TextBoxFor(m => m.AccessCode) %>
            </li>
            <li>
                <%: Html.LabelFor(m => m.UserName) %>
                <%: Html.TextBoxFor(m => m.UserName) %>
            </li>
            <li>
                <%: Html.LabelFor(m => m.Password) %>
                <%: Html.PasswordFor(m => m.Password) %>
            </li>
            <li>
                <%: Html.LabelFor(m => m.ConfirmPassword) %>
                <%: Html.PasswordFor(m => m.ConfirmPassword) %>
            </li>
        </ol>
        <input type="submit" value="Reset password" />
    </fieldset>
<% } %>

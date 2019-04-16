var dialog, form, intObjectToEdit,
  ddnRedirectType_Dialog = $("#ddnRedirectType_Dialog"),
  txtRedirectFrom_Dialog = $("#txtRedirectFrom_Dialog"),
  txtRedirectTo_Dialog = $("#txtRedirectTo_Dialog"),
  txtClientID_Dialog = $("#txtClientID_Dialog"),
  allFields = $([]).add(ddnRedirectType_Dialog).add(txtRedirectFrom_Dialog).add(txtRedirectTo_Dialog).add(txtClientID_Dialog),
  tips = $(".validateTips");

function StartCreateRedirect(intError404ID, strRedirectFrom, strClientID) {
    $("#redirect-normal").show();
    $("#redirect-help").hide();
    $("#redirect-success").hide();

    $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').show();
    $('.Error404RedirectDialog .ui-button:contains(Save)').hide();
    $('.Error404RedirectDialog .ui-button:contains(Back)').hide();

    txtRedirectFrom_Dialog.val(strRedirectFrom);
    txtClientID_Dialog.val(strClientID);

    dialog.dialog("open");
}

function StartEditObject(id) {
    $("#redirect-normal").show();
    $("#redirect-help").hide();
    $("#redirect-success").hide();

    intObjectToEdit = id;
    GetData('/api/' + APPContextURI() + '/Error404Redirect?ID=' + id, [], function (data) {
        ddnRedirectType_Dialog.val(data.RedirectType);
        txtRedirectFrom_Dialog.val(data.From);
        txtRedirectTo_Dialog.val(data.To);
        $('#divClientIDDialog').hide();

        $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').hide();
        $('.Error404RedirectDialog .ui-button:contains(Save)').show();
        $('.Error404RedirectDialog .ui-button:contains(Back)').hide();

        dialog.dialog('open');
    });
}

function ShowRedirectHelp() {
    $("#redirect-normal").hide();
    $("#redirect-help").show();

    $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').attr('TempValue', $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').css('display')).hide();
    $('.Error404RedirectDialog .ui-button:contains(Save)').attr('TempValue', $('.Error404RedirectDialog .ui-button:contains(Save)').css('display')).hide();

    $('.Error404RedirectDialog .ui-button:contains(Back)').show();
}


$(function () {
    function updateTips(t) {
        tips
          .text(t)
          .addClass("ui-state-highlight");
        setTimeout(function () {
            tips.removeClass("ui-state-highlight", 1500);
        }, 500);
    }
    function checkLength(o, n, min, max) {
        if (o.val().length > max || o.val().length < min) {
            o.addClass("ui-state-error");
            updateTips("Length of " + n + " must be between " +
              min + " and " + max + ".");
            return false;
        } else {
            return true;
        }
    }
    function checkRegexp(o, regexp, n) {
        if (!(regexp.test(o.val()))) {
            o.addClass("ui-state-error");
            updateTips(n);
            return false;
        } else {
            return true;
        }
    }
    function ValidObject() {
        var valid = true;
        allFields.removeClass("ui-state-error");
        valid = valid && checkRegexp(ddnRedirectType_Dialog, /^\d{3}$/i, "Redirect type must be a 3 digit HTTP status code");
        valid = valid && checkLength(txtRedirectFrom_Dialog, "From", 1, 300);
        valid = valid && checkLength(txtRedirectTo_Dialog, "To", 1, 300);
        //if (txtClientID_Dialog.val())
        //    valid = valid && checkRegexp(txtClientID_Dialog, /^\d+$/i, "Client ID must be an integer.");
        return valid;
    }
    function AddObject() {
        var valid = ValidObject();
        if (valid) {
            var objParams =
                {
                    AppID: vwModelCurrent.AppID(),
                    RedirectType: ddnRedirectType_Dialog.val(),
                    From: txtRedirectFrom_Dialog.val(),
                    To: txtRedirectTo_Dialog.val(),
                    ClientID: txtClientID_Dialog.val()
                }
            PostData("POST", '/api/' + APPContextURI() + '/Error404Redirect', JSON.stringify(objParams), function (data) {
                if (document.URL.indexOf('Error404Redirect') > -1)
                    DrawRow(data);
                ShowRedirectSuccess(data.AppURL, data.From);
            })
        }
        return valid;
    }
    function UpdateObject() {
        var valid = ValidObject();
        if (valid) {
            var objParams =
                {
                    ID: intObjectToEdit,
                    AppID: vwModelCurrent.AppID(),
                    RedirectType: ddnRedirectType_Dialog.val(),
                    From: txtRedirectFrom_Dialog.val(),
                    To: txtRedirectTo_Dialog.val(),
                    ClientID: txtClientID_Dialog.val()
                }
            PostData("PUT", '/api/' + APPContextURI() + '/Error404Redirect', JSON.stringify(objParams), function (data) {
                ReloadData();
            })
            dialog.dialog("close");
        }
        return valid;
    }

    function HideRedirectHelp() {
        $("#redirect-normal").show();
        $("#redirect-help").hide();
        $("#redirect-success").hide();
        $('.Error404RedirectDialog .ui-button:contains(Back)').hide();

        $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').css('display', $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').attr('TempValue'));
        $('.Error404RedirectDialog .ui-button:contains(Save)').css('display', $('.Error404RedirectDialog .ui-button:contains(Save)').attr('TempValue'));
    }

    function ShowRedirectSuccess(strAppURL, strRedirectFrom) {
        if (strAppURL.length > 0)
        {
            if (strAppURL.charAt(strAppURL.length - 1) != '/' && strRedirectFrom.charAt(0) != '/')
                strAppURL = strAppURL + '/';
            $("#lnkRedirectTest").attr('href', strAppURL + strRedirectFrom);
        }

        $("#redirect-normal").hide();
        $("#redirect-success").show();
        $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').hide();
        $('.Error404RedirectDialog .ui-button:contains(Save)').hide();
    }

    dialog = $("#dialog-form").dialog({
        dialogClass: 'Error404RedirectDialog',
        autoOpen: false,
        height: 450,
        width: 400,
        modal: true,
        close: function () {
            form[0].reset();
            allFields.removeClass("ui-state-error");
        },
        buttons: {
        "Create Redirect": AddObject,
        "Save": UpdateObject,
        "Back": HideRedirectHelp,
        Close: function () {
            dialog.dialog("close");
        }
    },
    });
    form = dialog.find("form").on("submit", function (event) {
        event.preventDefault();
        AddObject();
    });
    $("#create-object").button().on("click", function () {
        form[0].reset();

        $("#redirect-normal").show();
        $("#redirect-help").hide();
        $("#redirect-success").hide();

        $('.Error404RedirectDialog .ui-button:contains(Create Redirect)').show();
        $('.Error404RedirectDialog .ui-button:contains(Save)').hide();
        $('.Error404RedirectDialog .ui-button:contains(Back)').hide();

        $('#divClientIDDialog').show();
        dialog.dialog("open");
    });
});
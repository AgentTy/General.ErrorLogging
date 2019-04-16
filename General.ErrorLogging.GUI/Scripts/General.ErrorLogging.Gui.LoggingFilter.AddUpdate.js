var dialog, form, intObjectToEdit,
  txtFilterName_Dialog = $("#txtFilterName_Dialog"),
  chkFilterEnabled_Dialog = $("#chkFilterEnabled_Dialog"),
  txtFilterStartDate_Dialog = $("#txtFilterStartDate_Dialog"),
  txtFilterEndDate_Dialog = $("#txtFilterEndDate_Dialog"),
  txtFilterEmail_Dialog = $("#txtFilterEmail_Dialog"),
  txtFilterSMS_Dialog = $("#txtFilterSMS_Dialog"),
  allFields = $([]).add(txtFilterName_Dialog).add(chkFilterEnabled_Dialog).add(txtFilterStartDate_Dialog).add(txtFilterEndDate_Dialog).add(txtFilterEmail_Dialog).add(txtFilterSMS_Dialog),
  tips = $(".validateTips");

function StartCreateFilter(intAppID, strAppName, strClientID) {
    $("#filter-normal").show();
    $("#filter-help").hide();
    $("#filter-success").hide();

    $('.LoggingFilterDialog .ui-button:contains(Create Filter)').show();
    $('.LoggingFilterDialog .ui-button:contains(Save)').hide();
    $('.LoggingFilterDialog .ui-button:contains(Back)').hide();

    dialog.dialog("open");
}

function StartEditObject(id) {
    $("#filter-normal").show();
    $("#filter-help").hide();
    $("#filter-success").hide();

    intObjectToEdit = id;
    GetData('/api/' + APPContextURI() + '/LoggingFilter?ID=' + id, [], function (data) {
        txtFilterName_Dialog.val(data.Name);
        chkFilterEnabled_Dialog.prop('checked', data.Enabled);
        txtFilterStartDate_Dialog.val(data.StartDateString);
        txtFilterEndDate_Dialog.val(data.EndDateString);
        if (data.PageEmail)
            txtFilterEmail_Dialog.val(data.PageEmail.Value);
        if (data.PageSMS)
            txtFilterSMS_Dialog.val(data.PageSMS.Value);

        $('.LoggingFilterDialog .ui-button:contains(Create Filter)').hide();
        $('.LoggingFilterDialog .ui-button:contains(Save)').show();
        $('.LoggingFilterDialog .ui-button:contains(Back)').hide();

        dialog.dialog('open');
    });
}

function ShowFilterHelp() {
    $("#filter-normal").hide();
    $("#filter-help").show();

    $('.LoggingFilterDialog .ui-button:contains(Create Filter)').attr('TempValue', $('.LoggingFilterDialog .ui-button:contains(Create Filter)').css('display')).hide();
    $('.LoggingFilterDialog .ui-button:contains(Save)').attr('TempValue', $('.LoggingFilterDialog .ui-button:contains(Save)').css('display')).hide();

    $('.LoggingFilterDialog .ui-button:contains(Back)').show();
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
    function checkEmail(o, n) {
        var regexp = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
        return checkRegexp(o, regexp, n);
    }
    function checkPhone(o, n) {
        var targ = o.val().replace(/[^\d]/g, ''); // remove all non-digits
        if (targ && targ.length >= 10) {
            // targ might be a valid phone number
            return true;
        }
        else
        {
            o.addClass("ui-state-error");
            updateTips(n);
            return false;
        }
    }
    function checkDate(o, n) {
        var regexp = /^[0-3]?[0-9]\/[0-3]?[0-9]\/(?:[0-9]{2})?[0-9]{2}$/;
        return checkRegexp(o, regexp, n);
    }

    function ValidObject() {
        var valid = true;
        allFields.removeClass("ui-state-error");
        if (txtFilterEmail_Dialog.val())
            valid = valid && checkEmail(txtFilterEmail_Dialog, "Enter a valid email address.");
        if (txtFilterSMS_Dialog.val())
            valid = valid && checkPhone(txtFilterSMS_Dialog, "Enter a valid phone number.");
        if (txtFilterStartDate_Dialog.val())
            valid = valid && checkDate(txtFilterStartDate_Dialog, "Enter a valid start date.");
        if (txtFilterEndDate_Dialog.val())
            valid = valid && checkDate(txtFilterEndDate_Dialog, "Enter a valid end date.");
        valid = valid && checkLength(txtFilterName_Dialog, "Name", 1, 200);
        valid = valid && checkLength(txtFilterEmail_Dialog, "Email", 0, 254);
        valid = valid && checkLength(txtFilterSMS_Dialog, "SMS", 0, 50);

        return valid;
    }
    function AddObject() {
        var valid = ValidObject();
        if (valid) {
            var objParams =
                {
                    AppID: vwModelCurrent.AppID(),
                    Name: txtFilterName_Dialog.val(),
                    Enabled: chkFilterEnabled_Dialog.prop('checked'),
                    StartDate: MakeLocalTimeForQueryString(txtFilterStartDate_Dialog.val()),
                    EndDate: MakeLocalTimeForQueryString(txtFilterEndDate_Dialog.val(), true),
                    PageEmail: txtFilterEmail_Dialog.val(),
                    PageSMS: txtFilterSMS_Dialog.val()
                }
            PostData("POST", '/api/' + APPContextURI() + '/LoggingFilter/CreateFilter', JSON.stringify(objParams), function (data) {
                //if (document.URL.indexOf('Filter') > -1)
                //    DrawRow(data);
                ReloadData();
                ShowFilterSuccess(data.ID, data.Name);
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
                    Name: txtFilterName_Dialog.val(),
                    Enabled: chkFilterEnabled_Dialog.prop('checked'),
                    StartDate: MakeLocalTimeForQueryString(txtFilterStartDate_Dialog.val()),
                    EndDate: MakeLocalTimeForQueryString(txtFilterEndDate_Dialog.val(), true),
                    PageEmail: txtFilterEmail_Dialog.val(),
                    PageSMS: txtFilterSMS_Dialog.val()
                }
            PostData("PUT", '/api/' + APPContextURI() + '/LoggingFilter/UpdateFilterMeta', JSON.stringify(objParams), function (data) {
                ReloadData();
            })
            dialog.dialog("close");
        }
        return valid;
    }

    function HideFilterHelp() {
        $("#filter-normal").show();
        $("#filter-help").hide();
        $("#filter-success").hide();
        $('.LoggingFilterDialog .ui-button:contains(Back)').hide();

        $('.LoggingFilterDialog .ui-button:contains(Create Filter)').css('display', $('.LoggingFilterDialog .ui-button:contains(Create Filter)').attr('TempValue'));
        $('.LoggingFilterDialog .ui-button:contains(Save)').css('display', $('.LoggingFilterDialog .ui-button:contains(Save)').attr('TempValue'));
    }

    function ShowFilterSuccess(intFilterID, strFilterName) {
        $("#lnkPostFilterCreateGoToConfig").attr('href', '/Filter/Edit?AppID=' + vwModelCurrent.AppID() + '&FilterID=' + intFilterID);

        $("#filter-normal").hide();
        $("#filter-success").show();
        $('.LoggingFilterDialog .ui-button:contains(Create Filter)').hide();
        $('.LoggingFilterDialog .ui-button:contains(Save)').hide();
    }

    dialog = $("#dialog-form").dialog({
        dialogClass: 'LoggingFilterDialog',
        autoOpen: false,
        height: 550,
        width: 400,
        modal: true,
        close: function () {
            form[0].reset();
            allFields.removeClass("ui-state-error");
        },
        buttons: {
            "Create Filter": AddObject,
            "Save": UpdateObject,
            "Back": HideFilterHelp,
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

        $("#filter-normal").show();
        $("#filter-help").hide();
        $("#filter-success").hide();

        $('.LoggingFilterDialog .ui-button:contains(Create Filter)').show();
        $('.LoggingFilterDialog .ui-button:contains(Save)').hide();
        $('.LoggingFilterDialog .ui-button:contains(Back)').hide();

        $('#divClientIDDialog').show();
        dialog.dialog("open");
    });
});
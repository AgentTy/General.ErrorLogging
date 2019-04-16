function InitDraggables(query) {
    if (query)
        $(query).draggable({ revert: 'invalid', helper: 'clone' });
    else
        $(".DragItem").draggable({ revert: 'invalid', helper: 'clone' });
}

function InitDroppables() {
    $("#zoneFilter").droppable({
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        drop: function (event, ui) {
            if (ui.draggable.hasClass('Environment')) {
                //Add Environment Filter
                PersistFilterTagAdd(ui.draggable.attr('data-value'), 'Environment');
                $(this).find('.Environment.All').hide();
                $(this).find('.DropZone.Environment').append(ui.draggable.attr('style', ''));
            }
            else if (ui.draggable.hasClass('Event')) {
                //Add Event Filter
                PersistFilterTagAdd(ui.draggable.attr('data-value'), 'Event');
                $(this).find('.Event.All').hide();
                $(this).find('.DropZone.Event').append(ui.draggable.attr('style', ''));
            }
            else if (ui.draggable.hasClass('Client')) {
                //Add Client Filter
                PersistFilterTagAdd(ui.draggable.attr('data-value'), 'Client');
                $(this).find('.Client.All').hide();
                $(this).find('.DropZone.Client').append(ui.draggable.attr('style', ''));
            }
            else if (ui.draggable.hasClass('User')) {
                //Add User Filter
                PersistFilterTagAdd(ui.draggable.attr('data-value'), 'User');
                $(this).find('.User.All').hide();
                $(this).find('.DropZone.User').append(ui.draggable.attr('style', ''));
            }
        }
    });

    $("#zoneEnvironments").droppable({
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        accept: '.Environment',
        drop: function (event, ui) {
            //Remove Environment Filter
            PersistFilterTagRemove(ui.draggable.attr('data-value'), 'Environment');
            $(this).find('.DropZone').append(ui.draggable.attr('style', ''));
            if ($('#zoneFilter .DropZone.Environment .DragItem').length <= 1)
                $('#zoneFilter span.Environment.All').show();
        }
    });

    $("#zoneEvents").droppable({
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        accept: '.Event',
        drop: function (event, ui) {
            //Remove Event Filter
            PersistFilterTagRemove(ui.draggable.attr('data-value'), 'Event');
            $(this).find('.DropZone').append(ui.draggable.attr('style', ''));
            if ($('#zoneFilter .DropZone.Event .DragItem').length <= 1)
                $('#zoneFilter span.Event.All').show();
        }
    });
    $("#zoneClients").droppable({
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        accept: '.Client',
        drop: function (event, ui) {
            //Remove Client Filter
            PersistFilterTagRemove(ui.draggable.attr('data-value'), 'Client');
            $(this).find('.DropZone').append(ui.draggable.attr('style', ''));
            if ($('#zoneFilter .DropZone.Client .DragItem').length <= 1)
                $('#zoneFilter span.Client.All').show();
        }
    });
    $("#zoneUsers").droppable({
        activeClass: "ui-state-default",
        hoverClass: "ui-state-hover",
        accept: '.User',
        drop: function (event, ui) {
            //Remove User Filter
            PersistFilterTagRemove(ui.draggable.attr('data-value'), 'User');
            $(this).find('.DropZone').append(ui.draggable.attr('style', ''));
            if ($('#zoneFilter .DropZone.User .DragItem').length <= 1)
                $('#zoneFilter span.User.All').show();
        }
    });
}
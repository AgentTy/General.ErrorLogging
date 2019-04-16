// knockout extension for creating a changed flag (similar to Ryan's dirty flag except it resets itself after every change)
//http://stackoverflow.com/questions/10143682/knockoutjs-subscribe-to-property-changes-with-mapping-plugin
ko.changedFlag = function (root) {
    var result = function () { };
    var initialState = ko.observable(ko.toJSON(root));

    result.isChanged = ko.dependentObservable(function () {
        var changed = initialState() !== ko.toJSON(root);
        if (changed) result.reset();
        return changed;
    });

    result.reset = function () {
        initialState(ko.toJSON(root));
    };

    return result;
};
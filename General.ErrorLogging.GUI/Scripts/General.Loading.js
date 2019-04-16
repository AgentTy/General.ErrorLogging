var intLoadingCount = 0;
var intLoadingCountTotal = 0;
function ShowLoading(points) {
    if (points)
    {
        intLoadingCount += points;
        intLoadingCountTotal += points;
    }
    else
    {
        intLoadingCount++;
        intLoadingCountTotal ++;
    }
    if (!intLoadingCountTotal)
        intLoadingCountTotal = intLoadingCount;
    DrawLoadingStatus(intLoadingCount, intLoadingCountTotal);
    document.getElementById("LoadingCurtain").style.display = "block";
}

function UpdateLoadingProgress(points) {
    if (points)
        intLoadingCount -= points;
    else
        intLoadingCount--;

    DrawLoadingStatus(intLoadingCount, intLoadingCountTotal);
    if (intLoadingCount <= 0) {

        intLoadingCount = 0;
        intLoadingCountTotal = 0;
        document.getElementById("LoadingCurtain").style.display = "none";
    }
}

function HideLoading() {
    intLoadingCount = 0;
    intLoadingCountTotal = 0;
    document.getElementById("LoadingCurtain").style.display = "none";
}

function DrawLoadingStatus(intCurrentQueue, intTotal) {
    if (intLoadingCountTotal > 1) {
        var numPercentage = ((intTotal - intCurrentQueue) / intTotal) * 100;
        //console.log(intLoadingCount + "," + intLoadingCountTotal + "," + numPercentage);
        document.getElementById("LoadingText").innerHTML = Math.round(numPercentage) + '%';
    }
    else
        document.getElementById("LoadingText").innerHTML = '';
}

if(typeof Array.prototype.findIndex == 'undefined'){
    Array.prototype.findIndex = function (predicate, thisValue) {
        var arr = Object(this);
        if (typeof predicate !== 'function') {
            throw new TypeError();
        }
        for(var i=0; i < arr.length; i++) {
            if (i in arr) {  // skip holes
                var elem = arr[i];
                if (predicate.call(thisValue, elem, i, arr)) {
                    return i;  // (1)
                }
            }
        }
        return -1;  // (2)
    }
}
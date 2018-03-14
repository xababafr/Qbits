/*
 * Deutsch-Jozsa Algorithm
 * Given a function over n bits that returns 0 or 1, and is guaranteed to be either constant or balanced
 * the Deutsch-Jozsa algorithm determines whether it is constant or balanced after only one invocation of the function.
 * Returns true if the function is constant.
 */

function deutschJozsa(f) {
    var inputBits = {from: 1, to: 3};
    var result = jsqubits('|0001>')
            .hadamard(ALL)
            .applyFunction(inputBits, 0, f)
            .hadamard(inputBits)
            .measure(inputBits)
            .result;
    return result === 0;
};

function shuffle(a) {
    for (var i = 0; i < a.length; i++) {
        var j = Math.floor(Math.random() * a.length);
        var x = a[i];
        a[i] = a[j];
        a[j] = x;
    }
};

var nums = [0,1,2,3,4,5,6,7];
shuffle(nums);
function createBalancedFunction() {
    // Return 0 for exactly half the possible inputs and 1 for the rest.
    return function(x) { return nums[x] < 4 ? 0 : 1 };
};

var start = new Date().getTime();
for(var i = 0; i < 5000; i++) {
    //deutschJozsa( createBalancedFunction() );
    deutschJozsa( function(x){return 0;} );
}
var end = new Date().getTime();
var time = end - start;

log("time : "+time);

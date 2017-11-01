math = require 'mathjs'

class QuObject
    constructor: () ->

    # (array a#, array a2) -> (float |<a1/a2>|^2)
    prodSc: (a1,a2) ->
        math.norm( math.dot(a1,a2) )^2

    # "00010010" -> [0,0,0,1,0,0,1,0]
    getArr: (str) ->
        ret = []
        for i in [0...str.length]
            ret.push( parseInt(str[i]) )
        ret

    # [0,0,0,1,0,0,1,0] -> "00010010"
    # this function seems useless, since [0,0,0,1,0,0,1,0] != "00010010"
    getStr: (arr) ->
        ret = ""
        for i in [0...arr.length]
            ret +=  "" + arr[i] + ""
        ret

    toBin: (int, dim) ->
        bin = int.toString(2)
        for i in [0...(dim - bin.length)]
            bin = "0" + bin
        bin

    strReplace: (str, index, replacement) ->
        str.substr(0, index) + replacement + str.substr(index + replacement.length)

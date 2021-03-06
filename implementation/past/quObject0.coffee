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
    getStr: (arr) ->
        ret = ""
        for i in [0...arr.length]
            ret +=  "" + arr[i] + ""
        ret

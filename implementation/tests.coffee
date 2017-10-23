math = require 'mathjs'

# [A,B]
# [C,D] (tous des arrays, donc des valueOf() d'une math.matrix toutes de meme dim et carrées )
# dim = A.sizeOf()[0]
constructHadamardMatrix = (m) ->
    dim = Math.pow(2,m)
    mat =[]
    for k in [0...dim]
        current = []
        for n in [0...dim]

            [kb2,nb2] = [k.toString(2), n.toString(2)]
            [J, sum] = [ math.max(kb2.length,nb2.length), 0]

            kb2 = if (kb2.length < J) then ( "0".repeat((J-kb2.length)) ) + kb2 else kb2
            nb2 = if (nb2.length < J) then ( "0".repeat((J-nb2.length)) ) + nb2 else nb2

            for j in [0...J]
                sum += parseInt(kb2[j])*parseInt(nb2[j])

            value = ( 1/Math.pow(2,(m/2)) ) * Math.pow( (-1), sum )
            current.push value
        mat.push current
    math.matrix(mat)

constructHadamardMatrix(2)

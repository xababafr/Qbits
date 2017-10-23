# MAIN #

Q = new QuObject

strReplace = (str, index, replacement) ->
    str.substr(0, index) + replacement + str.substr(index + replacement.length)


swap = (quSt, x, y) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )
    #console.log newCoeffs

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim).split('')
        [ bin[x], bin[y] ] = [ bin[y], bin[x] ]
        bin = bin.join('')
        #console.log "new bin : " + bin
        newCoeffs[parseInt(bin,2)] = quSt.coeffs[i]

    new QuState quSt.dim, newCoeffs


hadamard = (quSt, x) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim)
        if (bin[x] == "0") # H(|0>) = ( 1/sqrt(2) )*( |0> + |1> )
            [c1,c2] = [bin, (strReplace bin, x, "1" )]
            newCoeffs[parseInt(c1,2)] += (quSt.coeffs[i]/Math.sqrt(2))
            newCoeffs[parseInt(c2,2)] += (quSt.coeffs[i]/Math.sqrt(2))
        else # H(|1>) = ( 1/sqrt(2) )*( |0> - |1> )
            [c1,c2] = [(strReplace bin, x, "0" ), bin]
            newCoeffs[parseInt(c1,2)] += (quSt.coeffs[i]/Math.sqrt(2))
            newCoeffs[parseInt(c2,2)] -= (quSt.coeffs[i]/Math.sqrt(2))

    new QuState quSt.dim, newCoeffs


hadamardAll = (quSt) ->
    ret = quSt
    for i in [0...quSt.dim]
        ret = hadamard(ret, i)
    ret


notGate = (quSt, x) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim)
        if (bin[x] == "0") # NOT(|0>) = |1>
            bin = strReplace(bin, x, "1")
        else # NOT(|1>) = |0>
            bin = strReplace(bin, x, "0")
        newCoeffs[parseInt(bin,2)] += quSt.coeffs[i]

    new QuState quSt.dim, newCoeffs


# x = control qubit, y = changed qubit
CnotGate = (quSt, x,y) ->
    newCoeffs = ( 0 for [1..(Math.pow(2,quSt.dim))] )

    for i in [0...(Math.pow(2,quSt.dim))]
        bin = (Q.toBin i, quSt.dim)
        if (bin[x] == "1")
            if (bin[y] == "0") # NOT(|0>) = |1>
                bin = strReplace(bin, y, "1")
            else # NOT(|1>) = |0>
                bin = strReplace(bin, y, "0")
        newCoeffs[parseInt(bin,2)] += quSt.coeffs[i]

    new QuState quSt.dim, newCoeffs


#st = new QuState(3, [math.complex(0,4),0,0,4,0,0,0,0])
#console.log "before measure : " + st.getState()
#console.log "after  measure : " + st.measure().getState()


st2 = new QuState(3, [0,1,0,0,0,0,0,0])
console.log "SWAP(0,2) : " + st2.getState() + " ---> " + (swap st2, 0, 2).getState()

st3 = new QuState(3, [1,0,0,0,0,0,0,1])
console.log "HADAMARD(0) : " + st3.getState() + " ---> " + (hadamard st3, 0).getState()
console.log "HADAMARD ALL : " + st3.getState() + " ---> " + (hadamardAll st3).getState()

st4 = new QuState(3, [0,0,0,0,0,0,0,1])
console.log "NOT(0) : " + st4.getState() + " ---> " + (notGate st4, 0).getState()

st5 = new QuState(3, [0,0,0,0,1,0,0,0])
console.log "CNOT(0,2) : " + st5.getState() + " ---> " + (CnotGate st5, 0, 2).getState()

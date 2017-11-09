###

pour la classe QuRegister, chaque porte retourne this ( = @) pour pouvoir chainer les appels. Malgré cette possibilité, j'ai décidé que chaque appel à un porte modifierait l'objet en lui meme . Ainsi, on peux faire myreg.unePorteQuantique() puis observer myReg : il aura subit les modifications de la porte concernée.

Concernant la manière de coder les portes, pour le moment, je n'ai pas utilisé les matrices, car ça m'a aidé à mieux comprendre de faire ça "à la main". Dans l'avenir, je repasserai peut etre par la représentation matricielle. Je me demande cela dit s'il n'y a pas un léger gachis de calculs en utilisant les matrices.

###

# testing measure()
reg0 = new QuRegister [math.complex(0,4),0,0,4,0,0,0,0]
console.log "before measure : " + reg0.getState()
reg0.measure()
console.log "after  measure : " + reg0.getState()

# testing hadamard
reg1 = new QuRegister [1,0,0,0,0,0,1,0]
console.log "HADAMARD(0) : " + reg1.getState() + " ---> " + reg1.hadamard(0).getState()

# testing hadamard on all qubits
reg2 = new QuRegister [1,0,0,0,0,0,1,0]
console.log "HADAMARD ALL : " + reg2.getState() + " ---> " + reg2.hadamardAll().getState()

# testing swap on qubits 0 and 2
reg3 = new QuRegister "|001>" # = [0,1,0,0,0,0,0,0]
console.log "SWAP(0,2) : " + reg3.getState() + " ---> " + reg3.swap(0,2).getState()

# testing not on qubit 0
reg4 = new QuRegister "|001>"
console.log "NOT(0) : " + reg4.getState() + " ---> " + reg4.not(0).getState()

# testing cnot on qubit 2 with controlled qubit 0
reg5 = new QuRegister [0,0,0,0,1,0,0,0]
console.log "CNOT(0,2) : " + reg5.getState() + " ---> " + reg5.cnot(0,2).getState()

# testing phase on qubit 1
reg6 = new QuRegister "/010>"
console.log "PHASE(1,e^(i*PI/4)) : " + reg6.getState() + " ---> " + reg6.phase(1,(math.PI)/4).getState()

# testing phase on qubit 1 with controlled qubit 0
reg7 = new QuRegister "/110>"
console.log "CPHASE(0,1,e^(-i*PI/4)) : " + reg7.getState() + " ---> " + reg7.cphase(0,1,-(math.PI)/4).getState()

console.log "\n\n ------------------------------------------------------------------- \n\n"

reg8 = new QuRegister "/010>"
reg8.p('Init')
    .hadamard(1).p('Hadamard(1)')
    .swap(0,1)  .p( 'Swap(0,1)' )
    .cnot(0,2)  .p( 'Cnot(0,2)' )
    .not(0)     .p(   'Not(0)'  )
    .measure()  .p(' Measure()' )

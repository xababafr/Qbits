require "complex"

class QuObject
    #def initialize() end

    def toBin(num : Int32, dim : Int32)
        bin = num.to_s 2
        (dim-bin.size).times do |i|
            bin = "0" + bin
        end
        bin
    end

    def newCoeffs(dim : Int32)
        newCoeffs = [] of Complex
        (2**dim).times do |i|
            newCoeffs.push Complex.new 0, 0
        end
        newCoeffs
    end

    def norm(vect : Array)
        norm = 0
        vect.each do |el|
            norm += (el*el.conj).abs
        end
        Math.sqrt norm
    end

     #we have String.insert(index : Int, other : Char)
     # "dada".insert(2,"i")

     #3.times do |n|
     # puts n
     #end
end

#a = if 2 > 1
#      3
#    else
#      4
#    end


class QuState < QuObject

    def initialize(dim : Int32, coeffs = [] of Complex, measured = false)
        @dim = dim
        if coeffs.size == 0
            @coeffs = genCoeffs @dim
        else
            @coeffs = coeffs
        end
				val = (1/norm(@coeffs))
        #@coeffs = (1/norm(@coeffs))*@coeffs #normalization
				(2**dim).times do |i| #normalization
  					@coeffs[i] *= val
				end
    end

    def genCoeffs(dim)
        ret = [] of Complex
        (2**dim).times do |i|
            ret.push Complex.new(Random.rand(1),Random.rand(1))
        end
        ret
    end

    def getProbas()
        probas = [] of Float64
        (2**@dim).times do |i|
            probas.push @coeffs[i].abs2()
        end
        probas
    end

		def getDim()
				@dim
		end

		def getCoeffs()
				@coeffs
		end

    def measure()
        probas, choice, sum, result = getProbas(), Random.rand(1.0), 0, [] of Complex
        (2**@dim).times do |i|
            prevSum, sum = sum, sum + probas[i]
            if (choice >= prevSum && choice <= sum)
                result.push Complex.new 1, 0
            else
                result.push Complex.new 0, 0
            end
        end
        QuState.new @dim, result, true
        #@coeffs = result
    end

	def getState()
        ret = ""
        (2**@dim).times do |i|
            if (@coeffs[i].abs != 0)
                ret += "(" + @coeffs[i].to_s + ")*|" + (toBin i,@dim) + "> + "
			end
        end
        ret[0..-4]
    end

    def isMeasured()
        @measured
    end

end


class QuRegister < QuObject
    # give "|001>", "/001>", or [0,1,0,0,0,0,0,0], which represents the same state
    def initialize(st : String)
        bin = st[1..-2]
        dim = bin.size
        arr = [] of Complex
        (2**dim).times do |i|
            arr.push Complex.new 0, 0
        end
        arr[(bin.to_i 2)] = Complex.new 1, 0
        puts arr
        @quState = QuState.new dim, arr
    end

    def initialize(st : Array(Complex))
        dim = Math.log2(st.size).to_i()
        arr = st
        @quState = QuState.new dim, arr
    end

    def getState()
        @quState.getState()
    end

    def p(st)
        puts "[" + st + "] " + getState()
        self
    end

    def measure()
        @quState = @quState.measure()
        self
    end

    def hadamard(x)
        dim = @quState.getDim
        newCoeffs = newCoeffs(dim)

        (2**dim).times do |i|
            bin = toBin i, dim
            if bin[x] == '0' # H(|0>) = ( 1/sqrt(2) )*( |0> + |1> )
                c1,c2 = bin, bin.sub(x, "1")
      			newCoeffs[c1.to_i 2] += @quState.getCoeffs[i] / Math.sqrt(2)
                newCoeffs[c2.to_i 2] += @quState.getCoeffs[i] / Math.sqrt(2)
            else # H(|1>) = ( 1/sqrt(2) )*( |0> - |1> )
                c1,c2 = bin.sub(x, "0"), bin
                newCoeffs[c1.to_i 2] += @quState.getCoeffs[i] / Math.sqrt(2)
                newCoeffs[c2.to_i 2] -= @quState.getCoeffs[i] / Math.sqrt(2)
            end
        end

        @quState = QuState.new dim, newCoeffs
        self
    end

    def hadamardAll()
        (@quState.getDim).times do |i|
            hadamard i
        end
        self
    end

    def swap(x, y)
        dim = @quState.getDim
        newCoeffs = newCoeffs(dim)

        (2**dim).times do |i|
            bin = (toBin i, dim).chars
            bin[x], bin[y] = bin[y], bin[x]
            newCoeffs[bin.join.to_i 2] = @quState.getCoeffs[i]
        end

        @quState = QuState.new dim, newCoeffs
        self
    end

    def not(x)
        dim = @quState.getDim
        newCoeffs = newCoeffs(dim)

        (2**dim).times do |i|
            bin = (toBin i, dim)
            if bin[x] == '0' # NOT(|0>) = |1>
                bin = bin.sub(x, "1")
            else # NOT(|1>) = |0>
                bin = bin.sub(x, "0")
            end
            newCoeffs[bin.to_i 2] += @quState.getCoeffs[i]
        end

        @quState = QuState.new dim, newCoeffs
        self
    end

    def cnot(x,y)
        dim = @quState.getDim
        newCoeffs = newCoeffs(dim)

        (2**dim).times do |i|
            bin = (toBin i, dim)
            if bin[x] == '1' # Control bit
                if bin[y] == '0' # NOT(|0>) = |1>
                    bin = bin.sub(y, "1")
                else # NOT(|1>) = |0>
                    bin = bin.sub(y, "0")
                end
            end
            newCoeffs[bin.to_i 2] += @quState.getCoeffs[i]
        end

        @quState = QuState.new dim, newCoeffs
        self
    end

    def phase(x, phi)
        dim = @quState.getDim
        newCoeffs = newCoeffs(dim)

        (2**dim).times do |i|
            bin = (toBin i, dim)
            if bin[x] == '1'
                newCoeffs[bin.to_i 2] = (@quState.getCoeffs[i]) * (Complex.new 1, phi)
            else
                newCoeffs[bin.to_i 2] = (@quState.getCoeffs[i])
            end
        end

        @quState = QuState.new dim, newCoeffs
        self
    end

    def cphase(x, y, phi)
        dim = @quState.getDim
        newCoeffs = newCoeffs(dim)

        (2**dim).times do |i|
            bin = (toBin i, dim)
            if bin[x] == '1' && bin[y] == '1'
                newCoeffs[bin.to_i 2] = (@quState.getCoeffs[i]) * (Complex.new 1, phi)
            else
                newCoeffs[bin.to_i 2] = (@quState.getCoeffs[i])
            end
        end

        @quState = QuState.new dim, newCoeffs
        self
    end
end

# CMD + /

#pour l'instant ça galère, je devrais peut etre forcer le typage en full nombre complexe, et forcer le constructeur par coeffs seulement, qutte à ecrire des convertisseurs? Dans cette version , je fais ça

def c(re, im = 0)
    Complex.new(re,im)
end

def ca(arr) # array of int or floats (not complex for now)
    (arr.size).times do |i|
        # a faire
    end
end

# testing measure()
reg0 = QuRegister.new [c(0,4),c(0),c(0),c(4,0),c(0),c(0),c(0),c(0)]
puts "before measure : " + reg0.getState
reg0.measure()
puts "after  measure : " + reg0.getState

# testing hadamard
reg1 = QuRegister.new [c(1),c(0),c(0),c(0),c(0),c(0),c(1),c(0)]
puts "HADAMARD(0) : " + reg1.getState + " ---> " + reg1.hadamard(0).getState

# testing hadamard on all qubits
reg2 = QuRegister.new [c(1),c(0),c(0),c(0),c(0),c(0),c(1),c(0)]
puts "HADAMARD ALL : " + reg2.getState + " ---> " + reg2.hadamardAll.getState

# testing swap on qubits 0 and 2
reg3 = QuRegister.new "|001>" # = [c(0),c(1),c(0),c(0),c(0),c(0),c(0),c(0)]
puts "SWAP(0,2) : " + reg3.getState + " ---> " + reg3.swap(0,2).getState

# testing not on qubit 0
reg4 = QuRegister.new "|001>"
puts "NOT(0) : " + reg4.getState + " ---> " + reg4.not(0).getState

# testing cnot on qubit 2 with controlled qubit 0
reg5 = QuRegister.new [c(0),c(0),c(0),c(0),c(1),c(0),c(0),c(0)]
puts "CNOT(0,2) : " + reg5.getState + " ---> " + reg5.cnot(0,2).getState

# testing phase on qubit 1
reg6 = QuRegister.new "/010>"
puts "PHASE(1,e^(i*PI/4)) : " + reg6.getState + " ---> " + reg6.phase(1,(Math::PI)/4).getState

# testing phase on qubit 1 with controlled qubit 0
reg7 = QuRegister.new "/110>"
puts "CPHASE(0,1,e^(-i*PI/4)) : " + reg7.getState + " ---> " + reg7.cphase(0,1,-(Math::PI)/4).getState

puts "\n\n ------------------------------------------------------------------- \n\n"

reg8 = QuRegister.new "/010>"
reg8.p("Init")
    .hadamard(1).p("Hadamard(1)")
    .swap(0,1)  .p( "Swap(0,1)" )
    .cnot(0,2)  .p( "Cnot(0,2)" )
    .not(0)     .p(   "Not(0)"  )
    .measure()  .p( "Measure() ")

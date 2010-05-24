


const Complex <- class Complex[realV : Integer, imagV : Integer]
	
	attached var real : Integer
	attached var imag : Integer
	
	var myFramework : Framework
	
	attached var isPrimaryCopy : boolean <- false
	
	initially
		real <- realV
		imag <- imagV
	end initially
	
	export operation setReal[n : Integer]
		real <- n
		myFramework.notify[self]
	end setReal
	
	export operation setImag[n : Integer]
		imag <-n
		myFramework.notify[self]
	end setImag
	
	export operation getReal[] -> [n : Integer]
		n <- real
	end getReal
	
	export operation getImag[] -> [n : Integer]
		n <- imag
	end getImag
	
	export function cloneMe[] -> [clone : Replicable]
		
		var complexclone : Complex <- Complex.create[self.getReal[], self.getImag[]]
		clone <- view complexclone as Replicable
		return
	end cloneMe

	export operation primaryCopyUpdated[primaryCopy : Replicable]
		self.wo["Primary copy updated"]
		const cplx <- view primaryCopy as Complex
		imag <- cplx.getImag[]
		real <- cplx.getReal[]
		self.writeStatus[]
	end primaryCopyUpdated
	
	export operation replicaUpdated[replica : Replicable]
		self.wo["Replica updated. Updating primary copy."]
		const repl <- view replica as Complex
		imag <- repl.getImag[]
		real <- repl.getReal[]
		myFramework.notify[self]
		self.writeStatus[]
	end replicaUpdated
	
	export operation addObserver[o : Framework]
		myFramework <- o
	end addObserver
	
	export function !=[o: Replicable] -> [r : boolean]
		r <- (nil = (view o as Complex))
	end !=
	
	export operation setIsPrimaryCopy[]
		isPrimaryCopy <- true
	end setIsPrimaryCopy
	
	export function isPrimaryCopy[] -> [r : boolean]
		r <- isPrimaryCopy
	end isPrimaryCopy
	
	export operation writeStatus[]
		if isPrimaryCopy = true then
			self.wo["Primary Copy. Real: " || real.asString || ". Imag: " || imag.asString || "."]
		else
			self.wo["Replica.  Real: " || real.asString || ". Imag: " || imag.asString || "."]
		end if
	end writeStatus
	
	operation wo[o : String]
		(locate 1)$stdout.putString[o || "\n"]
	end wo
end Complex 



const main <- object main
		var pc:Complex
		const all <- (locate self)$activeNodes
	
	
	initially
		var myFramework : Framework <- Framework.create
		self.wo["Creating complex"]
		pc <- Complex.create[2, 3]
	
		
		myFramework.replicateMe[pc, 2]
		
		(locate self).Delay[Time.create[5, 0]]
		
		pc.setReal[1]
		
		const replicas <- myFramework.getCopyOfReplicaList[]
		(locate self).Delay[Time.create[5, 0]]
		var repl : Complex <- (view (replicas.getValues)[0] as Complex)
		repl.setReal[5]
		
		
	end initially
	
	process
		
	end process
	
	operation wo[o : String]
		(locate 1)$stdout.putString[o || "\n"]
	end wo

end main
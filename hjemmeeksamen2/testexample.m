


const Complex <- class Complex[realV : Integer, imagV : Integer]
	
	attached var real : Integer
	attached var imag : Integer
	
	var myFramework : Framework.of[Complex]
	
	attached var isPrimaryCopy : boolean <- false
	
	initially
		real <- realV
		imag <- imagV
	end initially
	
	export operation setReal[n : Integer]
		myFramework.notify[self]
		real <- n
	end setReal
	
	export operation setImag[n : Integer]
		myFramework.notify[self]
		imag <-n
	end setImag
	
	export operation getReal[] -> [n : Integer]
		n <- imag
	end getReal
	
	export operation getImag[] -> [n : Integer]
		n <- imag
	end getImag
	
	export function cloneMe[] -> [clone : Complex]
		
		var complexclone : Complex <- Complex.create[self.getReal[], self.getImag[]]
		clone <- complexclone
		return
	end cloneMe

	export operation primaryCopyUpdated[primaryCopy : Complex]
		self.wo["Primary copy updated"]
	end primaryCopyUpdated
	
	export operation replicaUpdated[replica : Complex]
		self.wo["Replica updated"]
	end replicaUpdated
	
	export operation addObserver[o : Framework.of[Complex]]
		myFramework <- o
	end addObserver
	
	export function !=[o: Complex] -> [r : boolean]
		r <- (nil = o)
	end !=
	
	export operation setIsPrimaryCopy[]
		isPrimaryCopy <- true
	end setIsPrimaryCopy
	
	export function isPrimaryCopy[] -> [r : boolean]
		r <- isPrimaryCopy
	end isPrimaryCopy
	
	export operation writeStatus[]
		if isPrimaryCopy = true then
			self.wo["Complex. Primary Copy"]
		else
			self.wo["Complex. Replica."]
			
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
		var myFramework : Framework.of[Complex] <- Framework.of[Complex].create
		pc <- Complex.create[2, 1]
		
		%move pc to all[3]$theNode
		
		
		
		myFramework.replicateMe[pc, 2]
		(locate self).Delay[Time.create[5, 0]]
		
		
	
		
		pc.setReal[1]
	end initially
	
	process
		
	end process

end main
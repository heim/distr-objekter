export t

const t <- object t
	export operation assertIntegerNotEqual[val1 : Integer, val2 : Integer]
			assert val1 != val2
			self.wo["."]			
			failure 
				self.wo["Test failed " || val1.asString || " and " || val2.asString || " is equal.\n"]
				assert false
			end failure
	end assertIntegerNotEqual

	export operation assertStringEquals[val1 : String, val2 : String]
			assert val1 = val2
			self.wo["."]			
			failure 
				self.wo["Test failed " || val1.asString || " and " || val2.asString || " not equal.\n"]
				assert false
			end failure
	end assertStringEquals
	
	export operation assertIntegerEquals[val1 : Integer, val2 : Integer]
			assert val1 = val2
			self.wo["."]			
			failure 
				self.wo["Test failed " || val1.asString || " and " || val2.asString || " not equal.\n"]
				assert false
			end failure
	end assertIntegerEquals
	
	export operation assertTrue[val : Boolean]
		assert val
		self.wo["."]			
		failure 
			self.wo["Expected true, got false.\n"]
			assert false
		end failure
	end assertTrue
	
	export operation assertFalse[val : Boolean]
		assert !val
		self.wo["."]			
		failure 
			self.wo["Expected false, got true.\n"]
			assert false
		end failure
	end assertFalse
	
	export operation assertContains[input : Array.of[ServerFile], value : ServerFile, occurences : Integer]
			var result : Integer <- 0
			
			for i: Integer <- 0 while i < (input.upperbound + 1) by i <- i + 1
				if value = input[i] then
					result <- result + 1
				end if
			end for
			
			assert result == occurences
			self.wo["."]			
			failure 
				self.wo["Test failed. Array contained " || result.asString || " occurences of " || value.gethash.asString || ". Expected " || occurences.asString || ".\n"]
				assert false
			end failure
	end assertContains
	
	export operation assertStringArrayContains[input : Array.of[String], value : String, occurences : Integer]
			var result : Integer <- 0
			
			for i: Integer <- 0 while i < (input.upperbound + 1) by i <- i + 1
				if value = input[i] then
					result <- result + 1
				end if
			end for
			
			assert result = occurences
			self.wo["."]			
			failure 
				self.wo["Test failed. Array contained " || result.asString || " occurences of " || value || ". Expected " || occurences.asString || ".\n"]
				assert false
			end failure
	end assertStringArrayContains
	
	export operation assertEmptyFileArray[input : Array.of[ServerFile]]
		assert input.empty
		self.wo["."]			
		failure 
			self.wo["Test failed. Input not empty.\n"]
			assert false
		end failure
	end assertEmptyFileArray

	export operation wo[input : String]
		(locate 1)$stdout.putString[input]
		(locate 1)$stdout.flush
	end wo
end t


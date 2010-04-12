const Hasher <- object Hasher
	export operation hash[input : String] -> [hash : Integer]
		var a : Integer <- 63689
		const b <- 378551
		hash <- 0
		
		for i: Integer <- 0 while i < input.length by i <- i + 1
			hash <- (hash * a) + input.getElement[i].ord
			a <- a * b
		end for
	end hash
end Hasher

export Hasher


const testSuite <- object testSuite 
	
	operation testUnequalStringsHasDifferentHashValue
		t.assertIntegerNotEqual[Hasher.hash["The quick brown fox"], Hasher.hash["The quick brown fox."]]
	end testUnequalStringsHasDifferentHashValue
	
	operation testEqualStringsHasEqualValue
		t.assertIntegerEquals[Hasher.hash["Equal String"], Hasher.hash["Equal String"]]
	end testEqualStringsHasEqualValue
	
	process
		self.testUnequalStringsHasDifferentHashValue
		self.testEqualStringsHasEqualValue
	end process

end testSuite



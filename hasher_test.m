
const hasherTestSuite <- object testSuite 
	
	
	
	operation testUnequalStringsHasDifferentHashValue
		const hash_obj <- Hasher.create
		t.assertIntegerNotEqual[hash_obj.hash["The quick brown fox"], hash_obj.hash["The quick brown fox."]]
	end testUnequalStringsHasDifferentHashValue
	
	operation testEqualStringsHasEqualValue
		const hash_obj <- Hasher.create
		t.assertIntegerEquals[hash_obj.hash["Equal String"], hash_obj.hash["Equal String"]]
	end testEqualStringsHasEqualValue
	
	initially
		self.testUnequalStringsHasDifferentHashValue
		self.testEqualStringsHasEqualValue
	end initially

end testSuite



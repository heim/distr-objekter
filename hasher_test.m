
const hasherTestSuite <- object testSuite 
	
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



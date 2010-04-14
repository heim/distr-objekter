


const fileTestSuite <- object testSuite

	operation testCanInitialize
		const testFile <- self.makeFile
	end testCanInitialize

	operation testCanAccessContents
		const testFile <- self.makeFile
		t.assertStringEquals["Contents", testFile.getcontents]
	end testCanAccessContents
	
	operation testContentsHashesCorrectly
		const correctHash <- Hasher.create.hash["Contents"]
		const testFile <- self.makeFile
		t.assertIntegerEquals[correctHash, testFile.getHash]
	end testContentsHashesCorrectly
	
	operation makeFile -> [f : File]
		f <- File.create["test.txt", "Contents"]
	end makeFile
	
	initially
		self.testCanInitialize
		self.testCanAccessContents
		self.testContentsHashesCorrectly
	end initially

end testSuite
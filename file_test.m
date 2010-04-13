


const fileTestSuite <- object testSuite

	operation testCanInitialize
		const testFile <- File.create["My contents"]
	end testCanInitialize

	operation testCanAccessContents
		const testFile <- File.create["Contents"]
		%t.assertStringEquals["Contents", testFile.getcontents]
	end testCanAccessContents
	
	operation testContentsHashesCorrectly
		const correctHash <- Hasher.create.hash["Contents"]
		const testFile <- File.create["Contents"]
		t.assertIntegerEquals[correctHash, testFile.getHash]
	end testContentsHashesCorrectly
	
	initially
		self.testCanInitialize
		self.testCanAccessContents
		self.testContentsHashesCorrectly
	end initially

end testSuite
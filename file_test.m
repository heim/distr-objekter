const File <- class File[fileContents : String]
	attached field hash : Integer
	attached field contents : String <- fileContents
	initially
		%hash <- Hasher.hash[contents]
	end initially
end File

export File


const fileTestSuite <- object testSuite

	operation testCanInitialize
		const testFile <- File.create["My contents"]
	end testCanInitialize

	operation testCanAccessContents
		const testFile <- File.create["Contents"]
		%t.assertStringEquals["Contents", testFile.getcontents]
	end testCanAccessContents
	
	operation testContentsHashesCorrectly
		%const correctHash <- Hasher.hash["Contents"]
		const testFile <- File.create["Contents"]
		%t.assertIntegerEquals[correctHash, testFile.getHash]
	end testContentsHashesCorrectly
	
	initially
		self.testCanInitialize
		self.testCanAccessContents
		self.testContentsHashesCorrectly
	end initially

end testSuite
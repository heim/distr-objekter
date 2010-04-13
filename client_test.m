
const testSuite <- object testSuite
	
	operation testClientCanRegisterFileLocally
		const testFile <- File.create["The quick brown fox."]
		const client <- NoPesterClient.create
		client.registerFile[testFile]
		t.assertContains[client.fileList, testFile, 1]		
	end testClientCanRegisterFileLocally
	
	operation testEmptyClientHasNoFiles
		const client <- NoPesterClient.create
		t.assertEmptyFileArray[client.fileList]
	end testEmptyClientHasNoFiles

	initially
		
		self.testEmptyClientHasNoFiles
		
		%self.testClientCanRegisterFileLocally
		
	end initially


end testSuite
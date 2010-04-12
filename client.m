const NoPesterClient <- class NoPesterClient
	
	var fileList : Map.of[Integer, File]
	
	export operation fileList -> [list : Array.of[File]]
		list <- Array.of[File].empty
	end fileList
	
	export operation registerFile[inputFile : File]
	
	end registerFile
	
	

end NoPesterClient



const testSuite <- object testSuite
	
	operation testClientCanRegisterFileLocally
		%const testFile <- File["The quick brown fox."]
		%const client <- NoPesterClient.create
		%client.registerFile[testFile]
		%t.assertContains[client.fileList, testFile, 1]		
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
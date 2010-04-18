
const testSuite <- object testSuite
	const all <- (locate self)$activeNodes
	const serverNode <- all[1]$thenode
	
	operation testClientCanRegisterFileLocally
		const testFile <- self.makeFile
		const server <- self.makeServer
		const client <- self.makeClient[server]
		client.registerFile[testFile]
		const testServerFile <- ServerFile.create[testFile.getHash, testFile.getName]
		t.assertContains[client.fileList, testServerFile, 1]		
	end testClientCanRegisterFileLocally
	
	operation testEmptyClientHasNoFiles
		const server <- self.makeServer
		const client <- self.makeClient[server]
		t.assertEmptyFileArray[client.fileList]
	end testEmptyClientHasNoFiles

	operation testClientCanRegisterFileAtServer
		const server <- self.makeServer
		const client <- self.makeClient[server]
		const testfile <- self.makeFile
		client.registerFile[testFile]
	end testClientCanRegisterFileAtServer
	
	
	
	operation testClientCanRetrieveRegisteredFileFromServer
		const server <- self.makeServer
		const client <- self.makeClient[server]
		const testFile <- self.makeFile
		client.registerFile[testFile]
		const testServerFile <- ServerFile.create[testFile.getHash, testFile.getName]
		t.assertContains[server.fileList, testServerFile, 1]
	end testClientCanRetrieveRegisteredFileFromServer

	operation testClientCanRetrievePeerList
		const server <- self.makeServer
		const client <- self.makeClient[server]
		const testFile <- self.makeFile
		client.registerFile[testFile]
		const testServerFile <- ServerFile.create[testFile.getHash, testFile.getName]
		
		const actualClient <- server.getFileProviders[testServerFile][0]
		
		assert ((locate actualClient) == (locate self))
		
	end testClientCanRetrievePeerList



	operation testClientCanRetrieveFileFromPeer
		const server <- self.makeServer
		const client <- self.makeClient[server]
		const testFile <- self.makeFile
		const sFile <- ServerFile.create[testFile.getHash, testFile.getName]
		client.registerFile[testFile]
		
	 	assert client.retrieveFile[sFile, client]
	
	end testClientCanRetrieveFileFromPeer
	operation makeFile -> [f : File]
		f <- File.create["brownfox.txt", "The quick brown fox."]
	end makeFile
	
	operation makeClient[s : NoPesterServer] -> [c : NoPesterClient]
		c <- NoPesterClient.create[s]
	end makeClient
	
	operation makeServer -> [s : NoPesterServer]
		s <- NoPesterServer.create
		move s to serverNode
	end makeServer
	

	process
		assert (all.upperbound > 0)
		self.testEmptyClientHasNoFiles
		
		self.testClientCanRegisterFileLocally
		self.testClientCanRegisterFileAtServer
		self.testClientCanRetrieveRegisteredFileFromServer
		self.testClientCanRetrievePeerList
		self.testClientCanRetrieveFileFromPeer
		
	end process


end testSuite
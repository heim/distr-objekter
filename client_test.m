
const testSuite <- object testSuite
	const all <- (locate self)$activeNodes
	const serverNode <- all[1]$thenode
	
	operation testClientCanRegisterFileLocally
		const testFile <- self.makeFile
		const server <- self.makeServer
		const client <- self.makeClient[server]
		client.registerFile[testFile]
		t.assertContains[client.fileList, testFile, 1]		
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
		t.assertContains[server.fileList, testFile, 1]
		
	end testClientCanRegisterFileAtServer

	operation makeFile -> [f : File]
		f <- File.create["The quick brown fox."]
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
		
	end process


end testSuite
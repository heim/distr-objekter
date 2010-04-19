const IntegrationTest <- object IntegrationTest
	const here <- (locate self)
	const all <- here.getActiveNodes
	const server <- NoPesterServer.create

	initially
		self.ensureAtLeastSixNodes
	end initially
	
	
	process
		
		const peers <- self.createAndMoveClientArray
		const files <- self.createFileArray
		
		peers[0].registerFile[files[0]]
		peers[0].registerFile[files[1]]
		peers[1].registerFile[files[2]]
		peers[1].registerFile[files[3]]
		
		peers[2].registerFile[files[4]]
		peers[2].registerFile[files[5]]
		
		peers[3].registerFile[files[6]]
		peers[3].registerFile[files[7]]

		peers[4].registerFile[files[8]]
		peers[4].registerFile[files[9]]

		peers[0].retrieveFile[self.makeServerFile[files[6]], peers[3]]
		peers[1].retrieveFile[self.makeServerFile[files[4]], peers[2]]
		peers[3].retrieveFile[self.makeServerFile[files[9]], peers[4]]

		
		peers[3].retrieveFile[self.makeServerFile[files[2]], peers[1]]
		peers[3].retrieveFile[self.makeServerFile[files[4]], peers[2]]
		peers[3].retrieveFile[self.makeServerFile[files[8]], peers[4]]

		peers[4].unregisterFile[files[9]]
		

		server.printState
		
	end process

	operation wo[o : String]
		(locate 1)$stdout.putString[o || "\n"]
	end wo

	operation makeServerFile[f : File] -> [s : ServerFile]
		
		s <- ServerFile.create[f.getHash, f.getName]
		
	end makeServerFile

	operation createFileArray -> [a : Array.of[File]]
		%create nine files
		a <- Array.of[File].empty
		for i: Integer <- 1 while i < 11 by i <- i + 1
			var f : File <- File.create[("file " || i.asString ||""), ("contents" || i.asString)]
			a.addUpper[f]
		end for
	end createFileArray
	
	operation createAndMoveClientArray -> [a : Array.of[NoPesterClient]]
		a <- Array.of[NoPesterClient].empty
		for i: Integer <- 1 while i < all.upperbound+1 by i <- i + 1
			var client : NopesterClient <- NoPesterClient.create[server]
			const there <- all[i]$theNode
			move client to there
			there$stdout.putString["Here be node number #" || i.asString || " with LNN " || there.getLNN.asString ||"\n"]
			a.addUpper[client]
		end for
		
	end createAndMoveClientArray

	operation ensureAtLeastSixNodes  
		assert all.upperbound > 4
	end ensureAtLeastSixNodes

end IntegrationTest
const IntegrationTest <- object IntegrationTest
	const here <- (locate self)
	const all <- here.getActiveNodes
	const server <- NoPesterServer.create

	initially
		self.ensureAtLeastFiveNodes
	end initially
	
	
	process
		
		const clients <- self.createAndMoveClientArray
		const files <- self.createFileArray
		
		clients[0].registerFile[files[0]]
		clients[0].registerFile[files[1]]
		clients[0].registerFile[files[2]]
		clients[0].registerFile[files[3]]
		
		clients[0].unRegisterFile[files[0]]
		
		clients[0].printState
		
		
		
	end process


	operation createFileArray -> [a : Array.of[File]]
		%create nine files
		a <- Array.of[File].empty
		for i: Integer <- 0 while i < 9 by i <- i + 1
			var f : File <- File.create[("file " || i.asString ||""), ("contents" || i.asString)]
			a.addUpper[f]
		end for
	end createFileArray
	
	operation createAndMoveClientArray -> [a : Array.of[NoPesterClient]]
		a <- Array.of[NoPesterClient].empty
		for i: Integer <- 0 while i < all.upperbound+1 by i <- i + 1
			var client : NopesterClient <- NoPesterClient.create[server]
			move client to all[i]$theNode
			a.addUpper[client]
		end for
		
	end createAndMoveClientArray

	operation ensureAtLeastFiveNodes  
		assert all.upperbound > 3
	end ensureAtLeastFiveNodes

end IntegrationTest
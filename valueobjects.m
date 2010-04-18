const Hasher <- class Hasher

	export operation hash[input : String] -> [hash : Integer]
		var a : Integer <- 63689
		const b <- 378551
		hash <- 0
		
		for i: Integer <- 0 while i < input.length by i <- i + 1
			hash <- (hash * a) + input.getElement[i].ord
			a <- a * b
		end for
	end hash
	
end Hasher


const File <- immutable class File[fileName : String, fileContents : String]
	attached field hash : Integer
	attached field contents : String <- fileContents
	attached field name : String <- fileName

	initially
		const hash_obj <- Hasher.create
		hash <- hash_obj.hash[contents]
	end initially
	
	export function copy -> [f : File]
		f <- File.create[name, contents]
	end copy
	
	export function =[other : File] -> [r : Boolean]
		r <- (other.getHash = self.getHash) & (other.getName = self.getName) & (other.getContents = self.getContents)
	end =
	
	export function <[other : File] -> [r : Boolean]
		r <- (self.getHash < other.getHash) & (self.getName < other.getName)
	end <
	
	export function hash -> [i : Integer]
		i <- self.getHash
	end hash
end File


const NoPesterClient <- class NoPesterClient[s : NoPesterServer]
	
	var fileList : Map.of[ServerFile, File] <- Map.of[ServerFile, File].create
	const server <- s
	initially
	
	end initially
	
	export operation fileList -> [list : Array.of[ServerFile]]
		list <- fileList.getKeys
	end fileList
	
	export operation registerFile[inputFile : File]
		self.registerFileLocally[inputFile]
		self.registerRemotely[inputFile]
	end registerFile
	
	export operation unRegisterFile[inputFile : File]
		(locate 1)$stdout.putString["Deleting file " || inputFile.getName || " from client\n"]
		const sf <- ServerFile.create[inputfile.getHash, inputfile.getName]
		fileList.delete[sf]
		server.unRegisterFile[sf, self]
	end unRegisterFile	
	
	operation registerRemotely[inputFile : File]
		server.registerFile[ServerFile.create[inputFile.getHash, inputFile.getName], self]
	end registerRemotely
	
	operation registerFileLocally[inputFile : File]
		fileList.insert[ServerFile.create[inputFile.getHash, inputFile.getName], inputFile]
	end registerFileLocally
	
	export operation retrieveFile[sFile : ServerFile, fromClient : NoPesterClient]
		self.wo["retrieving " || sFile.getName ||" from client " || fromclient.nodeLNN.asString ]
		const file <- fromClient.transferFile[sFile, self]
		if file !== nil then
			self.registerFile[file]
		end if 

		unavailable
			(locate 1)$stdout.putString["Node unavailable. Cannot download file: " || sFile.getName || ". Try another node.\n "]
		end unavailable
	end retrieveFile
	
	export operation transferFile[sFile : ServerFile, transferTo : NoPesterClient] -> [f : File]
		self.wo["Transferring " || sFile.getName || " to " || transferTo.nodeLNN.asString]
		f <- (fileList.lookup[sFile]).copy
		move f to (locate transferTo)
	end transferFile
	
	export function =[other : ServerFile] -> [b : Boolean]
		b <- ((locate other) == (locate self))
	end =
	
	export function getTheNode -> [n : Node]
		n <- (locate self)
	end getTheNode	
	
	export function nodeLNN -> [i : Integer]
		i <- (locate self).getLNN
	end nodeLNN
	
	
	export operation printState
		
		self.wo[""]
		self.wo[""]
		self.wo["State for client " || self.nodeLNN.asString]
		const files <- fileList.getKeys
		self.wo[files.upperBound.asString]
		for i: Integer <- 0 while i < (files.upperbound + 1) by i <- i + 1
			
			self.wo["Filename: " || files[i].getName]
			
		end for
		
	
	end printState
	
	operation wo[o : String]
		(locate 1)$stdout.putString[o || "\n"]
	end wo
	
end NoPesterClient

const ServerFile <- immutable class ServerFile[fileHash : Integer, fileName : String]
	attached field hash : Integer <- fileHash
	attached field name : String <- fileName
	
	export function = [other : ServerFile] -> [r : Boolean]
		r <- (other.getHash == self.getHash) & (other.getName == self.getName)
	end =
	
	export function <[other : ServerFile] -> [r : Boolean]
		r <- (self.getHash < other.getHash) & (self.getName < other.getName)
	end <
	
	export function hash -> [i : Integer]
		i <- self.getHash
	end hash
	
end ServerFile

export ServerFile


const NoPesterServer <- class NoPesterServer
	
	var fileMap : Map.of[ServerFile, Map.of[Integer, NoPesterClient]]
	var clientList : Map.of[Integer, Node] <- Map.of[Integer, Node].create
	
	initially
		fileMap <- Map.of[ServerFile, Map.of[Integer, NoPesterClient]].create
	end initially

	export operation fileList -> [list : Array.of[ServerFile]]
		(locate 1)$stdout.putString["Returning file list\n"]
		list <- fileMap.getKeys
	end fileList
	
	export operation getFileProviders[file : ServerFile] -> [providerList : Array.of[NoPesterClient]]
		(locate 1)$stdout.putString["Returning fileproviders for " || file.getname || " \n"]
		if fileMap.contains[file] then
			providerList <- fileMap.lookup[file].getValues
		else
			providerList <- Array.of[NoPesterClient].empty
		end if
	end getFileProviders
	
	export operation registerFile[file : ServerFile, c : NoPesterClient]
		(locate 1)$stdout.putString["Registering file " || file.getName || " from client located at node no." || (locate c).getLNN.asString || "\n"]
		var clientMap : Map.of[Integer, NoPesterClient]
		clientMap <- fileMap.lookup[file]
		if clientMap !== nil then
			(locate 1)$stdout.putString["File does exist on server\n"]
			clientMap.insert[c.nodeLNN, c]
			fileMap.insert[file, clientMap]
 		else 
			(locate 1)$stdout.putString["File does not exist on server\n"]
			clientMap <- Map.of[Integer, NoPesterClient].create
			clientMap.insert[c.nodeLNN, c]
			fileMap.insert[file, clientMap]
		end if
		self.addClientToClientList[c]
	end registerFile
	
	operation addClientToClientList[c : NoPesterClient]
		clientList.insert[c.nodeLNN, c.getTheNode]
	end addClientToClientList
	
	operation removeClientFromFileList[lnn : Integer]
		clientList.delete[lnn]
		
		const files <- fileMap.getKeys
		const fileCount <- (files.upperbound +1)
		%const clients <- fileMap.getValues
		var deleteFiles : Array.of[ServerFile] <- Array.of[ServerFile].empty
		
		for i: Integer <- 0 while i < fileCount by i <- i + 1		
			

			var file : ServerFile <- files[i]

			var clientMap : Map.of[Integer, NoPesterClient] <- fileMap.lookup[file]
			
			clientMap.delete[lnn]

			if clientMap.size == 0 then

				deleteFiles.addUpper[file]
			else

				fileMap.insert[file, clientMap]
			end if
			
		end for
		
		for i: Integer <- 0 while i < (deleteFiles.upperbound + 1) by i <- i + 1		
			fileMap.delete[(deleteFiles[i])]
		end for
	end removeClientFromFileList
	
	export operation unRegisterFile[file : ServerFile, c : NoPesterClient]
		(locate 1)$stdout.putString["Removing file " || file.getName || " hosted at node " || c.nodeLNN.asString || " from server.\n" ]
		var clientMap : Map.of[Integer, NoPesterClient]
		clientMap <- fileMap.lookup[file]
		if clientMap == nil then
			return
		end if
		
		clientMap.delete[c.nodeLNN]
		if clientMap.size == 0 then
			fileMap.delete[file]
		else
			fileMap.insert[file, clientMap]
		end if
	end unRegisterFile
	
	
	export operation printState
		
		self.wo["State for server"]
		self.wo[fileMap.size.asString || " files in database."]
		
		const files <- fileMap.getKeys
		
		for i: Integer <- 0 while i < fileMap.size by i <- i + 1
			const file <- files[i]
			self.wo["Filename: " || file.getName]
			self.wo["\tClients:"]
			const clientMap <- fileMap.lookup[file]
			const clients <- clientMap.getValues
			for j: Integer <- 0 while j < (clients.upperbound + 1) by j <- j + 1
  		  self.wo["\tClient number" || clients[j].nodeLNN.asString]
			end for
			self.wo[""]
		end for
		
		
		unavailable
		
			self.wo["One of the nodes was unavailable. Waiting one second and trying again."]
			(locate self).Delay[Time.create[1, 0]]
			self.printState
		
		end unavailable
	
	end printState

	operation wo[o : String]
		(locate 1)$stdout.putString[o || "\n"]
	end wo
	
	
	process
		self.monitorActiveNodes
	end process
	
	operation monitorActiveNodes
		loop
			var  lnns : Array.of[Integer]
			var  nodes : Array.of[Node]
			nodes <- clientList.getValues
			lnns <- clientList.getKeys
			(locate self).Delay[Time.create[1, 0]]
			self.checkActiveNodes[nodes, lnns]
		end loop	
	end monitorActiveNodes
	
	operation checkActiveNodes[nodes : Array.of[Node], lnns : Array.of[Integer]]
			var n : Integer
			for i: Integer <- 0 while i < (nodes.upperbound + 1) by i <- i + 1
				n <- i
				const tmp <- nodes[i].getLNN
			end for
			unavailable
				self.wo["Node with LNN " || lnns[n].asString || " no longer active. Removing from server."]
				self.removeClientFromFileList[lnns[n]]
			end unavailable
	end checkActiveNodes

end NoPesterServer

export NoPesterServer
export NoPesterClient
export Hasher
export File

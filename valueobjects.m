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
	
	
	export function =[other : ServerFile] -> [b : Boolean]
		b <- ((locate other) == (locate self))
	end =
	
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
	
	initially
		fileMap <- Map.of[ServerFile, Map.of[Integer, NoPesterClient]].create
	end initially

	export operation fileList -> [list : Array.of[ServerFile]]
		(locate 1)$stdout.putString["Returning file list\n"]
		list <- fileMap.getKeys
	end fileList
	
	export operation getFileProviders[file : ServerFile] -> [clientList : Array.of[NoPesterClient]]
		(locate 1)$stdout.putString["Returning fileproviders for " || file.getname || " \n"]
		if fileMap.contains[file] then
			clientList <- fileMap.lookup[file].getValues
		else
			clientList <- Array.of[NoPesterClient].empty
		end if
	end getFileProviders
	
	export operation registerFile[file : ServerFile, c : NoPesterClient]
		(locate 1)$stdout.putString["Registering file " || file.getName || " from client located at node #" || (locate c).getLNN.asString || "\n"]
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
	end registerFile
	
	export operation unRegisterFile[file : ServerFile, c : NoPesterClient]
		(locate 1)$stdout.putString["Removing file " || file.getName || " hosted at node " || c.nodeLNN.asString || " from server.\n" ]
		var clientMap : Map.of[Integer, NoPesterClient]
		clientMap <- fileMap.lookup[file]
		if clientMap == nil then
			return
		end if
		
		clientMap.delete[c.nodeLNN]
		
	
	end unRegisterFile
	
	
	process
		%kontinuerlig kjøring av getActiveNodes og tømming av datastruktur.
	end process
end NoPesterServer

export NoPesterServer
export NoPesterClient
export Hasher
export File

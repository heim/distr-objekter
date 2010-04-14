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
	
	operation registerRemotely[inputFile : File]
		server.registerFile[ServerFile.create[inputFile.getHash, inputFile.getName], self]
	end registerRemotely
	
	operation registerFileLocally[inputFile : File]
		fileList.insert[ServerFile.create[inputFile.getHash, inputFile.getName], inputFile]
	end registerFileLocally
	
	
	export function =[other : ServerFile] -> [b : Boolean]
		b <- ((locate other) == (locate self))
	end =

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
	
	var fileMap : Map.of[ServerFile, Array.of[NoPesterClient]]
	
	initially
	
		fileMap <- Map.of[ServerFile, Array.of[NoPesterClient]].create
	end initially

	export operation fileList -> [list : Array.of[ServerFile]]
		list <- fileMap.getKeys
	end fileList
	
	export operation getFileProviders[file : ServerFile] -> [clientList : Array.of[NoPesterClient]]
		if fileMap.contains[file] then
			clientList <- fileMap.lookup[file]
		else
			clientList <- Array.of[NoPesterClient].empty
		end if
	end getFileProviders
	
	export operation registerFile[file : ServerFile, c : NoPesterClient]
		var clientArray : Array.of[NoPesterClient]
		clientArray <- fileMap.lookup[file]
		if clientArray !== nil then
			clientArray.addUpper[c]
			fileMap.insert[file, clientArray]
 		else 
			clientArray <- Array.of[NoPesterClient].empty
			clientArray.addUpper[c]
			fileMap.insert[file, clientArray]
		end if
	end registerFile
end NoPesterServer

export NoPesterServer









export NoPesterClient
export Hasher
export File

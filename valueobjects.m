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


const File <- class File[fileContents : String]
	attached field hash : Integer
	attached field contents : String <- fileContents
	initially
		const hash_obj <- Hasher.create
		hash <- hash_obj.hash[contents]
	end initially
end File


const NoPesterClient <- class NoPesterClient[s : NoPesterServer]
	
	var fileList : Map.of[Integer, File] <- Map.of[Integer, File].create
	const server <- s
	initially
	
	end initially
	
	export operation fileList -> [list : Array.of[File]]
		list <- fileList.getValues
	end fileList
	
	export operation registerFile[inputFile : File]
		self.registerFileLocally[inputFile]
		self.registerRemotely[inputFile]
	end registerFile
	
	operation registerRemotely[inputFile : File]
		server.registerFile[inputFile.getHash, self]
	end registerRemotely
	
	operation registerFileLocally[inputFile : File]
		fileList.insert[inputFile.getHash, inputFile]
	end registerFileLocally

end NoPesterClient


const NoPesterServer <- class NoPesterServer
	export operation fileList -> [list : Array.of[File]]
		
	end fileList
	
	export operation registerFile[hash : Integer, c : NoPesterClient]
		%if filelist contains hash, add c to array
		%else make new array of nopesterclient and add with hash as key.
	end registerFile
end NoPesterServer

export NoPesterServer









export NoPesterClient
export Hasher
export File

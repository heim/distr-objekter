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


const NoPesterClient <- class NoPesterClient
	
	var fileList : Map.of[Integer, File]
	
	function fileList[] -> [list : Array.of[File]]
		list <- Array.of[File].empty
	end fileList
	
	export operation registerFile[inputFile : String]
		(locate 1)$stdout.putString[inputFile]
	end registerFile

end NoPesterClient









export NoPesterClient
export Hasher
export File

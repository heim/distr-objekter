export Map
const Map <- immutable object Map
  export function of [ktype : type, vtype : type] -> [r : MapCreatorType]
    suchthat ktype *> immutable typeobject key
			function = [key] -> [boolean]
			function < [key] -> [boolean]
			function hash -> [integer]
    end key
    forall
      vtype
    where 
      MapType <- typeobject MapType
				function getValues -> [retVals : Array.of[vtype]]
				function size -> [val : Integer]
				operation insert [key : ktype, value : vtype]
				operation delete [key : ktype]
				function  lookup [key : ktype] -> [value : vtype]
				function  contains [key : ktype] -> [result : Boolean]
    end MapType
    
		where
      MapCreatorType <- immutable typeobject MapCreatorType
				operation create -> [MapType]
				function getSignature -> [Signature]
    end MapCreatorType

   	r <- monitor class aMapCreator
     	attached const aok <- Array.of[ktype]
     	attached const aov <- Array.of[vtype]

     	attached const keys <- aok.empty
     	attached const values <- aov.empty

		attached const c : Condition <- Condition.create
		var locked : Boolean <- false
		
		var size : Integer <- 0
		
     	export operation insert [key : ktype, value : vtype]
				if locked then
					wait c
				end if
				locked <- true
				
				const limit <- keys.upperbound
				for i : Integer <- 0 while i <= limit by i <- i + 1
  				if keys[i] = key then
    				values[i] <- value
					locked <- false
					signal c
    				return
  				end if
				end for
				keys.addUpper[key]
				values.addUpper[value]
				size <- size + 1
				locked <- false
				signal c
     	end insert
		
		export function size -> [val : Integer]
			if locked then
				wait c
			end if
			locked <- true
			val <- size
			locked <- false
			signal c
		end size
			
 			export operation delete [key : ktype]
				if locked then
					wait c
				end if
				locked <- true
				const limit <- keys.upperbound
				var found : Boolean <- false
				for i : Integer <- 0 while i <= limit by i <- i + 1
  				if keys[i] = key then
					
					assert !found
    				found <- true
  				elseif found then
    				keys[i-1] <- keys[i]
    				values[i-1] <- values[i]
  				end if
				end for
				if found then
					%to make self.size return correct value
					const k1 <- keys.removeUpper
					const k2 <- values.removeUpper
				end if
				
				size <- size - 1
				locked <- false
				signal c
     	end delete

			export function getValues -> [retVals : Array.of[vtype]]
				if locked then
					wait c
				end if
				locked <- true
				retVals <- values
				locked <- false
				signal c
			end getValues
			
			export function getKeys -> [retVals : Array.of[ktype]]
				if locked then
					wait c
				end if
				locked <- true
				retVals <- keys
				locked <- false
				signal c
			end getKeys
			
			export function contains [key : ktype] -> [b : Boolean]
					if locked then
						wait c
					end if
					locked <- true
					const limit <- keys.upperbound
					for i : Integer <- 0 while i <= limit by i <- i + 1
	  				if keys[i] = key then
	    				b <- true
						locked <- false
						signal c
	    				return
	  				end if
					end for
					b <- false
					locked <- false
					signal c
					
			end contains
     
			export function lookup [key : ktype] -> [value : vtype]

				if locked then
					wait c
				end if
				locked <- true
				const limit <- keys.upperbound
				for i : Integer <- 0 while i <= limit by i <- i + 1
  				if keys[i] = key then
    				value <- values[i]
					locked <- false
					signal c
    				return
  				end if
				end for
				locked <- false
				signal c
     		end lookup
			
			operation wo[o : String]
				
				(locate 1)$stdout.putString[o || "\n"]
				
			end wo
   	end aMapCreator
  end of
end Map
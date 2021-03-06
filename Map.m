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
    end MapType
    
		where
      MapCreatorType <- immutable typeobject MapCreatorType
				operation create -> [MapType]
				function getSignature -> [Signature]
    end MapCreatorType

   	r <- class aMapCreator
     	const aok <- Array.of[ktype]
     	const aov <- Array.of[vtype]

     	const keys <- aok.empty
     	const values <- aov.empty

     	export operation insert [key : ktype, value : vtype]
				const limit <- keys.upperbound
				for i : Integer <- 0 while i <= limit by i <- i + 1
  				if keys[i] = key then
    				values[i] <- value
    				return
  				end if
				end for
				keys.addUpper[key]
				values.addUpper[value]
     	end insert

			export function size -> [val : Integer]
				val <- (keys.upperbound + 1)
			end size
			
 			export operation delete [key : ktype]
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
     	end delete

			export function getValues -> [retVals : Array.of[vtype]]
				retVals <- values
			end getValues
			
			export function getKeys -> [retVals : Array.of[ktype]]
				retVals <- keys
			end getKeys
			
			export function contains [key : ktype] -> [b : Boolean]
				b <- (self.lookup[key] !== nil)
			end contains
     
			export function lookup [key : ktype] -> [value : vtype]
				const limit <- keys.upperbound
				for i : Integer <- 0 while i <= limit by i <- i + 1
  				if keys[i] = key then
    				value <- values[i]
    				return
  				end if
				end for
     	end lookup
   	end aMapCreator
  end of
end Map
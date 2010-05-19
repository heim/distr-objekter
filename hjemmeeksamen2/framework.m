export Framework
const Framework <- immutable object Framework
	  export function of [rtype : type] -> [r : FrameworkCreatorType]
	    suchthat rtype *> typeobject Replicable
			function cloneMe[] -> [clone : rtype]
			operation primaryCopyUpdated[primaryCopy : rtype]
			operation replicaUpdated[replica : rtype]
			operation addObserver[o : Framework.of[rtype]]
			function !=[o: rtype] -> [boolean]
			function isPrimaryCopy[] -> [boolean]
			operation setIsPrimaryCopy[]
			operation writeStatus[]
		end Replicable
	    where 
	      FrameworkType <- typeobject FrameworkType
			operation notify[obj : rtype]
			operation getPrimaryCopy[] -> [rtype]
			operation replicateMe[primaryCopy : rtype, n : Integer]
			operation getReplicas[] -> [Array.of[rtype]]
	    end FrameworkType

		where
	      FrameworkCreatorType <- immutable typeobject FrameworkCreatorType
					operation create -> [FrameworkType]
					function getSignature -> [Signature]
	    end FrameworkCreatorType


		r <- class aFrameworkCreator
	
			const here <- (locate self)
			var all : NodeList <- here.getActiveNodes

			var primaryCopy : rtype
			var primaryCopyLNN : Integer
	
			var replicationReady : boolean <- false
	
	
			var replicas : Map.of[Integer, rtype]
			var maintainCopies : Integer
			var inactiveList : Array.of[Integer] <- Array.of[Integer].empty
	
			initially
				replicas <- Map.of[Integer, rtype].create
				self.wo["Available nodes " || (all.upperbound + 1).asString ]
			end initially

			export operation getPrimaryCopy[] -> [r : rtype]
				r <- primaryCopy
			end getPrimaryCopy
			
			export operation getReplicas[] -> [r : Array.of[rtype]]
				r <- replicas.getValues[]			
			end getReplicas

		 	export operation replicateMe[pc : rtype, count : Integer]
	
		
				primaryCopy <- pc
		
				primaryCopy.addObserver[self]
				primaryCopy.setIsPrimaryCopy[]
				primaryCopyLNN <- (locate primaryCopy).getLNN
		
				%//if count is more thant available nodes, then we can not maintain more replicas than we have available nodes
				if (all.upperbound + 1) < count then
					maintainCopies <- (all.upperbound + 1)
				else
					maintainCopies <- count
				end if
		
				pc.writeStatus[]
				self.wo["Producing " || maintainCopies.asString || " copies."]
				
				self.makeNewReplicas[count]
				
				self.wo["Replica map size : " || replicas.size.asString]
				replicationReady <- true
			end replicateMe
			
			
			%makes new replicas on available nodes
			operation makeNewReplicas[amount : Integer]
				self.wo["Making " || amount.asString || " new replicas."]
				var newReplicas : Integer <- 0
			
				for i : Integer <- 0 while i < all.upperbound + 1 by i <- i +1
					all <- here.getActiveNodes
					
					var rNode : Node <- all[i].getTheNode
					
					if newReplicas < amount & rNode.getLNN != primaryCopyLNN  then
						self.wo["newReplicas < amount & rNode.getLNN != primaryCopyLNN"]
						if replicas.contains[rNode.getLNN] = false then
							self.wo["replicas.contains[rNode.getLNN] = false"]
							self.wo["found node without a replica or primary copy"]
							var replica : rtype <- primaryCopy.cloneMe
							replica.addObserver[self]
							move replica to rNode
							replicas.insert[rNode.getLNN, replica]
							newReplicas <- newReplicas + 1
							replica.writeStatus[]
						end if
					end if
				end for
			end makeNewReplicas
			

			export operation notify[obj : rtype]
				if obj == primaryCopy then
					self.notifyReplicasThatPrimaryCopyHasChanged[]
				else
					primaryCopy.replicaUpdated[obj]
				end if
			end notify
	
			operation notifyReplicasThatPrimaryCopyHasChanged[] 
				var values : Array.of[rtype] <- replicas.getValues
		
				for i : Integer <- 0 while i < maintainCopies by i <- i + 1
					values[i].primaryCopyUpdated[primaryCopy]
				end for
				
				unavailable
					self.wo["Replica unavailable, so could not be notified."]
				end unavailable
			end notifyReplicasThatPrimaryCopyHasChanged
		
			
			%Promoting a replica to Primary Copy
			operation promoteNewPrimaryCopy[]
				const keys <- replicas.getKeys
				const vals <- replicas.getValues
		
				const n <- vals.upperbound
		
				var newPrimary : rtype <- vals[n]
		
		
				primaryCopy <- newPrimary
				primaryCopy.setIsPrimaryCopy[]
		
				replicas.delete[keys[n]]
		
				unavailable
					%do nothing, this will get picked up by process.
				end unavailable
			end promoteNewPrimaryCopy

			process 
				
				%wait for ready signal from replicateMe
				loop
				exit when replicationReady
					(locate self).Delay[Time.create[2, 0]]
				end loop
				
				loop
					self.maintainReplicas[]
		
				end loop
		
			end process
	
	
			operation maintainReplicas[] 
		
				all <- here.getActiveNodes
	
				(locate self).Delay[Time.create[2, 0]]
		
				self.wo["Checking for lost replicas"]
		
				%remove inactive replicas
				self.wo["inactive replicas # " || (inactiveList.upperbound + 1).asString ]
		
				for i : Integer <- 0 while i < inactiveList.upperbound + 1 by i <- i + 1
					var lnn : Integer <- inactiveList[i]
					if lnn < 0 then
						self.wo["Promoting new primary copy"]
						self.promoteNewPrimaryCopy[]
					else
						self.wo["Deleting replica at " || lnn.asString]
						replicas.delete[lnn]	
					end if
				end for
		
				inactiveList <- Array.of[Integer].empty
		
		
				%put up new replicas if replicas.size < maintaincopies
				self.wo["replicas.size: " || replicas.size.asString]
				if replicas.size < maintainCopies & (maintainCopies < all.upperbound + 2) then
					self.wo["replicas.size < replicas.size < maintainCopies & (maintainCopies < all.upperbound + 2)"]
					self.makeNewReplicas[(maintainCopies - replicas.size)]
				end if
		
				%check if primary Copy is available
				inactiveList.addUpper[(-1)]
				var pcNode : Node <- (locate primaryCopy)
				const waste2 <- inactiveList.removeUpper
		
		
				%checking for inactive replicas.
				var values : Array.of[rtype] <- replicas.getValues
				var keys : Array.of[Integer] <- replicas.getKeys
				self.wo["Checking for inactive replicas."]
				for i : Integer <- 0 while i < maintainCopies by i <- i + 1
					inactiveList.addUpper[keys[i]]
					var n : Node <- (locate values[i])
					const waste <- inactiveList.removeUpper
				end for

		
		
				unavailable
					self.wo["A copy is unavailable "]
				end unavailable
			end maintainReplicas
	
			operation wo[o : String]
				(locate 1)$stdout.putString[o || "\n"]
			end wo
		end aFrameworkCreator
	end of
end FrameWork






export Framework
const Framework <- class  Framework
  	
	const here <- (locate self)
	attached var all : NodeList <- here.getActiveNodes

	var primaryCopy : Replicable
	attached var primaryCopyLNN : Integer
	var isPrimaryFramework : boolean <- false
	var replicationReady : boolean <- true
	
	
	var primaryFramework : Framework
	
	var replicaFrameworkId : Integer <- 0
	
	var workerCount : Integer <- 0
	
	attached var workerList : Map.of[Integer, Framework]


	attached var replicas : Map.of[Integer, Replicable]
	var maintainCopies : Integer
	attached var inactiveList : Array.of[Integer] <- Array.of[Integer].empty

	initially
		workerList <- Map.of[Integer, Framework].create
		replicas <- Map.of[Integer, Replicable].create
		self.wo["Available nodes " || (all.upperbound + 1).asString ]
	end initially
	
	
	export operation setWorkerCount[rfc : Integer]
		workerCount <- rfc
	end setWorkerCount
	
	export operation setMaintainCopies[mc : Integer]
		maintainCopies <- mc
	end setMaintainCopies
	
	export operation getMaintainCopies[] -> [mc : Integer]
		mc <- maintainCopies
	end getMaintainCopies
	
	
	export function getCopyOfWorkerList[] -> [wl : Map.of[Integer, Framework]]
		var copy : Map.of[Integer, Framework] <- Map.of[Integer, Framework].create
		var keys : Array.of[Integer] <- workerList.getKeys
		var vals : Array.of[Framework] <- workerList.getValues

		for i : Integer <- 0 while i < (keys.upperbound + 1) by i <- i + 1
			copy.insert[keys[i], vals[i]]			
		end for
		wl <- copy
	end getCopyOfWorkerList
	
	export operation getWorkerCount[] -> [rfc : Integer]
		rfc <- workerCount
	end getWorkerCount

	export operation setPrimaryFramework[pf : FrameworkType]
		isPrimaryFramework <- false
		primaryFramework <- pf
	end setPrimaryFramework
	
	export operation setReplicaFrameworkId[rfi : Integer]
		replicaFrameworkId <- rfi
	end setReplicaFrameworkId
	export operation getPrimaryCopy[] -> [r : Replicable]
		r <- primaryCopy
	end getPrimaryCopy
	
	export operation getCopyOfReplicaList[] -> [r : Map.of[Integer, Replicable]]
		var copy : Map.of[Integer, Replicable] <- Map.of[Integer, Replicable].create
	
		var keys : Array.of[Integer] <- replicas.getKeys
		var vals : Array.of[Replicable] <- replicas.getValues
		
		for i : Integer <- 0 while i < (keys.upperbound + 1) by i <- i + 1
			copy.insert[keys[i], vals[i]]			
		end for

		r <- copy			
	end getCopyOfReplicaList

 	export operation replicateMe[pc : Replicable, count : Integer]
		replicationReady <- false

		primaryCopy <- pc
		isPrimaryFramework <- true
		primaryCopy.addObserver[self]
		primaryCopy.setIsPrimaryCopy[]
		primaryCopyLNN <- (locate primaryCopy).getLNN
		

		maintainCopies <- count

		pc.writeStatus[]
		self.wo["Attempting to maintain " || maintainCopies.asString || " replicas."]
		
		self.makeNewReplicas[count]
		
		self.wo["Replica map size : " || replicas.size.asString]
		replicationReady <- true
	end replicateMe
	
	
	%makes new replicas on available nodes
	operation makeNewReplicas[amount : Integer]
		self.wo["Attempting to make  " || amount.asString || " new replicas."]
		var newReplicas : Integer <- 0
		all <- (locate self).getActiveNodes
		for i : Integer <- 0 while i < all.upperbound + 1 by i <- i +1
			
			
			var rNode : Node <- all[i].getTheNode
			
			if newReplicas < amount & rNode.getLNN != primaryCopyLNN  then
				if replicas.contains[rNode.getLNN] = false then
					self.wo["Making new replica on node #" || rNode.getLNN.asString]
					self.makeReplicaOnNode[rNode]
					self.makeNewReplicaFrameworkOnNode[rNode]
					newReplicas <- newReplicas + 1
				end if
			end if
		end for
		self.wo["Managed to make " || newReplicas.asString || " new replicas"]
	end makeNewReplicas
	
	operation makeReplicaOnNode[n : Node]
		var replica : Replicable <- primaryCopy.cloneMe
		replica.addObserver[self]
		%self.wo["moving replica to " || n.getLNN.asString]
		move replica to n
		fix replica at n
		replicas.insert[n.getLNN, replica]
		replica.writeStatus[]
	end makeReplicaOnNode
	
	operation makeNewReplicaFrameworkOnNode[n : Node]
		var worker : Framework <- Framework.create
		worker.setPrimaryFramework[self]
		worker.setMaintainCopies[maintainCopies]
		workerCount <- workerCount + 1
		worker.setReplicaFrameworkId[workerCount]
		move worker to n
		fix worker at n
	    workerList.insert[n.getLNN, worker]
		worker.writeStatus[]
	end makeNewReplicaFrameworkOnNode

	export operation notify[obj : Replicable]
		if obj.isPrimaryCopy[] then
			self.notifyReplicasThatPrimaryCopyHasChanged[]
		else
			self.wo["framework. replica updated"]
			primaryCopy.replicaUpdated[obj]
		end if
	end notify

	operation notifyReplicasThatPrimaryCopyHasChanged[] 
		var values : Array.of[Replicable] <- replicas.getValues

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

		const n <- vals.lowerbound

		var newPrimary : Replicable <- vals[n]
	
		
		primaryCopy <- newPrimary
		primaryCopy.setIsPrimaryCopy[]
		primaryCopy.writeStatus[]
		primaryCopyLNN <- (locate primaryCopy)$LNN
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
			if isPrimaryFramework = true then
				%self.wo["maintaining replicas"]
				self.maintainReplicas[]
			else
				self.monitorPrimaryFramework[]
			end if
		end loop
	end process
	
	operation monitorPrimaryFramework[]
		const pfwaste<- primaryFramework.getPrimaryCopy
		const thisNode <- (locate self)
		
		primaryCopy <- primaryFramework.getPrimaryCopy[]
		workerList <- primaryFramework.getCopyOfWorkerList[]
		move workerList to thisNode
		replicas <- primaryFramework.getCopyOfReplicaList[]
		move replicas to thisNode
			
		maintainCopies <- primaryFramework.getMaintainCopies[]
		workerCount <- primaryFramework.getWorkerCount[]
		
		
		(locate self).Delay[Time.create[2, 0]]

		unavailable
			self.wo["Primary framework unavailable"]
			self.handlePrimaryFrameworkUnavailable[]
		end unavailable
	end monitorPrimaryFramework

	operation handlePrimaryFrameworkUnavailable[]
		
		primaryFramework <- nil
		self.wo["Sleeping..."]
		(locate self).Delay[Time.create[0, (replicaFrameworkId * 4000000)]]
		%self.wo["Woke up!"]
		
		if primaryFramework !== nil then
			self.wo["New primary framework set."]
		else
			self.wo["No primary framework set. Promoting myself to primary framework."]
			%inactiveList <- Array.of[Integer]
			self.informOtherWorkersThatIAmTheNewPrimaryFramework[]
			isPrimaryFramework <- true
		end if
		
	end handlePrimaryFrameworkUnavailable
	

	
	operation informOtherWorkersThatIAmTheNewPrimaryFramework[]
		var workers : Array.of[Framework] <- workerList.getValues
		%self.wo["Workers length" || (workers.upperbound + 1).asString]
				
		for i : Integer <- 0 while i < (workers.upperbound + 1) by i <- i + 1
			self.wo["informing worker #" || i.asString]
			self.setPrimaryFrameworkOnWorker[workers[i]]
		end for
	end informOtherWorkersThatIAmTheNewPrimaryFramework
	
	operation setPrimaryFrameworkOnWorker[f : Framework]
		
		const selfLnn <- (locate self)$lnn
		const otherLnn <- (locate f)$lnn
		
		if selfLnn != otherLnn then
			f.setPrimaryFramework[self]
		end if

		unavailable
			self.wo["worker unavailable"]
		end unavailable
	end setPrimaryFrameworkOnWorker
	
	operation maintainReplicas[] 

		all <- (locate self).getActiveNodes

		(locate self).Delay[Time.create[2, 0]]

		%self.wo["Checking for lost replicas"]

		%remove inactive replicas
		%self.wo["inactive replicas # " || (inactiveList.upperbound + 1).asString ]
		
		
		
		for i : Integer <- 0 while i < inactiveList.upperbound + 1 by i <- i + 1
			var lnn : Integer <- inactiveList[i]
			if lnn < 0 then
				self.wo["Promoting new primary copy"]
				self.promoteNewPrimaryCopy[]
			else
				self.wo["Deleting replica at " || lnn.asString]
				replicas.delete[lnn]	
				workerList.delete[lnn]
			end if
		end for

		inactiveList <- Array.of[Integer].empty

		
		


		if replicas.size < maintainCopies & (maintainCopies < (all.upperbound + 1)) then
			self.makeNewReplicas[(maintainCopies - replicas.size)]
		end if

		%check if primary Copy is available
		inactiveList.addUpper[(-1)]
		var pcNode : boolean <- primaryCopy.isPrimaryCopy[]
		const waste2 <- inactiveList.removeUpper


		%checking for inactive replicas.
		var values : Array.of[Replicable] <- replicas.getValues
		var keys : Array.of[Integer] <- replicas.getKeys
		%self.wo["Checking for inactive replicas."]
		for i : Integer <- 0 while i < replicas.size by i <- i + 1
			inactiveList.addUpper[keys[i]]
			var n : Node <- (locate values[i])
			const waste <- inactiveList.removeUpper
			%ensure replicas have the correct primary framework
			values[i].addObserver[self]
		end for

		unavailable
			self.wo["A copy is unavailable "]
		end unavailable
	end maintainReplicas
	
	
	export operation writeStatus[]
		if isPrimaryFramework = true then
			self.wo["This is the primary framework at " || (locate self)$lnn.asString]
		else
			self.wo["This is replica framework number " || replicaFrameworkId.asString || " at " || (locate self)$lnn.asString]
		end if
	end writeStatus

	operation wo[o : String]
		(locate 1)$stdout.putString[o || "\n"]
	end wo
end Framework


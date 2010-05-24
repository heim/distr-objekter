export FrameworkType
const FrameworkType <- typeobject FrameworkType
	operation notify[obj : Replicable]
	operation getPrimaryCopy[] -> [Replicable]
	operation replicateMe[primaryCopy : Replicable, n : Integer]
	operation getCopyOfReplicaList[] -> [Map.of[Integer, Replicable]]
	operation setPrimaryFramework[FrameworkType]
	operation setReplicaFrameworkId[Integer]
	operation setWorkerCount[Integer]
	operation getWorkerCount[] -> [Integer]
	operation setMaintainCopies[Integer]
	operation getMaintainCopies[] -> [Integer]
	function getCopyOfWorkerList[] -> [Map.of[Integer, FrameworkType]]
	operation writeStatus[]
end FrameworkType

export Replicable
const Replicable <- typeobject Replicable
	function cloneMe[] -> [clone : Replicable]
	operation primaryCopyUpdated[primaryCopy : Replicable]
	operation replicaUpdated[replica : Replicable]
	operation addObserver[o : FrameworkType]
	function !=[o: Replicable] -> [boolean]
	function isPrimaryCopy[] -> [boolean]
	operation setIsPrimaryCopy[]
	operation writeStatus[]
end Replicable




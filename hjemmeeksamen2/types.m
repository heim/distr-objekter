export ReplicationFramework
const ReplicationFramework <- typeobject ReplicationFramework
	operation notify[obj : Replicable]
	operation getPrimaryCopy[] -> [Replicable]
	operation replicateMe[primaryCopy : Replicable, n : Integer]
end ReplicationFramework

export Replicable
const Replicable <- typeobject Replicable
	function cloneMe[] -> [clone : Replicable]
	operation primaryCopyUpdated[primaryCopy : Replicable]
	operation replicaUpdated[replica : Replicable]
	operation addObserver[o : ReplicationFramework]
	function !=[o: Replicable] -> [boolean]
	function isPrimaryCopy[] -> [boolean]
	operation setIsPrimaryCopy[]
	operation writeStatus[]
end Replicable




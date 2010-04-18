const p <- object p
  const here <- (locate self)
	const all <- here.getActiveNodes

  
  process
		const m <- Map.of[Integer, String].create


		m.insert[1, "1"]
		m.insert[2, "2"]
		stdout.putString[m.size.asString || "\n"]
		m.delete[1]
		m.delete[2]
		m.delete[2]
		stdout.putString[m.size.asString || "\n"]

		
  	loop
  	var n : Node <- all[1]$theNode
		
		n$stdout.putString["This is me\n"]
		
		stdout.putstring["Avail: " || n.getLNN.asString || "\n"]
  	
		stdout.putstring["5\n"]
  	(locate self).Delay[Time.create[1, 0]]
		stdout.putstring["4\n"]
  	(locate self).Delay[Time.create[1, 0]]
		stdout.putstring["3\n"]
  	(locate self).Delay[Time.create[1, 0]]
		stdout.putstring["2\n"]
  	(locate self).Delay[Time.create[1, 0]]
		stdout.putstring["1\n"]
  	(locate self).Delay[Time.create[1, 0]]

	


  	stdout.putstring["Avail: " || n.getLNN.asString || "\n"]

		
		end loop
  end process


end p
return{
	compare_key = function(keys, key, mod )
		local count = #mod
		local ind = 0
		for i,a in pairs(keys)do

			local traf = false
			if count == #a[1] then
				if count>0 then
					local c = 0
					for _,b in pairs(a[1]) do
						for _,f in pairs(mod) do
							if f == b then
								c = c +1
								if c == count then
									traf = true
									break
								end
							end

						end

					end

				else
					traf = true
				end
				if string.upper(key) == string.upper(a[2]) and traf then
					ind = i
					break
				end

			end

		end
		return ind

	end


}

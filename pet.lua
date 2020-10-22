local pet = {}
pet.__index = pet

function pet:init()
	utils:log('Initializing pet', 1)

	local p = {}
	setmetatable(p, pet) -- make handle lookup

	p.name = 'NO-PET'
	p.zone = ''
	p.id = -1
	p.noPet = false
	p.isPet = true
	
	p:clear()
	
	return p
end

function pet:clear()
	self.hp = -1 -- not set: UI will show '?' instead of the number
	self.maxhp = -1
	self.mp = -1
	self.maxmp = -1
	self.tp = -1
	
	-- percentages
	self.hpp = 0
	self.mpp = 0
	self.tpp = 0
	
	self.isSelected = false
	self.isSubTarget = false
	self.isPet = true
	self.noPet = false

	
	self.job = '???'
	self.jobLvl = 0
	self.subJob = '???'
	self.subJobLvl = 0
	
	self.distance = 1
	
	self.buffs = {} -- list of all buffs this pet has
	self.filteredBuffs = T{} -- list of filtered buffs to be displayed
end

function pet:updateBuffs(buffs, filters)
	self.buffs = buffs
	self.filteredBuffs = T{}
	for i = 1, 32 do
		buff = buffs[i]
		if (settings.buffs.filterMode == 'blacklist' and filters[buff]) or 
		   (settings.buffs.filterMode == 'whitelist' and not filters[buff]) then
			buff = 1000
		end
		self.filteredBuffs[i] = buff
	end
	
	if settings.buffs.customOrder then
		self.filteredBuffs:sort(buffOrderCompare)
	else
		self.filteredBuffs:sort()
	end
end

function buffOrderCompare(a, b)
	local orderA = buffOrder[a]
	local orderB = buffOrder[b]

	if not orderA then
		return false
	elseif not orderB then
		return true
	end
	
	return buffOrder[a] < buffOrder[b]
end

function pet:vanish()
	self.name = 'NO PET!'
	self.noPet = true
end

function pet:dispose()
	self.name = 'NO PET!'
	self.noPet = true
	utils:log('Disposing pet '..self.name, 0)
	setmetatable(self, nil)
end

return pet
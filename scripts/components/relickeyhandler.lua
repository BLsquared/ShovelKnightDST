local RelicKeyHandler = Class(function(self, inst)
	self.inst = inst
	self.handler = TheInput:AddKeyHandler(function(key, down) self:OnRawKey(key, down) end )
end)

function RelicKeyHandler:OnRawKey(key, down)
	local player = ThePlayer
  	if (key and not down) and not IsPaused() then
      	player:PushEvent("relickeypressed", {inst = self.inst, player = player, key = key})
    elseif key and down and not IsPaused() then
      	player:PushEvent("relickeydown", {inst = self.inst, player = player, key = key})
  	end
end

return RelicKeyHandler
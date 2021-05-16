require("libraries/replaystuff")

LinkLuaModifier("modifier_recording", "modifiers/modifier_recording.lua", LUA_MODIFIER_MOTION_NONE)

modifier_recording = modifier_recording or class({})

function modifier_recording:IsPermanent() return true end
function modifier_recording:RemoveOnDeath() return false end
function modifier_recording:IsHidden() return false end 	-- we can hide the modifier
function modifier_recording:IsDebuff() return false end 	-- make it red or green
function modifier_recording:IsPurgable() return false end

function modifier_recording:GetEffectName() return "particles/custom/record_button.vpcf" end
function modifier_recording:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end


function modifier_recording:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
	}
	return funcs
end



function modifier_recording:OnOrder(event)
	if event.unit == self:GetParent() then 
		AddRecordedAction(self, event)
	end
end

function modifier_recording:OnDestroy(event)
	if not IsServer() then return end 

	local modifier = self
	local time = modifier:GetDuration() - modifier:GetRemainingTime()

	local parent = self:GetParent()
	local ability = self:GetAbility()
	ability.recordTime = time
	
	--print("Recording stopped with duration " .. time)

	local newItem = CreateItem("item_video_file", parent, parent)
	newItem.cloneData = ability.cloneData
	newItem.recordedActions = ability.recordedActions
	newItem.recordTime = ability.recordTime
	parent:AddItem(newItem)
	newItem:SetPurchaseTime(-10)

	--ability:StartCooldown(ability.recordTime)
	ability.isRecording = false
	ability.recordedActions = {}
end

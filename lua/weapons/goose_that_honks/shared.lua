-- Charming Discussion, A pleasant discussion between two civilized people on the game Garry's Mod.
-- Copyright (C) 2025  MrMarrant.
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

AddCSLuaFile()
AddCSLuaFile("cl_init.lua")
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Spawnable = true
SWEP.Category = "Charming Discussion"
SWEP.ViewModel = Model("models/weapons/charming_discussion/vm_goose.mdl")
SWEP.WorldModel = Model("models/weapons/charming_discussion/wm_goose.mdl") --! Problème : Le WM ne joue pas les animations
SWEP.ViewModelFOV = 65
SWEP.HoldType = "slam"
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
-- Variables Personnal to this weapon --
-- [[ STATS WEAPON ]]
SWEP.PreviousScream = "" --! Not used for now
SWEP.CountHonk = 0
SWEP.MachineGunEnable = false

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetHoldType(self.HoldType)
end

-- Set up every var related to the entity we will use
function SWEP:SetupDataTables()
	self:NetworkVar("String", 0, "CurrentScreamer")
end

function SWEP:Deploy()
	self:ActionGoose(ACT_VM_DRAW)
	return true
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()
	local soundToPlay = ""
	if ply.charmingdiscussion_wasHonk then
		soundToPlay = CHARMING_DISCUSSION_CONFIG.Sounds.Response[math.random(1, #CHARMING_DISCUSSION_CONFIG.Sounds.Response)]
	else
		soundToPlay = CHARMING_DISCUSSION_CONFIG.Sounds.BadLanguage[math.random(1, #CHARMING_DISCUSSION_CONFIG.Sounds.BadLanguage)]
	end

	self:ActionGoose(ACT_VM_PRIMARYATTACK)
	self:Honk(soundToPlay)
	ply:SetAnimation(PLAYER_ATTACK1)
	ply.charmingdiscussion_wasHonk = false
	self:HonkReward()
end

function SWEP:SecondaryAttack()
	local soundToPlay = CHARMING_DISCUSSION_CONFIG.Sounds.Ouink[math.random(1, #CHARMING_DISCUSSION_CONFIG.Sounds.Ouink)]
	self:ActionGoose(ACT_VM_SECONDARYATTACK)
	timer.Simple(0.8, function()
		if not self:IsValid() then return end
		if SERVER then self:GetOwner():EmitSound(soundToPlay) end
	end)
end

function SWEP:Honk(soundToPlay)
	if SERVER then
		self.PreviousScream = soundToPlay
		self:GetOwner():EmitSound(soundToPlay) -- On joue le son sur le Owner sinon on ne l'entend pas
		self:CheckFucker()
	end
end

function SWEP:ActionGoose(animToPlay)
	self:SendWeaponAnim(animToPlay)
	self:NextFire()
end

function SWEP:NextFire()
	local machineGunEnable = self.MachineGunEnable and self:GetActivity() == ACT_VM_PRIMARYATTACK
	local VMAnim = self:GetOwner():GetViewModel()
	local NexIdle = machineGunEnable and 0.2 or VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate()
	self:SetNextPrimaryFire(CurTime() + NexIdle + 0.1)
	self:SetNextSecondaryFire(CurTime() + NexIdle + 0.1)
	timer.Simple(NexIdle, function()
		if not self:IsValid() then return end
		self:SendWeaponAnim(ACT_VM_IDLE)
	end)
end

-- TODO : Compteur de honk à afficher peut être ?
function SWEP:CheckFucker()
	local ply = self:GetOwner()
	local size = CHARMING_DISCUSSION_CONFIG.DistanceFucker
	local dir = ply:GetAimVector()
	local angle = math.cos(math.rad(45))
	local startPos = ply:EyePos()
	local entsFound = ents.FindInCone(startPos, dir, size, angle)
	for key, value in ipairs(entsFound) do
		if value:IsPlayer() and value:HasWeapon("goose_that_honks") then
			value.charmingdiscussion_wasHonk = true
		end
	end
end

function SWEP:HonkReward()
	if SERVER then
		local ply = self:GetOwner()
		self.CountHonk = self.CountHonk + 1
		if self.CountHonk == 10 then
			ply:ChatPrint(charming_discussion.GetTranslation("rewardhonk_10"))
		elseif self.CountHonk == 50 then
			ply:ChatPrint(charming_discussion.GetTranslation("rewardhonk_50"))
		elseif self.CountHonk == 100 then
			ply:ChatPrint(charming_discussion.GetTranslation("rewardhonk_100"))
			ply:EmitSound(CHARMING_DISCUSSION_CONFIG.Sounds.Special[1])
			self:MachineGunHonk()
		elseif self.CountHonk == 300 then
			ply:ChatPrint(charming_discussion.GetTranslation("rewardhonk_300"))
			self:NextScreamer()
		elseif self.CountHonk == 500 then
			ply:ChatPrint(charming_discussion.GetTranslation("rewardhonk_500"))
			self:Explode()
		end
	end
end

function SWEP:Explode()
	local ply = self:GetOwner()
	local playerpos = ply:GetPos()
	timer.Simple(0.1, function()
		local traceworld = {}
		traceworld.start = playerpos
		traceworld.endpos = traceworld.start + (Vector(0, 0, -1) * 250)
		local trw = util.TraceLine(traceworld)
		local worldpos1 = trw.HitPos + trw.HitNormal
		local worldpos2 = trw.HitPos - trw.HitNormal
		util.Decal("Scorch", worldpos1, worldpos2)
	end)

	ply:Kill()
	util.ScreenShake(playerpos, 5, 5, 1.5, 200)
	local vPoint = playerpos + Vector(0, 0, 10)
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("HelicopterMegaBomb", effectdata)
	ply:EmitSound(Sound("ambient/explosions/explode_4.wav"))
end

function SWEP:MachineGunHonk()
	self:SendMessage(1, "machinegunhonk_01")
	self:SendMessage(3, "machinegunhonk_02")
	self:SendMessage(5, "machinegunhonk_03")
	timer.Simple(5, function()
		if not self:IsValid() then return end

		self.MachineGunEnable = true
	end)
end

function SWEP:SendMessage(delay, message)
	local ply = self:GetOwner()
	timer.Simple(delay, function()
		if not self:IsValid() or not ply:IsValid() then return end

		ply:ChatPrint(charming_discussion.GetTranslation(message))
	end)
end

function SWEP:NextScreamer()
	local ply = self:GetOwner()
	timer.Create("CharmingDiscussion.ScreamHonk." .. ply:EntIndex(), math.random(20, 30), 1, function()
		if not self:IsValid() or not ply:IsValid() then return end

		self:SetCurrentScreamer(CHARMING_DISCUSSION_CONFIG.Images[math.random(1, #CHARMING_DISCUSSION_CONFIG.Images)])
		ply:EmitSound(CHARMING_DISCUSSION_CONFIG.Sounds.Scream[math.random(1, #CHARMING_DISCUSSION_CONFIG.Sounds.Scream)])
		timer.Create("CharmingDiscussion.ScreamDelay." .. ply:EntIndex(), 0.3, 1, function()
			if not self:IsValid() or not ply:IsValid() then return end

			self:SetCurrentScreamer("")
			self:NextScreamer()
		end)
	end)
end
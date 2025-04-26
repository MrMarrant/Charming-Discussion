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
SWEP.ViewModel = Model( "models/weapons/charming_discussion/vm_goose.mdl" )
SWEP.WorldModel = Model( "models/weapons/charming_discussion/wm_goose.mdl" ) --! Problème : Le WM ne joue pas les animations

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
SWEP.PreviousScream = ""

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	self:ActionGoose( ACT_VM_DRAW )
	return true
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()
	local soundToPlay = ""
	if (ply.charmingdiscussion_wasHonk) then
		soundToPlay = CHARMING_DISCUSSION_CONFIG.Sounds.Response[math.random(1, #CHARMING_DISCUSSION_CONFIG.Sounds.Response)]
	else
		soundToPlay = CHARMING_DISCUSSION_CONFIG.Sounds.BadLanguage[math.random(1, #CHARMING_DISCUSSION_CONFIG.Sounds.BadLanguage)]
	end
	self:ActionGoose( ACT_VM_PRIMARYATTACK )
	self:Honk( soundToPlay )
	ply:SetAnimation( PLAYER_ATTACK1 )
	ply.charmingdiscussion_wasHonk = false
end

function SWEP:SecondaryAttack()
	local soundToPlay = CHARMING_DISCUSSION_CONFIG.Sounds.Ouink[math.random(1, #CHARMING_DISCUSSION_CONFIG.Sounds.Ouink)]
	self:ActionGoose( ACT_VM_SECONDARYATTACK )
	timer.Simple( 0.8, function()
		if ( !self:IsValid() ) then return end
		if (SERVER) then self:GetOwner():EmitSound( soundToPlay ) end
	end)
end

function SWEP:Honk( soundToPlay )
	if ( SERVER ) then
		self.PreviousScream = soundToPlay
		self:GetOwner():EmitSound( soundToPlay ) -- On joue le son sur le Owner sinon on ne l'entend pas
		self:CheckFucker()
	end
end

function SWEP:ActionGoose( animToPlay )
	self:SendWeaponAnim( animToPlay )
	local VMAnim = self:GetOwner():GetViewModel()
	local NexIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate()
	self:SetNextPrimaryFire( CurTime() + NexIdle + 0.1 )
	self:SetNextSecondaryFire( CurTime() + NexIdle + 0.1 )
	timer.Simple( NexIdle, function()
		if ( !self:IsValid() ) then return end
		self:SendWeaponAnim( ACT_VM_IDLE )
	end)
end

-- Compteur de honk à afficher peut être ?
function SWEP:CheckFucker()
	local ply = self:GetOwner()
	local size = CHARMING_DISCUSSION_CONFIG.DistanceFucker
	local dir = ply:GetAimVector()
	local angle = math.cos( math.rad( 45 ) )
	local startPos = ply:EyePos()
	local entsFound = ents.FindInCone( startPos, dir, size, angle )
	for key, value in ipairs(entsFound) do
		if ( value:IsPlayer() and value:HasWeapon("goose_that_honks") ) then
				value.charmingdiscussion_wasHonk = true
				ply.charmingdiscussion_honkStack = ply.charmingdiscussion_honkStack and ply.charmingdiscussion_honkStack + 1 or 1
		end
	end
end
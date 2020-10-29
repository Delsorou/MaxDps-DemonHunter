local _, addonTable = ...;

--- @type MaxDps
if not MaxDps then return end

local DemonHunter = addonTable.DemonHunter;
local MaxDps = MaxDps;

local VG = {
	SoulCleave         = 228477,
	CharredFlesh       = 264002,
	ConcentratedSigils = 207666,
	FelDevastation     = 212084,
	Metamorphosis      = 187827,
	SpiritBomb         = 247454,
	Felblade           = 232893,
	Fracture           = 263642,
	Shear              = 203782,
	ThrowGlaive        = 204157,
	SoulFragments      = 203981,
	ImmolationAura     = 258920,
	SigilOfFlame       = 204596,
	SigilOfFlame2      = 204513,
	FieryBrand         = 204021,
	DemonSpikes        = 203720,
	DemonSpikesAura    = 203819,
	SoulBarrier        = 263648,
	InfernalStrike	   = 189110,
};

setmetatable(VG, DemonHunter.spellMeta);

function DemonHunter:Vengeance()
	local fd = MaxDps.FrameData;
	local cooldown, buff, debuff, timeShift, talents =
	fd.cooldown, fd.buff, fd.debuff, fd.timeShift, fd.talents;
	local targets = MaxDps:SmartAoe();
	local fury = UnitPower('player', Enum.PowerType.Fury);
	local healthPercent = UnitHealth('player') / UnitHealthMax('player');
	local soulFragments = buff[VG.SoulFragments].count;
	local SigilOfFlame = talents[VG.ConcentratedSigils] and VG.SigilOfFlame2 or VG.SigilOfFlame;

	MaxDps:GlowEssences();

	-- DemonSpikes if ((Charges=2 and HealthPercent<0.5 and not DemonSpikesAura) or BuffRemainingSec(DemonSpikes) < 1.5) and not Metamorphosis and not FieryBrandDebuff 

	MaxDps:GlowCooldown(VG.DemonSpikes, ((cooldown[VG.DemonSpikes].charges >= 2 and healthPercent < 0.5 and not buff[VG.DemonSpikesAura].up) or buff[VG.DemonSpikesAura].remains < 1.5) and cooldown[VG.DemonSpikes].ready and not buff[VG.Metamorphosis].up and not (cooldown[VG.FieryBrand].remains > 52));

	-- FieryBrand if not Metamorphosis and not DemonSpikesAura

	MaxDps:GlowCooldown(VG.FieryBrand, cooldown[VG.FieryBrand].ready and not buff[VG.Metamorphosis].up and not buff[VG.DemonSpikesAura].up);

	-- Metamorphosis if not Metamorphosis and not FieryBrand and not DemonSpikesAura

	MaxDps:GlowCooldown(VG.Metamorphosis, cooldown[VG.Metamorphosis].ready and not buff[VG.Metamorphosis].up and not (cooldown[VG.FieryBrand].remains > 52) and not buff[VG.DemonSpikesAura].up);

	if talents[VG.SoulBarrier] then
		MaxDps:GlowCooldown(VG.SoulBarrier, cooldown[VG.SoulBarrier].ready);
	end

	-- Spell FelDevastation Cooldown if TargetsInRadius(FelDevastationDamage) >= 2 or HealthPercent < 0.75
	if cooldown[VG.FelDevastation].ready and fury > 70 and (targets >= 2 or healthPercent < 0.75) then
		return VG.FelDevastation;
	end
	
	-- Spell SigilOfFlame
	if cooldown[SigilOfFlame].ready then
		return SigilOfFlame;
	end

	if talents[VG.SpiritBomb] and fury > 30 then
		-- Spell SoulCleave if HealthPercent < 0.5 and TargetsInRadius(SoulCleave) < 3 and HasBuff(SoulFragment)
		if healthPercent < 0.5 and targets < 3 and soulFragments > 0 then
			return VG.SoulCleave;
		end
		-- Spell SpiritBomb if BuffStack(SoulFragment) >= 4 or (TargetsInRadius(SpiritBomb) >= 3 and HealthPercent < 0.5)
		if soulFragments >= 4 or (targets >= 3 and healthPercent < 0.5) then
			return VG.SpiritBomb;
		end
		-- Spell SoulCleave if PowerToMax < 30 and (not HasBuff(SoulFragment) or TargetsInRadius(SpiritBomb) < 2)
		if fury > 70 and (soulFragments == 0 or targets < 2) then
			return VG.SoulCleave;
		end
	else
		--Spell SoulCleave if HealthPercent < 0.5 and fury > 30
		if healthPercent < 0.5 and fury > 30 then
			return VG.SoulCleave;
		end
	end

	-- Spell Fracture if ChargesRemaining(Fracture) = 2
	if talents[VG.Fracture] and cooldown[VG.Fracture].charges >= 2 then
		return VG.Fracture;
	end

	-- Spell ImmolationAura
	if cooldown[VG.ImmolationAura].ready then
		return VG.ImmolationAura;
	end

	-- Spell SoulCleave if PowerToMax < 30
	if not talents[VG.SpiritBomb] and fury > 70 then
		return VG.SoulCleave;
	end

	-- Spell Fracture
	if talents[VG.Fracture] and cooldown[VG.Fracture].ready then
		return VG.Fracture;
	end

	-- Spell Felblade if PowerToMax >= 40
	if talents[VG.Felblade] and cooldown[VG.Felblade].ready and fury <= 60 then
		return VG.Felblade;
	end

	-- Spell InfernalStrike if ChargesRemaining(InfernalStrike) = 2
	if cooldown[VG.InfernalStrike].ready and cooldown[VG.InfernalStrike].charges >= 2 then
		return VG.InfernalStrike;
	end

	-- Spell Shear
	if not talents[VG.Fracture] then
		return VG.Shear;
	end
end

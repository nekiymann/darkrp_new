AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 0
    SWEP.SlotPos = 5
    SWEP.RenderGroup = RENDERGROUP_BOTH

    killicon.AddAlias("stunstick", "weapon_stunstick")

    CreateMaterial("darkrp/stunstick_beam", "UnlitGeneric", {
        ["$basetexture"] = "sprites/lgtning",
        ["$additive"] = 1
    })
end

DEFINE_BASECLASS("stick_base")

SWEP.Instructions = "Левая кнопка - ударить\nПравая кнопка - с уроном"
SWEP.IsDarkRPStunstick = true

SWEP.PrintName = "Дубинка"
SWEP.Spawnable = false
SWEP.Category = "Запрещено брать"

SWEP.StickColor = Color(0, 0, 255)

function SWEP:Initialize()
    BaseClass.Initialize(self)

    self.Hit = {
        Sound("weapons/stunstick/stunstick_impact1.wav"),
        Sound("weapons/stunstick/stunstick_impact2.wav")
    }

    self.FleshHit = {
        Sound("weapons/stunstick/stunstick_fleshhit1.wav"),
        Sound("weapons/stunstick/stunstick_fleshhit2.wav")
    }
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
end

function SWEP:Think()
    BaseClass.Think(self)
    if self.WaitingForAttackEffect and self:GetSeqIdleTime() ~= 0 and CurTime() >= self:GetSeqIdleTime() - 0.35 then
        self.WaitingForAttackEffect = false

        local Owner = self:GetOwner()

        local effectData = EffectData()
        effectData:SetOrigin(Owner:GetShootPos() + (Owner:EyeAngles():Forward() * 45))
        effectData:SetNormal(Owner:EyeAngles():Forward())
        util.Effect("StunstickImpact", effectData)
    end
end

function SWEP:DoFlash(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    ply:ScreenFade(SCREENFADE.IN, color_white, 1.2, 0)
end

local entMeta = FindMetaTable("Entity")
function SWEP:DoAttack(dmg)
    if CLIENT then return end

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    Owner:LagCompensation(true)
    local trace = util.QuickTrace(Owner:EyePos(), Owner:GetAimVector() * 90, {Owner})
    Owner:LagCompensation(false)

    local ent = trace.Entity
    if IsValid(ent) and ent.onStunStickUsed then
        ent:onStunStickUsed(Owner)
        return
    elseif IsValid(ent) and ent:GetClass() == "func_breakable_surf" then
        ent:Fire("Shatter")
        Owner:EmitSound(self.Hit[math.random(#self.Hit)])
        return
    end

    self.WaitingForAttackEffect = true

    ent = Owner:getEyeSightHitEntity(
        self.stickRange,
        15,
        fn.FAnd{
            fp{fn.Neq, Owner},
            fc{IsValid, entMeta.GetPhysicsObject},
            entMeta.IsSolid
        }
    )

    if not IsValid(ent) then return end
    if ent:IsPlayer() and not ent:Alive() then return end

    if not ent:isDoor() then
        ent:SetVelocity((ent:GetPos() - Owner:GetPos()) * 7)
    end

    if dmg > 0 then
        ent:TakeDamage(dmg, Owner, self)
    end

    if ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() then
        self:DoFlash(ent)
        Owner:EmitSound(self.FleshHit[math.random(#self.FleshHit)])
    else
        Owner:EmitSound(self.Hit[math.random(#self.Hit)])
        if FPP and FPP.plyCanTouchEnt(Owner, ent, "EntityDamage") then
            if ent.SeizeReward and not ent.beenSeized and not ent.burningup and Owner:isCP() and ent.Getowning_ent and Owner ~= ent:Getowning_ent() then
                local amount = isfunction(ent.SeizeReward) and ent:SeizeReward(Owner, dmg) or ent.SeizeReward

                Owner:addMoney(amount)
                DarkRP.notify(Owner, 1, 4, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(amount), DarkRP.getPhrase("bonus_destroying_entity")))
                ent.beenSeized = true
            end
            local health = math.max(ent:Health(), ent:GetMaxHealth())
            health = health == 0 and 1000 or health

            local dmgToTake = GAMEMODE.Config.stunstickdamage <= 1 and GAMEMODE.Config.stunstickdamage * health or GAMEMODE.Config.stunstickdamage
            -- Ceil because health is an integer value
            dmgToTake = math.max(0, math.ceil(dmgToTake - dmg))
            ent:TakeDamage(dmgToTake, Owner, self) -- for illegal entities
        end
    end
end

function SWEP:PrimaryAttack()
    BaseClass.PrimaryAttack(self)
    self:SetNextSecondaryFire(self:GetNextPrimaryFire())
    self:DoAttack(0)
end

function SWEP:SecondaryAttack()
    BaseClass.PrimaryAttack(self)
    self:SetNextSecondaryFire(self:GetNextPrimaryFire())
    self:DoAttack(5)
end

function SWEP:Reload()
end

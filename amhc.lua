
----------------------
-- 作者：裸奔的代码
-- 参与者：
-- 创建日期：2015/6/11
-- 修改日期：2015/6/11
----------------------

if AMHC == nil then
	AMHC = class({})

--初始化
function AMHCInit( )

--------------------
--这里定义私有变量--
--------------------
local __isPause = false

--颜色
local __msg_type = {}
local __color = {
	red 	={255,0,0},
	orange	={255,127,0},
	yellow	={255,255,0},
	green 	={0,255,0},
	blue 	={0,0,255},
	indigo 	={0,255,255},
	purple 	={255,0,255},
}

--------------------------
--从这里开始定义成员函数--
--------------------------

--====================================================================================================
--判断游戏是否暂停
function GamePause()
	local old = GameRules:GetGameTime()
	local new = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("GamePause"),function( )
		new = GameRules:GetGameTime()

		if old == new then
			if not __isPause then __isPause = true end
		else
			if __isPause then __isPause = false end
		end

		old = new
		return 0.01
	end,0)
end
GamePause()

function AMHC:IsPaused()
	return __isPause
end

--====================================================================================================


--====================================================================================================
--判断实体有效，存活，非存活于一体的函数
--返回true	有效且存活
--返回false	有效但非存活
--返回nil	无效实体
function AMHC:IsAlive( entity )
	if type(entity)~="table" then
		error("AMHC:IsAlive :param 0 is not entity",2);
		return;
	end

	if IsValidEntity(entity) then
		if entity:IsAlive() then
			return true
		end
		return false
	end
	return nil
end
--====================================================================================================


--====================================================================================================
--创建计时器

function AMHC:Timer( name,fun,delay,entity )
	if type(name)~="string" then
		error("AMHC:Timer :param 0 is not String",2);
		return;
	end
	if type(fun)~="function" then
		error("AMHC:Timer :param 1 is not function",2);
		return;
	end

	delay = delay or 0
	if type(delay)~="number" then
		error("AMHC:Timer :param 2 is not number",2);
		return;
	end

	local ent = nil;
	if(entity ~= nil)then
		if type(entity)~="table" then
			error("AMHC:Timer :param 3 is not entity",2);
			return;
		end
		if self:IsAlive(entity)==nil then
			error("AMHC:Timer :param 3 is not valid entity",2);
			return;
		end
		ent = entity;
	else
		ent = GameRules:GetGameModeEntity();
	end

	ent:SetContextThink(DoUniqueString(name),function( )

		if not self:IsPaused() then
			return fun();
		end

		return 0.01
	end,delay)
end

--便于实体直接调用
function CBaseEntity:Timer(fun,delay)
	if type(fun)~="function" then
		error("CBaseEntity:Timer :param 0 is not function",2);
		return;
	end

	delay = delay or 0
	if type(delay)~="number" then
		error("CBaseEntity:Timer :param 1 is not number",2);
		return;
	end
	AMHC:Timer( self:GetClassname()..tostring(self:GetOrigin()),fun,delay,self )
end

--====================================================================================================


--====================================================================================================
--创建带有计时器的特效，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticle(particleName,particleAttach,immediately,owningEntity,duration,callback)
	if type(particleName)~="string" then
		error("AMHC:CreateParticle :param 0 is not string",2);
		return;
	end
	if type(particleAttach)~="number" then
		error("AMHC:CreateParticle :param 1 is not number",2);
		return;
	end
	if type(immediately)~="boolean" then
		error("AMHC:CreateParticle :param 2 is not boolean",2);
		return;
	end
	if type(owningEntity)~="table" then
		error("AMHC:CreateParticle :param 3 is not handle",2);
		if self:IsAlive(owningEntity)==nil then
			error("AMHC:CreateParticle :param 3 is not valid entity",2);
			return;
		end
		return;
	end
	if type(duration)~="number" then
		error("AMHC:CreateParticle :param 4 is not number",2);
		return;
	end
	if callback~=nil then
		if type(callback)~="function" then
			error("AMHC:CreateParticle :param 5 is not function",2);
			return;
		end
	end
	
	local p = ParticleManager:CreateParticle(particleName,particleAttach,owningEntity)

	local time = GameRules:GetGameTime();
	self:Timer(particleName,function()
		if (GameRules:GetGameTime()-time)>=duration then
			ParticleManager:DestroyParticle(p,immediately)
			if callback~=nil then callback() end
			return nil
		end

		return 0.01
	end,0)

	return p
end

--创建带有计时器的特效，只对某玩家显示，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticleForPlayer(particleName,particleAttach,immediately,owningEntity,owningPlayer,duration,callback)
	if type(particleName)~="string" then
		error("AMHC:CreateParticleForPlayer :param 0 is not string",2);
		return;
	end
	if type(particleAttach)~="number" then
		error("AMHC:CreateParticleForPlayer :param 1 is not number",2);
		return;
	end
	if type(immediately)~="boolean" then
		error("AMHC:CreateParticleForPlayer :param 2 is not boolean",2);
		return;
	end
	if type(owningEntity)~="table" then
		error("AMHC:CreateParticleForPlayer :param 3 is not handle",2);
		if self:IsAlive(owningEntity)==nil then
			error("AMHC:CreateParticleForPlayer :param 3 is not valid entity",2);
			return;
		end
		return;
	end
	if type(owningPlayer)~="table" then
		error("AMHC:CreateParticleForPlayer :param 4 is not handle",2);
		return;
	end
	if type(duration)~="number" then
		error("AMHC:CreateParticleForPlayer :param 5 is not number",2);
		return;
	end
	if callback~=nil then
		if type(callback)~="function" then
			error("AMHC:CreateParticleForPlayer :param 6 is not function",2);
			return;
		end
	end
	
	local p = ParticleManager:CreateParticleForPlayer(particleName,particleAttach,owningEntity,owningPlayer)

	local time = GameRules:GetGameTime();
	self:Timer(particleName,function()
		if (GameRules:GetGameTime()-time)>=duration then
			ParticleManager:DestroyParticle(p,immediately)
			if callback~=nil then callback() end
			return nil
		end

		return 0.01
	end,0)

	return p
end
--====================================================================================================


--====================================================================================================
--定义常量
AMHC.MSG_BLOCK 		= "particles/msg_fx/msg_block.vpcf"
AMHC.MSG_ORIT 		= "particles/msg_fx/msg_crit.vpcf"
AMHC.MSG_DAMAGE 	= "particles/msg_fx/msg_damage.vpcf"
AMHC.MSG_EVADE 		= "particles/msg_fx/msg_evade.vpcf"
AMHC.MSG_GOLD 		= "particles/msg_fx/msg_gold.vpcf"
AMHC.MSG_HEAL 		= "particles/msg_fx/msg_heal.vpcf"
AMHC.MSG_MANA_ADD 	= "particles/msg_fx/msg_mana_add.vpcf"
AMHC.MSG_MANA_LOSS 	= "particles/msg_fx/msg_mana_loss.vpcf"
AMHC.MSG_MISS 		= "particles/msg_fx/msg_miss.vpcf"
AMHC.MSG_POISION 	= "particles/msg_fx/msg_poison.vpcf"
AMHC.MSG_SPELL 		= "particles/msg_fx/msg_spell.vpcf"
AMHC.MSG_XP 		= "particles/msg_fx/msg_xp.vpcf"

table.insert(__msg_type,AMHC.MSG_BLOCK)
table.insert(__msg_type,AMHC.MSG_ORIT)
table.insert(__msg_type,AMHC.MSG_DAMAGE)
table.insert(__msg_type,AMHC.MSG_EVADE)
table.insert(__msg_type,AMHC.MSG_GOLD)
table.insert(__msg_type,AMHC.MSG_HEAL)
table.insert(__msg_type,AMHC.MSG_MANA_ADD)
table.insert(__msg_type,AMHC.MSG_MANA_LOSS)
table.insert(__msg_type,AMHC.MSG_MISS)
table.insert(__msg_type,AMHC.MSG_POISION)
table.insert(__msg_type,AMHC.MSG_SPELL)
table.insert(__msg_type,AMHC.MSG_XP)

--显示数字特效，可指定颜色，符号
function AMHC:CreateNumberEffect( entity,number,duration,msg_type,color,icon_type )
	if type(entity)~="table" then
		error("AMHC:CreateNumberEffect :param 0 is not entity",2);
		if self:IsAlive(entity)==nil then
			error("AMHC:CreateNumberEffect :param 0 is not valid entity",2);
			return;
		end
		return;
	end
	if type(number)~="number" then
		error("AMHC:CreateNumberEffect :param 1 is not number",2);
		return
	end
	if type(duration)~="number" then
		error("AMHC:CreateNumberEffect :param 2 is not number",2);
		return
	end
	if type(color)~="table" and type(color)~="string" then
		error("AMHC:CreateNumberEffect :param 4 is not table or string",2);
		return
	end

	--判断实体
	if self:IsAlive(entity)==nil then
		return
	end

	icon_type = icon_type or 9

	--对采用的特效进行判断
	local is_msg_type = false
	for k,v in pairs(__msg_type) do
		if msg_type == v then
			is_msg_type = true;
			break;
		end
	end

	if not is_msg_type then
		error("AMHC:CreateNumberEffect :param 3 is not valid msg type;example:AMHC.MSG_GOLD",2);
		return;
	end

	--判断颜色
	if type(color)=="string" then
		color = __color[color] or {255,255,255}
	else
		if #color ~=3 then
			error("AMHC:CreateNumberEffect :param 4 color error; format example:{255,255,255}",2);
			return
		end
	end
	local color_r = tonumber(color[1]) or 255;
	local color_g = tonumber(color[2]) or 255;
	local color_b = tonumber(color[3]) or 255;
	local color_vec = Vector(color_r,color_g,color_b);

	--处理数字
	number = math.floor(number)
	local number_count = #tostring(number) + 1

	--创建特效
    local particle = AMHC:CreateParticle(msg_type,PATTACH_CUSTOMORIGIN_FOLLOW,false,entity,duration)
    ParticleManager:SetParticleControlEnt(particle,0,entity,5,"attach_hitloc",entity:GetOrigin(),true)
    ParticleManager:SetParticleControl(particle,1,Vector(10,number,icon_type))
    ParticleManager:SetParticleControl(particle,2,Vector(duration,number_count,0))
    ParticleManager:SetParticleControl(particle,3,color_vec)
end

--====================================================================================================
--创建单位，简化版
--复活英雄
--给予玩家金钱
--查找table1中指定的table2
--删除table1中指定的table2
--停止播放音效，两个接口，一个KV一个lua

--伤害系统
--触发器
--位移运动
--椭圆运动
--抛物运动
--同步技能等级
--增加或者减少modifier的数字
--弹射函数
--恢复生命值
--净化

--====================================================================================================
end
end
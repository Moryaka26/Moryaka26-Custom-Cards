local s,id=GetID()

s.listed_names={79791878}

function s.initial_effect(c)

	-- If a monster that mentions "Shining Sarcophagus"
	-- you control battles:
	-- You can send this card from your hand to the GY;
	-- that monster cannot be destroyed by battle this turn.
	-- The battle damage becomes 0,
	-- and each player draws 1 card.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

end


--========================================
-- Condition
--========================================

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	if a and a:IsFaceup()
		and a:IsControler(tp)
		and a:ListsCode(79791878) then
		return true
	end

	if d and d:IsFaceup()
		and d:IsControler(tp)
		and d:ListsCode(79791878) then
		return true
	end

	return false
end


--========================================
-- Cost
--========================================

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToGraveAsCost()
	end

	Duel.SendtoGrave(
		e:GetHandler(),
		REASON_COST
	)
end


--========================================
-- Target
--========================================

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetAttacker()~=nil
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_DRAW,
		nil,
		0,
		PLAYER_ALL,
		2
	)
end


--========================================
-- Operation
--========================================

function s.operation(e,tp,eg,ep,ev,re,r,rp)

	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc=nil

	if a and a:IsFaceup()
		and a:IsControler(tp)
		and a:ListsCode(79791878) then
		tc=a
	elseif d and d:IsFaceup()
		and d:IsControler(tp)
		and d:ListsCode(79791878) then
		tc=d
	end

	if not tc then
		return
	end

	-- Cannot be destroyed by battle this turn.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)

	-- Make all battle damage from this battle 0.
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetCondition(s.dmgcon)
	e2:SetOperation(s.dmgop)
	e2:SetLabelObject(tc)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)

	-- Each player draws 1 card.
	Duel.Draw(0,1,REASON_EFFECT)
	Duel.Draw(1,1,REASON_EFFECT)

end


--========================================
-- Battle Damage
--========================================

function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()

	if not tc then
		return false
	end

	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	return a==tc or d==tc
end

function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,0)
end
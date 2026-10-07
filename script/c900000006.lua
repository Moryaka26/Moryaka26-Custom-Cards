local s,id=GetID()

s.listed_names={79791878}

function s.initial_effect(c)

	-- Activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)

	-- Opponent's monsters cannot declare attacks
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)

	-- Remain on the field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e3)

	-- Cannot be destroyed by opponent's card effects
	-- while "Shining Sarcophagus" is on the field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetCondition(s.immcon)
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)

end


--------------------------------------------------
-- SET UP THE 3-TURN COUNTDOWN
--------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsHasType(EFFECT_TYPE_ACTIVATE)
	end

	local c=e:GetHandler()
	c:SetTurnCounter(0)

	-- Destroy during the End Phase of opponent's 3rd turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	e1:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,3)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(
		EFFECT_FLAG_CANNOT_DISABLE+
		EFFECT_FLAG_UNCOPYABLE+
		EFFECT_FLAG_IGNORE_IMMUNE+
		EFFECT_FLAG_SET_AVAILABLE
	)
	e2:SetCode(1082946)
	e2:SetLabelObject(e1)
	e2:SetOwnerPlayer(tp)
	e2:SetOperation(s.reset)
	e2:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,3)
	c:RegisterEffect(e2)
end


function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.desop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end


--------------------------------------------------
-- DESTROY AFTER OPPONENT'S 3RD TURN
--------------------------------------------------

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end


function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)

	if ct==3 then
		Duel.Destroy(c,REASON_RULE)
		if re then
			re:Reset()
		end
	end
end


--------------------------------------------------
-- SHINING SARCOPHAGUS PROTECTION
--------------------------------------------------

function s.immcon(e)
	return Duel.IsExistingMatchingCard(
		s.sarfilter,
		0,
		LOCATION_ONFIELD,
		LOCATION_ONFIELD,
		1,
		nil
	)
end


function s.sarfilter(c)
	return c:IsCode(79791878)
end
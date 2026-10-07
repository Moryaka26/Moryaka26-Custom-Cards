local s,id=GetID()

s.listed_names={79791878}

function s.initial_effect(c)

	-- Effect 1
	-- If "Shining Sarcophagus" is on the field:
	-- You can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)


	-- Effect 2
	-- If this card is Normal or Special Summoned:
	-- You can add 1 Spell/Trap that mentions "Shining Sarcophagus"
	-- from your Deck or GY to your hand,
	-- except "Shining Sarcophagus".
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)


	-- Effect 3
	-- Once per turn, reveal 1 Spell in your hand,
	-- then target 1 face-up monster on the field;
	-- negate its effects until the end of this turn,
	-- then, if the revealed card was a Normal Spell,
	-- this card gains 500 ATK.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)

end


--------------------------------------------------
-- EFFECT 1
--------------------------------------------------

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
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

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(
				e,
				0,
				tp,
				false,
				false
			)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_SPECIAL_SUMMON,
		e:GetHandler(),
		1,
		0,
		0
	)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then
		return
	end

	Duel.SpecialSummon(
		c,
		0,
		tp,
		tp,
		false,
		false,
		POS_FACEUP
	)
end


--------------------------------------------------
-- EFFECT 2
--------------------------------------------------

function s.thfilter(c)
	return c:IsSpellTrap()
		and c:ListsCode(79791878)
		and not c:IsCode(79791878)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,
			tp,
			LOCATION_DECK+LOCATION_GRAVE,
			0,
			1,
			nil
		)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOHAND,
		nil,
		1,
		tp,
		LOCATION_DECK+LOCATION_GRAVE
	)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_ATOHAND
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.thfilter,
		tp,
		LOCATION_DECK+LOCATION_GRAVE,
		0,
		1,
		1,
		nil
	)

	if #g>0 then
		Duel.SendtoHand(
			g,
			nil,
			REASON_EFFECT
		)

		Duel.ConfirmCards(
			1-tp,
			g
		)
	end
end


--------------------------------------------------
-- EFFECT 3
--------------------------------------------------

function s.negfilter(c)
	return c:IsType(TYPE_SPELL)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.negfilter,
			tp,
			LOCATION_HAND,
			0,
			1,
			nil
		)
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_CONFIRM
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.negfilter,
		tp,
		LOCATION_HAND,
		0,
		1,
		1,
		nil
	)

	local rc=g:GetFirst()

	-- Save the revealed card's code.
	if rc then
		e:SetLabel(rc:GetCode())
	else
		e:SetLabel(0)
	end

	Duel.ConfirmCards(
		1-tp,
		g
	)
end

function s.normalspellfilter(c,code)
	return c:IsCode(code)
		and c:GetType()==TYPE_SPELL
end

function s.negfilter2(c)
	return c:IsFaceup()
		and c:IsType(TYPE_MONSTER)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and chkc:IsFaceup()
			and chkc:IsType(TYPE_MONSTER)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.negfilter2,
			tp,
			LOCATION_MZONE,
			LOCATION_MZONE,
			1,
			nil
		)
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_FACEUP
	)

	Duel.SelectTarget(
		tp,
		s.negfilter2,
		tp,
		LOCATION_MZONE,
		LOCATION_MZONE,
		1,
		1,
		nil
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_DISABLE,
		nil,
		1,
		0,
		0
	)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)

	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if not tc then
		return
	end

	if not tc:IsRelateToEffect(e) then
		return
	end

	if not tc:IsFaceup() then
		return
	end

	if not tc:IsType(TYPE_MONSTER) then
		return
	end

	-- Negate the monster's effects
	Duel.NegateRelatedChain(
		tc,
		RESET_TURN_SET
	)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e2)

	-- If the revealed card was a Normal Spell,
	-- this card gains 500 ATK until it leaves the field.
	local revealed_code=e:GetLabel()

	if revealed_code~=0
		and Duel.IsExistingMatchingCard(
			s.normalspellfilter,
			tp,
			LOCATION_HAND,
			0,
			1,
			nil,
			revealed_code
		) then

		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetValue(500)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)

	end

end
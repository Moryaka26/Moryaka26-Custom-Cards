local s,id=GetID()

s.listed_names={79791878}

function s.initial_effect(c)

	-- Effect 1:
	-- If your opponent controls more monsters than you do,
	-- you can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon_hand)
	e1:SetTarget(s.sptg_hand)
	e1:SetOperation(s.spop_hand)
	c:RegisterEffect(e1)

	-- Effect 2:
	-- You can discard this card; add 1 card that mentions
	-- "Shining Sarcophagus" from your Deck to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	-- Effect 3:
	-- If this card is in your GY, except during the turn it was sent there:
	-- You can banish 1 other monster that mentions "Shining Sarcophagus"
	-- from your GY; Special Summon this card, but banish it when it leaves the field.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon_grave)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg_grave)
	e3:SetOperation(s.spop_grave)
	c:RegisterEffect(e3)

end


--========================================
-- Effect 1
-- Special Summon from hand
--========================================

function s.spcon_hand(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end

function s.sptg_hand(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
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

function s.spop_hand(e,tp,eg,ep,ev,re,r,rp)
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


--========================================
-- Effect 2
-- Discard to search
--========================================

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsDiscardable()
	end

	Duel.SendtoGrave(
		e:GetHandler(),
		REASON_COST+REASON_DISCARD
	)
end

function s.thfilter(c)
	return c:ListsCode(79791878)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,
			tp,
			LOCATION_DECK,
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
		LOCATION_DECK
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
		LOCATION_DECK,
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


--========================================
-- Effect 3
-- Special Summon from GY
--========================================

function s.spcon_grave(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end

function s.rmfilter(c,e)
	return c:IsMonster()
		and c:ListsCode(79791878)
		and c~=e:GetHandler()
		and c:IsAbleToRemove()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.rmfilter,
			tp,
			LOCATION_GRAVE,
			0,
			1,
			nil,
			e
		)
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_REMOVE
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.rmfilter,
		tp,
		LOCATION_GRAVE,
		0,
		1,
		1,
		nil,
		e
	)

	Duel.Remove(
		g,
		POS_FACEUP,
		REASON_COST
	)
end

function s.sptg_grave(e,tp,eg,ep,ev,re,r,rp,chk)
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

function s.spop_grave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then
		return
	end

	if Duel.SpecialSummon(
		c,
		0,
		tp,
		tp,
		false,
		false,
		POS_FACEUP
	)>0 then

		-- Banish this card when it leaves the field.
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(
			RESET_EVENT+RESETS_REDIRECT
		)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)

	end
end
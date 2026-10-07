local s,id=GetID()
s.listed_names={79791878}

function s.initial_effect(c)
    -- If this card is added from your Deck to your hand by a card effect:
    -- You can Special Summon this card.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- You can Tribute this card; Special Summon 1 monster
    -- that mentions "Shining Sarcophagus" from your Deck.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    -- When your opponent declares an attack while this card is in your GY:
    -- You can banish this card; negate the attack, then end the Battle Phase.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    return c:GetPreviousLocation()==LOCATION_DECK
        and c:GetReason()&REASON_EFFECT~=0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
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

    if c:IsRelateToEffect(e)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsReleasable()
    end

    Duel.Release(e:GetHandler(),REASON_COST)
end

function s.spfilter(c,e,tp)
    return c:IsMonster()
        and c:ListsCode(79791878)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.spfilter,
            tp,
            LOCATION_DECK,
            0,
            1,
            nil,
            e,
            tp
        )
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_SPECIAL_SUMMON,
        nil,
        1,
        tp,
        LOCATION_DECK
    )
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(
        tp,
        s.spfilter,
        tp,
        LOCATION_DECK,
        0,
        1,
        1,
        nil,
        e,
        tp
    )

    local tc=g:GetFirst()

    if tc then
        Duel.SpecialSummon(
            tc,
            0,
            tp,
            tp,
            false,
            false,
            POS_FACEUP
        )
    end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker()
        and Duel.GetAttacker():IsControler(1-tp)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsAbleToRemoveAsCost()
    end

    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateAttack()
    Duel.SkipPhase(
        1-tp,
        PHASE_BATTLE,
        RESET_PHASE+PHASE_BATTLE_STEP,
        1
    )
end
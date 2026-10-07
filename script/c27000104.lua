local s,id=GetID()
s.listed_names={79791878}

function s.initial_effect(c)
    -- If this card is Normal or Special Summoned: Change it to Defense Position
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
    c:RegisterEffect(e1)

    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- Quick Effect: Send this card to the GY; the attacked monster gains ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.atkcon)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- If you control "Shining Sarcophagus": Your opponent cannot target
    -- monsters you control with card effects
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.immunetg)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        return e:GetHandler():IsFaceup()
    end
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
    end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetAttackTarget()

    return tc
        and tc:IsControler(tp)
        and tc:IsFaceup()
        and tc:ListsCode(79791878)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=Duel.GetAttackTarget()

    if chk==0 then
        return tc
            and tc:IsControler(tp)
            and tc:IsFaceup()
            and tc:ListsCode(79791878)
            and e:GetHandler():IsAbleToGrave()
    end

    Duel.SetTargetCard(tc)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()

    if not tc or not tc:IsRelateToEffect(e) then
        return
    end

    if not c:IsRelateToEffect(e) then
        return
    end

    local def=c:GetDefense()

    if Duel.SendtoGrave(c,REASON_EFFECT)>0 and tc:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(def)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
        tc:RegisterEffect(e1)
    end
end

function s.immunetg(e,c)
    return c:IsFaceup()
        and Duel.IsExistingMatchingCard(
            Card.IsCode,
            e:GetHandlerPlayer(),
            LOCATION_ONFIELD,
            0,
            1,
            nil,
            79791878
        )
end
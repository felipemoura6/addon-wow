local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Para garantir que o script está carregado corretamente

-- Criar o frame principal com fundo
local frameWithBackground = CreateFrame("Frame", nil, UIParent)
frameWithBackground:SetSize(70, 40) -- Define o tamanho do frame com o fundo
frameWithBackground:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 125, -80) -- Posição do frame com fundo

-- Adicionar fundo ao frame principal
frameWithBackground:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Fundo sólido
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- Borda decorativa
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
frameWithBackground:SetBackdropColor(0.2, 0.1, 0.0, 1.0) -- Cor de fundo (marrom escuro com transparência)

-- Criar o MessageFrame dentro do frame principal
local customFrame = CreateFrame("MessageFrame", nil, frameWithBackground)
customFrame:SetSize(120, 30) -- Ajustar o tamanho do MessageFrame
customFrame:SetPoint("CENTER", frameWithBackground, "CENTER", -2, -1) -- Centralizar dentro do frame principal
customFrame:SetInsertMode("TOP")
customFrame:SetFont("Fonts\\FRIZQT__.TTF", 16, "THICKOUTLINE")
customFrame:SetFading(false)



-- Tabela para armazenar alvos com Living Bomb ativo
local activeLivingBombs = 0 -- Variável para contar Living Bombs ativos
local livingBombTargets = {}


-- Configuração do tempo de duração do Living Bomb (em segundos)
local LIVING_BOMB_DURATION = 12

-- Função para atualizar o tempo restante
local function updateLivingBombs()
    local currentTime = GetTime()
    for target, data in pairs(livingBombTargets) do
        if currentTime > data.expiration then
            livingBombTargets[target] = nil -- Remove o alvo se o efeito expirou
        end
    end
end


SLASH_HITLIVING1 = "/hitliving" -- Nome do comando (ex.: /hg)
SLASH_HITLIVING2 = "/hitliving teste" -- Um segundo nome para o mesmo comando (opcional)


-- Função que será chamada ao usar o comando
SlashCmdList["HITLIVING"] = function(msg)

    local spellIcon = "Interface\\Icons\\Spell_Mage_Polymorph" -- Ícone de exemplo
    local iconSizeWidth = 24
    local iconSizeHeight = 28

    -- Analisa o que foi digitado após o comando
    if msg == "" then
        print("|cff69CCF0[HitLiving]:|r Comandos disponíveis: /hitliving teste")
    elseif msg == "teste" then
        message = string.format(
                "|T%s:%d:%d|t |cffC41F3BLiving Bomb Count: ?",
                spellIcon, iconSizeWidth, iconSizeHeight
            )
        DEFAULT_CHAT_FRAME:AddMessage(message) 
        PlaySound(8959) -- Alerta sonoro
    else
        print("|cff69CCF0[HitGrip]:|r Comando desconhecido. Use '/hitliving'.")
    end
end




-- Função para mensagem inicial
local function handle_PLAYER_ENTERING_WORLD()
    local message = "|cff00ff00[Addon HitLiving]:|r Um addon criado por |cff69CCF0Hitsugai, |rum mage sem damage! Utilize /hitliving"
    DEFAULT_CHAT_FRAME:AddMessage(message) 
end

-- Função para capturar o evento COMBAT_LOG_EVENT_UNFILTERED
local function Living_COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, _, ...)
    local iconSizeWidth = 24
    local iconSizeHeight = 28
    local spellName, spellRank, spellIcon = GetSpellInfo(spellID)

    -- Verifica se o evento é o lançamento ou remoção de Living Bomb
    if eventtype == "SPELL_CAST_SUCCESS" and spellName == "Living Bomb" and srcGUID == UnitGUID("player") then

        -- Living Bomb aplicado
        if not livingBombTargets[dstGUID] then
            livingBombTargets[dstGUID] = true
            --print("Living Bomb aplicado em: " .. (dstName or "Alvo desconhecido"))
            activeLivingBombs=activeLivingBombs+1
            PlaySound(8959) -- Alerta sonoro
        end
    elseif eventtype == "SPELL_AURA_REFRESH" and spellName == "Living Bomb" and srcGUID == UnitGUID("player") then
        -- Living Bomb renovado
        if livingBombTargets[dstGUID] then
            livingBombTargets[dstGUID].expiration = GetTime() + LIVING_BOMB_DURATION
            --print("Living Bomb renovado em: " .. (dstName or "Alvo desconhecido"))
        end
    elseif eventtype == "SPELL_AURA_REMOVED"  and spellName == "Living Bomb" then
        -- Living Bomb removido
        if livingBombTargets[dstGUID] then
            livingBombTargets[dstGUID] = nil
            --print("Living Bomb expirou/removido de: " .. (dstName or "Alvo desconhecido"))
            activeLivingBombs=activeLivingBombs-1
        end
    end

    -- Cor do texto (hexadecimal)
    local textColor = "ff0000" -- Vermelho; pode ser ajustado para outras cores
    local spellIcon = "Interface\\Icons\\Ability_Mage_LivingBomb" -- Ícone de exemplo

    -- Formata a mensagem
    local message = string.format(
        "|T%s:%d:%d|t |cff%s: %d|r",
        spellIcon, iconSizeWidth, iconSizeHeight, textColor, activeLivingBombs
    )
    
    -- Exibe a mensagem no quadro personalizado
    customFrame:AddMessage(message)

    -- Atualiza a lista
    updateLivingBombs()   
end



frame:SetScript("OnEvent", function(self, event, ...)

    if event == "PLAYER_ENTERING_WORLD" then
        handle_PLAYER_ENTERING_WORLD()
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        Living_COMBAT_LOG_EVENT_UNFILTERED(...)
    end
end)

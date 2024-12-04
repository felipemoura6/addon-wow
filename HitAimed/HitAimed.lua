local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Para garantir que o script está carregado corretamente

-- Criar o frame principal com fundo
local frameWithBackground = CreateFrame("Frame", nil, UIParent)
frameWithBackground:SetSize(40, 40) -- Define o tamanho do frame com o fundo
frameWithBackground:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 215, -30) -- Posição do frame com fundo

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
customFrame:SetSize(140, 30) -- Ajustar o tamanho do MessageFrame
customFrame:SetPoint("CENTER", frameWithBackground, "CENTER", 1, -4) -- Centralizar dentro do frame principal
customFrame:SetInsertMode("TOP")
customFrame:SetFont("Fonts\\FRIZQT__.TTF", 20, "THICKOUTLINE")
customFrame:SetFading(false)



local enemyCount = 0
local attackingEnemies = {} -- Tabela para armazenar inimigos únicos
local previousEnemyCount = 0

SLASH_HITAIMED1 = "/hitaimed"
SLASH_HITAIMED2 = "/hitaimed teste"
SLASH_HITAIMED3 = "/hitaimed list"

SlashCmdList["HITAIMED"] = function(msg)
    if msg == "" then
        print("|cff69CCF0[HitAimed]:|r Comandos disponíveis: /hitaimed teste")
    elseif msg == "teste" then
        customFrame:AddMessage(enemyCount)
        PlaySound(8959)
    elseif msg == "list" then
        print(enemyCount)
        PlaySound(8959)
    else
        print("|cff69CCF0[HitAimed]:|r Comando desconhecido. Use '/hitaimed'.")
    end
end


-- Função para mensagem inicial
local function handle_PLAYER_ENTERING_WORLD()
    local message = "|cff00ff00[Addon HitAimed]:|r Um addon criado por |cff69CCF0Hitsugai, |rum mage sem damage! Utilize /hitaimed"
    DEFAULT_CHAT_FRAME:AddMessage(message) 
    customFrame:AddMessage(0)
end


-- Função para capturar o evento COMBAT_LOG_EVENT_UNFILTERED
local function HitAimed_COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, _, ...)
    local playerGUID = UnitGUID("player")
    
    -- Verificar se o alvo do evento é o jogador
    if dstGUID == playerGUID then
        -- Verificar se o atacante é um jogador (não NPC)
        local isPlayer = bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
        -- Verificar se o atacante é inimigo
        local isFriendly = bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0
        if not isFriendly and isPlayer then
            -- Verifica se o inimigo já foi contado
            if not attackingEnemies[srcGUID] then
                attackingEnemies[srcGUID] = true  -- Adiciona o inimigo à lista
                enemyCount = enemyCount + 1  -- Incrementa o contador
            end
        end
    elseif dstGUID ~= playerGUID then
        -- Verificar se o `srcGUID` está no vetor de atacantes
        if attackingEnemies[srcGUID] then
            -- Remove o atacante e decrementa o contador
            attackingEnemies[srcGUID] = nil
            enemyCount = enemyCount - 1
            -- print("Atacante removido:", srcName)
        end
    end

    if enemyCount ~= previousEnemyCount then
        customFrame:AddMessage(enemyCount)
        previousEnemyCount = enemyCount
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        handle_PLAYER_ENTERING_WORLD()
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HitAimed_COMBAT_LOG_EVENT_UNFILTERED(...)
    end

end)

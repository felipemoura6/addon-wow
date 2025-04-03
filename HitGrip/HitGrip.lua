local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Para garantir que o script está carregado corretamente

-- Criar o frame para exibir a mensagem
local customFrame = CreateFrame("MessageFrame", nil, UIParent)
customFrame:SetSize(500, 100)
customFrame:SetPoint("CENTER", 0, 200) -- Centralizado acima do personagem
customFrame:SetInsertMode("TOP")
customFrame:SetFont("Fonts\\FRIZQT__.TTF", 20, "THICKOUTLINE")
customFrame:SetFading(true)
customFrame:SetTimeVisible(4) -- Mensagens visíveis por 3 segundos

-- Variável global para controle de som (ativa por padrão)
isSoundEnabled = true 
isAddonEnabled = true 


SLASH_HITGRIP1 = "/hitgrip" -- Nome do comando (ex.: /hg)
SLASH_HITGRIP2 = "/hitgrip teste" -- Um segundo nome para o mesmo comando (opcional)
SLASH_HITGRIP3 = "/hitgrip sound" -- Um segundo nome para o mesmo comando (opcional)
SLASH_HITGRIP4 = "/hitgrip enable" -- Um segundo nome para o mesmo comando (opcional)


-- Função que será chamada ao usar o comando
SlashCmdList["HITGRIP"] = function(msg)

    local spellIcon = "Interface\\Icons\\Spell_DeathKnight_Strangulate" -- Ícone de exemplo
    local iconSizeWidth = 24
    local iconSizeHeight = 28

    -- Analisa o que foi digitado após o comando
    if msg == "" then
        print("|cff69CCF0[HitGrip]:|r Comandos disponíveis: \n/hitgrip enable: (" .. tostring(isAddonEnabled) .. ")\n/hitgrip sound: (" .. tostring(isSoundEnabled) .. ")\n/hitgrip teste")
    
    elseif msg == "teste" then
        if not isAddonEnabled then  
            print("|cff69CCF0[HitGrip]:|r O addon está desativado! Use /hitgrip enable para ativá-lo.")  
            return  
        end 
        message = string.format(
                "|T%s:%d:%d|t |cffC41F3BTeste |cffC8FFC8usou Death Grip em Teste",
                spellIcon, iconSizeWidth, iconSizeHeight
            )
        customFrame:AddMessage(message)
        if isSoundEnabled then PlaySound(8959) end -- Alerta sonoro

    elseif msg == "sound" then
        if isAddonEnabled then 
            isSoundEnabled = not isSoundEnabled  -- Alterna entre ativado e desativado
            local status = isSoundEnabled and "ativado" or "desativado"
            print("|cff69CCF0[HitGrip]:|r Som " .. status .. "!")
        else 
            print("|cff69CCF0[HitGrip]:|r O addon está desativado! Use /hitgrip enable para ativá-lo.")  
        end  -- Faltava este `end` para fechar corretamente o `if` dentro do `elseif msg == "sound"`

    elseif msg == "enable" then
        isAddonEnabled = not isAddonEnabled  -- Alterna entre ativado e desativado
        local statusAddon = isAddonEnabled and "ativado" or "desativado"
        print("|cff69CCF0[HitGrip]:|r Addon " .. statusAddon .. "!")

    else
        print("|cff69CCF0[HitGrip]:|r Comando desconhecido. Use '/hitgrip'.")
    end
end
    




local function GetClassColor(classFile)
    local color = RAID_CLASS_COLORS[classFile]
    if color then
        -- Retorna os valores de cor RGB (0-1) e o formato hexadecimal
        return color.r, color.g, color.b, string.format("%02X%02X%02X", color.r * 255, color.g * 255, color.b * 255)
    else
        -- Caso a classe não seja encontrada (ou seja um mob/NPC), retorna branco como padrão
        return 1, 1, 1, "FFFFFF"
    end
end


-- Função para mensagem inicial
local function handle_PLAYER_ENTERING_WORLD()
    local message = "|cff00ff00[Addon HitGrip]:|r Um addon criado por |cff69CCF0Hitsugai, |rum mage sem damage! Utilize /hitgrip"
    DEFAULT_CHAT_FRAME:AddMessage(message) 
end

-- Função para capturar o evento COMBAT_LOG_EVENT_UNFILTERED
local function Puxao_COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, _, ...)
    if not isAddonEnabled then return end -- Se o addon estiver desativado, ignora
    -- Verifica se o evento é a habilidade "Death Grip"
    local spellName, spellRank, spellIcon = GetSpellInfo(spellID)
    
    if eventtype == "SPELL_CAST_SUCCESS" and spellName == "Death Grip" then
        local iconSizeHeight = 28   -- Altura do ícone (retângulo)
        local iconSizeWidth = 24    -- Largura do ícone (retângulo)

        -- Variáveis para a cor do destino
        local classColor = "FFFFFF" -- Cor padrão (branca)

        -- Obtém o GUID do jogador local
        local playerGUID = UnitGUID("player")
        local isPlayerCaster = srcGUID == playerGUID -- Verifica se o lançador sou eu

        -- Determina se o lançador é da raid, grupo ou externo
        local isFromRaid = bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_RAID) ~= 0
        local isFromParty = bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) ~= 0
        local sourceAffiliation = isFromRaid and "|cff00ff00[Raid]|r" or (isFromParty and "|cff00ff00[Grupo]|r" or "|cffff0000[Externo]|r")

        -- Determina se é Horda ou Aliança
        local isFriendly = bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0
        local sourceFaction = isFriendly and playerFaction or (playerFaction == "Horde" and "Alliance" or "Horde")

        -- Caso o lançador seja o jogador
        if isPlayerCaster then
            sourceAffiliation = "|cff00ff00[Você]|r"
            faction = "|cffff0000[Horda]|r"
        end

        local unit = "target"  -- Aqui você pode usar "player", "target", ou outra unidade conforme necessário
        
        -- Verificar se a unidade é um jogador
        if UnitIsPlayer(unit) then
            -- Obtém a classe do jogador
            local className, classFile = UnitClass(unit)  -- classFile é a chave em inglês da classe
            --print("O jogador " .. UnitName(unit) .. " é da classe: " .. classFile)

            if classFile then
                -- Obtém a cor da classe
                local r, g, b, colorHex = GetClassColor(classFile)
                classColor = colorHex -- Atualiza para a cor real da classe
            end

        else
            -- print("O destino " .. UnitName(unit) .. " é um NPC.")
        end

        local message=''

        -- Formata a mensagem com o ícone retangular e a cor da classe
        if isFriendly then
            message = string.format(
                "|T%s:%d:%d|t %s |cffC41F3B%s |cffC8FFC8usou Death Grip em |cff%s%s",
                spellIcon, iconSizeWidth, iconSizeHeight, sourceAffiliation, srcName or "Desconhecido", classColor, dstName or "Desconhecido"
            )

        elseif UnitGUID("player") == dstGUID then
            -- Se você é o alvo, coloração de perigo
            message = string.format(
                "|cffFF0000[ALERTA!] %s usou Death Grip em |cffFF0000Você|T%s:%d:%d|t ",
                srcName or "Desconhecido", spellIcon, iconSizeWidth, iconSizeHeight
            )
            if isSoundEnabled then PlaySound(11466) end
        else
            message = string.format(
                "%s |cffC41F3B%s |cffFF7F7Fusou Death Grip em |cff%s%s|r |T%s:%d:%d|t", 
                sourceAffiliation, srcName or "Desconhecido", classColor, dstName or "Desconhecido", spellIcon, iconSizeWidth, iconSizeHeight
            )
            if isSoundEnabled then PlaySound(11466) end
        end
        
        -- Exibe a mensagem no quadro personalizado
        customFrame:AddMessage(message)
        if isSoundEnabled then PlaySound(8959) end
    

    end
end



frame:SetScript("OnEvent", function(self, event, ...)  
    if not isAddonEnabled then return end  -- Sai imediatamente se o addon estiver desativado  

    if event == "PLAYER_ENTERING_WORLD" then  
        handle_PLAYER_ENTERING_WORLD()  
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then  
        Puxao_COMBAT_LOG_EVENT_UNFILTERED(...)  
    end  
end)


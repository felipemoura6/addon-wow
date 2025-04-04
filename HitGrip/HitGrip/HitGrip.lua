HitGrip = LibStub("AceAddon-3.0"):NewAddon("HitGrip", "AceConsole-3.0", "AceEvent-3.0")
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Para garantir que o script está carregado corretamente


function HitGrip:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HitGripDB", {
        profile = {
            isAddonEnabled = true,
            isSoundEnabled = true,
            fontSize = 20,
            frameOffsetX = 0,
            frameOffsetY = 250,
            editMode = false,
        }
    })
    
    
    
    self:CreateCustomFrame()

    -- Sincroniza as variáveis com o banco de dados
    isAddonEnabled = self.db.profile.isAddonEnabled
    isSoundEnabled = self.db.profile.isSoundEnabled

    self:SetupOptions()
end


function HitGrip:SetAddonEnabled(value)
    self.db.profile.isAddonEnabled = value -- Salva no banco de dados
    isAddonEnabled = value -- Atualiza a variável global
end

function HitGrip:UpdateFont()
    if self.customFrame then
        self.customFrame:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.fontSize, "THICKOUTLINE")
    end
end

-- Atualiza posição do frame (mensagem)
function HitGrip:UpdateFramePosition()
    if self.customFrame then
        self.customFrame:ClearAllPoints()
        self.customFrame:SetPoint("CENTER", self.db.profile.frameOffsetX, self.db.profile.frameOffsetY)
    end
end

-- Restaura posição padrão do frame (mensagem)
function HitGrip:ResetFramePosition()
    self.db.profile.frameOffsetX = 0
    self.db.profile.frameOffsetY = 250

    if self.customFrame then
        self.customFrame:ClearAllPoints()
        self.customFrame:SetPoint("CENTER", UIParent, "CENTER", self.db.profile.frameOffsetX, self.db.profile.frameOffsetY)
    end
end



function HitGrip:ShowDragHint()
    if not self.customFrame.border then
        self.customFrame.border = self.customFrame:CreateTexture(nil, "OVERLAY")
        self.customFrame.border:SetAllPoints()
        self.customFrame.border:SetColorTexture(1, 1, 1, 0.2)
    end
    self.customFrame.border:Show()

    C_Timer.After(3, function()
        if self.customFrame.border then
            self.customFrame.border:Hide()
        end
    end)
end




-- Criar o frame para exibir a mensagem
function HitGrip:CreateCustomFrame()
    self.customFrame = CreateFrame("MessageFrame", "HitGripCustomFrame", UIParent)
    self.customFrame:SetSize(500, 100)
    self.customFrame:SetPoint("CENTER", self.db.profile.frameOffsetX, self.db.profile.frameOffsetY)
    self.customFrame:SetInsertMode("TOP")
    self.customFrame:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.fontSize or 20, "THICKOUTLINE")
    self.customFrame:SetFading(true)
    self.customFrame:SetTimeVisible(4)

    -- Sempre habilita mouse (para futuros cliques), mas só move se estiver em modo edição
    self.customFrame:EnableMouse(true)
    self.customFrame:SetMovable(true)
    self.customFrame:RegisterForDrag("LeftButton")
    self.customFrame:SetClampedToScreen(true)

    self.customFrame:SetScript("OnDragStart", function(frame)
        if self.db.profile.editMode then
            frame:StartMoving()
        end
    end)

    self.customFrame:SetScript("OnDragStop", function(frame)
        if self.db.profile.editMode then
            frame:StopMovingOrSizing()
            local point, _, _, x, y = frame:GetPoint()
            self.db.profile.frameOffsetX = x
            self.db.profile.frameOffsetY = y
            print("|cff69CCF0[HitGrip]:|r Nova posição salva.")
        end
    end)
end




function HitGrip:RunTest()
    local classColors = {
        WARRIOR = "|cffC79C6E",
        PALADIN = "|cffF58CBA",
        HUNTER = "|cffABD473",
        ROGUE = "|cffFFF569",
        PRIEST = "|cffFFFFFF",
        DEATHKNIGHT = "|cffC41F3B",
        SHAMAN = "|cff0070DE",
        MAGE = "|cff69CCF0",
        WARLOCK = "|cff9482C9",
        DRUID = "|cffFF7D0A",
    }

    local function randomName()
        local names = { "Hitsugai", "Aterrorizado", "Arthas", "Jaina", "Thrall", "Sylvanas", "Uther", "Gul'dan", "Kil'jaeden", "Illidan", "Tyrande", "Malfurion", "Bolvar", "Anduin", "Varian", "Vol'jin", "Cairne", "Baine", "Grommash", "Garrosh", "Kel'Thuzad", "Ner'zhul", "Medivh", "Turalyon", "Alleria", "Velen", "Kael'thas", "Anub'arak", "Deathwing", "Alexstrasza", "Ysera", "Nozdormu", "Murozond", "Zul'jin", "Rokhan", "Nazgrim", "Thassarian", "Lady Liadrin", "Moira", "Muradin", "Genn Greymane", "Valeera", "Rexxar", "Maiev Shadowsong", "Xal'atath", "Zovaal", "Denathrius", "The Jailer", "Bwonsamdi", "Azshara", "N'Zoth", "C'Thun", "Yogg-Saron", "Sargeras" }

        
        return names[math.random(#names)]
    end
    
    local function randomClass()
        local classKeys = {}
        for class in pairs(classColors) do
            table.insert(classKeys, class)
        end
        local selected = classKeys[math.random(#classKeys)]
        return selected, classColors[selected]
    end
    
    local sourceName = randomName()
    local destName = randomName()
    
    local class, color = randomClass()

    local spellIcon = "Interface\\Icons\\Spell_DeathKnight_Strangulate"
    local iconSizeWidth = 24
    local iconSizeHeight = 28

    local message = string.format(
        "|T%s:%d:%d|t |cffC41F3B%s |cffC8FFC8usou Death Grip em %s%s|r",
        spellIcon, iconSizeWidth, iconSizeHeight,
        sourceName, color,
        destName
    )

    HitGrip.customFrame:AddMessage(message)

    if HitGrip.db.profile.isSoundEnabled then
        PlaySound(8959)
    end
end


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
        print("Addon Ativado:", HitGrip.db.profile.isAddonEnabled)
        print("Som Ativado:", HitGrip.db.profile.isSoundEnabled)

    elseif msg == "teste" then
        if not HitGrip.db.profile.isAddonEnabled then  
            print("|cff69CCF0[HitGrip]:|r O addon está desativado! Use /hitgrip enable para ativá-lo.")  
            return  
        end
        HitGrip:RunTest()    


    elseif msg == "sound" then
        if isAddonEnabled then 
            HitGrip.db.profile.isSoundEnabled = not HitGrip.db.profile.isSoundEnabled  -- Alterna entre ativado e desativado
            local status = isSoundEnabled and "ativado" or "desativado"
            print("|cff69CCF0[HitGrip]:|r Som " .. status .. "!")
        else 
            print("|cff69CCF0[HitGrip]:|r O addon está desativado! Use /hitgrip enable para ativá-lo.")  
        end  -- Faltava este `end` para fechar corretamente o `if` dentro do `elseif msg == "sound"`

    elseif msg == "enable" then
        HitGrip:SetAddonEnabled(not HitGrip.db.profile.isAddonEnabled)
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
        return 1, 1, 1, "D3D3D3"
    end
end


-- Função para mensagem inicial
local function Puxao_COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, _, ...)
    if not HitGrip.db.profile.isAddonEnabled then return end -- Se o addon estiver desativado, ignora

    -- Obtém o nome e ícone da habilidade
    local spellName, _, spellIcon = GetSpellInfo(spellID)

    -- Verifica se o evento é a habilidade "Death Grip"
    if eventtype == "SPELL_CAST_SUCCESS" and spellName == "Death Grip" then
        local iconSizeHeight = 28   -- Altura do ícone (retângulo)
        local iconSizeWidth = 24    -- Largura do ícone (retângulo)

        -- Variáveis para a cor do destino
        local classColor = "c0c0c0" -- Cor padrão (cinza)

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
        end

        -- Obtém informações sobre o destino pelo GUID
        local _, classFile = GetPlayerInfoByGUID(dstGUID) -- Pega a classe do destino

        if classFile then
            -- Obtém a cor da classe do destino
            local r, g, b, colorHex = GetClassColor(classFile)
            classColor = colorHex -- Atualiza para a cor real da classe
        end

        -- Evita valores vazios no nome
        srcName = srcName or "Desconhecido"
        dstName = dstName or "Desconhecido"

        local message = ''

        -- Formata a mensagem conforme a facção e situação
        if isFriendly then
            -- Ícone à esquerda se for da minha facção
            message = string.format(
                "|T%s:%d:%d|t %s |cffC41F3B%s |cffC8FFC8usou Death Grip em |cff%s%s",
                spellIcon, iconSizeWidth, iconSizeHeight, sourceAffiliation, srcName, classColor, dstName
            )
        elseif playerGUID == dstGUID then
            -- Se você é o alvo, alerta especial
            message = string.format(
                "|cffFF0000[ALERTA!] %s usou Death Grip em |cffFF0000Você|T%s:%d:%d|t",
                srcName, spellIcon, iconSizeWidth, iconSizeHeight
            )
            if HitGrip.db.profile.isSoundEnabled then PlaySound(11466) end
        else
            -- Ícone à direita se for da facção oposta
            message = string.format(
                "%s |cffC41F3B%s |cffFF7F7Fusou Death Grip em |cff%s%s|r |T%s:%d:%d|t", 
                sourceAffiliation, srcName, classColor, dstName, spellIcon, iconSizeWidth, iconSizeHeight
            )
            if HitGrip.db.profile.isSoundEnabled then PlaySound(11466) end
        end
        
        -- Exibe a mensagem no quadro personalizado
        HitGrip.customFrame:AddMessage(message)
        if HitGrip.db.profile.isSoundEnabled then PlaySound(8959) end
    end
end


-- Função para mensagem inicial
local function handle_PLAYER_ENTERING_WORLD()
    local message = "|cff00ff00[Addon HitGrip]:|r Um addon criado por |cff69CCF0Hitsugai, |rum mage sem damage! Utilize /hitgrip"
    DEFAULT_CHAT_FRAME:AddMessage(message) 
end


frame:SetScript("OnEvent", function(self, event, ...)  
    if not HitGrip.db.profile.isAddonEnabled then return end  -- Sai imediatamente se o addon estiver desativado  

    if event == "PLAYER_ENTERING_WORLD" then  
        handle_PLAYER_ENTERING_WORLD()  
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then  
        Puxao_COMBAT_LOG_EVENT_UNFILTERED(...)  
    end  
end)


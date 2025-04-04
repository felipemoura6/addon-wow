local HitGrip = LibStub("AceAddon-3.0"):GetAddon("HitGrip")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function HitGrip:SetupOptions()
    local options = {
        name = "HitGrip",
        handler = HitGrip,
        type = "group",
        args = {
            geral = {
                type = "group",
                name = "Geral",
                order = 1,
                inline = true,
                args = {
                    enable = {
                        type = "toggle",
                        name = "Ativar addon",
                        desc = "Ativa ou desativa o HitGrip.",
                        get = function() return self.db.profile.isAddonEnabled end,
                        set = function(_, value)
                            self.db.profile.isAddonEnabled = value
                        end,
                    },
                    sound = {
                        type = "toggle",
                        name = "Som",
                        desc = "Liga ou desliga os alertas sonoros.",
                        get = function() return self.db.profile.isSoundEnabled end,
                        set = function(_, value)
                            self.db.profile.isSoundEnabled = value
                        end,
                    },
                },
            },

            teste = {
                type = "group",
                name = "Teste",
                order = 2,
                inline = true,
                args = {
                    test = {
                        type = "execute",
                        name = "Testar alerta",
                        desc = "Exibir uma mensagem de teste.",
                        func = function() HitGrip:RunTest() end,
                        disabled = function() return not self.db.profile.isAddonEnabled or self.db.profile.editMode end,
                    },
                },
            },

            aparencia = {
                type = "group",
                name = "Aparência",
                order = 3,
                inline = true,
                args = {
                    fontSize = {
                        type = "range",
                        name = "Tamanho da Fonte",
                        desc = "Ajuste a altura da fonte usada nas mensagens.",
                        min = 10,
                        max = 40,
                        step = 1,
                        get = function() return self.db.profile.fontSize or 20 end,
                        set = function(_, value)
                            self.db.profile.fontSize = value
                            HitGrip:UpdateFont()
                        end,
                    },

                    editMode = {
                        type = "toggle",
                        name = "Modo de Edição",
                        desc = "Ativa o modo de ajuste da posição da mensagem.",
                        get = function() return self.db.profile.editMode end,
                        set = function(_, value)
                            self.db.profile.editMode = value
                        
                            if self.customFrame then
                                self.customFrame:SetFading(not value) -- Desliga o fade ao ativar o modo de edição
                            end
                        
                            if value then
                                print("|cff69CCF0[HitGrip]:|r Modo de edição ativado. Arraste o texto para ajustar a posição.")
                                if self.customFrame then
                                    self.customFrame:AddMessage("|cffffd100[Modo de Edição]|r Arraste esta mensagem para mover.", 1.0, 1.0, 0.6)
                        
                                    -- Mostrar fundo transparente para ajudar visualmente
                                    if not self.customFrame.bg then
                                        local bg = self.customFrame:CreateTexture(nil, "BACKGROUND")
                                        bg:SetAllPoints(true)
                                        bg:SetColorTexture(1, 1, 0, 0.2) -- amarelo claro
                                        self.customFrame.bg = bg
                                    end
                                    self.customFrame.bg:Show()
                                end
                            else
                                print("|cff69CCF0[HitGrip]:|r Modo de edição desativado.")
                                if self.customFrame and self.customFrame.bg then
                                    self.customFrame.bg:Hide()
                                end
                            end
                        end,                        
                        order = 5,
                    }, 

                    resetPosition = {
                        type = "execute",
                        name = "Restaurar posição",
                        desc = "Restaura a posição do alerta para o local padrão.",
                        func = function()
                            HitGrip:ResetFramePosition()
                            print("|cff69CCF0[HitGrip]:|r Posição restaurada para o padrão.")
                        end,
                        order = 6,
                    },
                                                        
                },
            },
        },
    }

    AceConfig:RegisterOptionsTable("HitGrip", options)
    AceConfigDialog:AddToBlizOptions("HitGrip", "HitGrip")
end


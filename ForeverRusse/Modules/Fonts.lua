local _, A = ...
local fontPath = "Interface\\AddOns\\"..A.name.."\\Media\\DejaVuSans.ttf"

function A:ApplyFont(region, size)
    local _, inheritedSize, flags = region:GetFont()
    if not region:SetFont(fontPath, size or inheritedSize or 12, flags) then
        self.errors.font = "Impossible de charger DejaVu Sans."
    end
end

-- Buttons switch font objects when highlighted or disabled. Keep separate
-- addon-owned objects so the packaged font stays active in every state.
local buttonFonts, buttonFontCount = {}, 0
local function buttonFont(source)
    if not source then return end
    if not buttonFonts[source] then
        buttonFontCount = buttonFontCount + 1
        local font = CreateFont("ForeverRusseButtonFont"..buttonFontCount)
        font:SetFontObject(source)
        A:ApplyFont(font)
        buttonFonts[source] = font
    end
    return buttonFonts[source]
end

function A:ApplyButtonFonts(button)
    local normal = buttonFont(button:GetNormalFontObject())
    local highlight = buttonFont(button:GetHighlightFontObject())
    local disabled = buttonFont(button:GetDisabledFontObject())
    if normal then button:SetNormalFontObject(normal) end
    if highlight then button:SetHighlightFontObject(highlight) end
    if disabled then button:SetDisabledFontObject(disabled) end
end

function A:FontSamples()
    local upper, lower = {}, {}
    for i, letter in ipairs(self.alphabet) do
        upper[i], lower[i] = letter[1], letter[2]
    end
    local stressed = "а́ е́ и́ о́ у́ ы́ э́ ю́ я́ / А́ Е́ И́ О́ У́ Ы́ Э́ Ю́ Я́"
    local phrase = "Приве́т! Я учу́ ру́сский язы́к."
    return table.concat({
        "DejaVu Sans — alphabet russe et français",
        table.concat(upper, " "), table.concat(lower, " "), "",
        "Accents toniques : "..stressed,
        "Français : À Â Ä Æ Ç É È Ê Ë Î Ï Ô Ö Œ Ù Û Ü Ÿ",
        "à â ä æ ç é è ê ë î ï ô ö œ ù û ü ÿ — l’élève, cœur, Noël",
        "", "Russe : "..phrase, "Translittération : "..self:Translit(phrase),
        "Couleurs selon tes options : "..self:Color(phrase),
        "Accent dans la même couleur : |cffffbf69о́|r |cff75d69aя́|r",
    }, "\n")
end

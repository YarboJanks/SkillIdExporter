SkillIdExporter = {}
SkillIdExporter.name = "SkillIdExporter"
SkillIdExporter.saved = nil

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f, g, h, i, j = pcall(fn, ...)
    if ok then return a, b, c, d, e, f, g, h, i, j end
    return nil
end

local function AbilityDetails(abilityId)
    if not abilityId or abilityId == 0 then return nil end
    local name = SafeCall(GetAbilityName, abilityId)
    if not name or name == "" then return nil end
    local minRange, maxRange = SafeCall(GetAbilityRange, abilityId)
    local isChanneled, castTime = SafeCall(GetAbilityCastInfo, abilityId)
    return {
        id = abilityId,
        name = name,
        description = SafeCall(GetAbilityDescription, abilityId) or "",
        icon = SafeCall(GetAbilityIcon, abilityId) or "",
        cost = SafeCall(GetAbilityCost, abilityId) or 0,
        duration = SafeCall(GetAbilityDuration, abilityId) or 0,
        radius = SafeCall(GetAbilityRadius, abilityId) or 0,
        minRange = minRange or 0,
        maxRange = maxRange or 0,
        isPassive = SafeCall(IsAbilityPassive, abilityId) or false,
        isChanneled = isChanneled or false,
        castTime = castTime or 0,
        targetDescription = SafeCall(GetAbilityTargetDescription, abilityId) or "",
        effectDescription = SafeCall(GetAbilityEffectDescription, abilityId) or "",
    }
end

function SkillIdExporter.ExportRawAbilityScan(startId, endId)
    startId = tonumber(startId) or 1
    endId = tonumber(endId) or 250000
    SkillIdExporter.saved.rawAbilities = {}
    local count = 0
    for abilityId = startId, endId do
        local data = AbilityDetails(abilityId)
        if data then
            SkillIdExporter.saved.rawAbilities[abilityId] = data
            count = count + 1
        end
    end
    d(string.format("Raw ability scan exported %d abilities. /reloadui to write to disk.", count))
end

function SkillIdExporter.ExportSkillLines()
    SkillIdExporter.saved.skillLines = {}
    SkillIdExporter.saved.passives = {}
    SkillIdExporter.saved.activeSkills = {}
    SkillIdExporter.saved.exportedAt = GetTimeStamp()
    SkillIdExporter.saved.characterName = GetUnitName("player")
    SkillIdExporter.saved.raceName = GetUnitRace("player")
    SkillIdExporter.saved.className = GetUnitClass("player")

    local totalAbilities = 0
    local totalPassives = 0

    for skillType = 1, GetNumSkillTypes() do
        local skillTypeName = GetString("SI_SKILLTYPE", skillType) or tostring(skillType)
        SkillIdExporter.saved.skillLines[skillType] = {
            skillType = skillType,
            skillTypeName = skillTypeName,
            lines = {},
        }

        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            local lineName, lineRank, discovered, skillLineId, advised, unlockText =
                GetSkillLineInfo(skillType, skillLineIndex)
            local lineData = {
                skillLineIndex = skillLineIndex,
                skillLineId = skillLineId or 0,
                name = lineName or "",
                rank = lineRank or 0,
                discovered = discovered or false,
                advised = advised or false,
                unlockText = unlockText or "",
                abilities = {},
            }

            local numAbilities = GetNumSkillAbilities(skillType, skillLineIndex)
            for abilityIndex = 1, numAbilities do
                local abilityName, texture, earnedRank, passive, ultimate, purchased,
                      progressionIndex, rankIndex, abilityId =
                    GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
                local currentUpgradeLevel = SafeCall(GetSkillAbilityUpgradeInfo, skillType, skillLineIndex, abilityIndex) or 0

                local abilityData = {
                    skillType = skillType,
                    skillTypeName = skillTypeName,
                    skillLineIndex = skillLineIndex,
                    skillLineId = skillLineId or 0,
                    skillLineName = lineName or "",
                    abilityIndex = abilityIndex,
                    abilityId = abilityId or 0,
                    name = abilityName or "",
                    texture = texture or "",
                    earnedRank = earnedRank or 0,
                    passive = passive or false,
                    ultimate = ultimate or false,
                    purchased = purchased or false,
                    progressionIndex = progressionIndex or 0,
                    rankIndex = rankIndex or 0,
                    currentUpgradeLevel = currentUpgradeLevel,
                    details = AbilityDetails(abilityId),
                }

                table.insert(lineData.abilities, abilityData)
                totalAbilities = totalAbilities + 1

                if passive then
                    table.insert(SkillIdExporter.saved.passives, abilityData)
                    totalPassives = totalPassives + 1
                else
                    table.insert(SkillIdExporter.saved.activeSkills, abilityData)
                end
            end

            table.insert(SkillIdExporter.saved.skillLines[skillType].lines, lineData)
        end
    end

    d(string.format(
        "Exported skill lines: %d abilities, %d passives. /reloadui to write SavedVariables.",
        totalAbilities,
        totalPassives
    ))
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= SkillIdExporter.name then return end
    EVENT_MANAGER:UnregisterForEvent(SkillIdExporter.name, EVENT_ADD_ON_LOADED)

    SkillIdExporter.saved = ZO_SavedVars:NewAccountWide(
        "SkillIdExporter_SavedVariables",
        1,
        nil,
        {
            rawAbilities = {},
            skillLines = {},
            passives = {},
            activeSkills = {},
        }
    )

    SLASH_COMMANDS["/exportskills"] = function()
        SkillIdExporter.ExportSkillLines()
    end

    SLASH_COMMANDS["/exportabilities"] = function(args)
        local startId, endId = zo_strsplit(" ", args)
        SkillIdExporter.ExportRawAbilityScan(startId, endId)
    end

    d("SkillIdExporter loaded. Use /exportskills or /exportabilities 1 250000")
end

EVENT_MANAGER:RegisterForEvent(
    SkillIdExporter.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)

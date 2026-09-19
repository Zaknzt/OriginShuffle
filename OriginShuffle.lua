_addon.name = 'OriginShuffle'
_addon.author = 'Zaknzt'
_addon.version = '0.3.1-rc1'
_addon.commands = {'originshuffle', 'oshuffle'}

-- OriginShuffle v0.3.1-rc1
-- PUBLIC CANDIDATE / ANY-WS SAME-FAMILY VISUAL SHUFFLE / NOT YET PUBLISHED
--
-- Local-client cosmetic experiment only.
-- Every supported local-player Weapon Skill in an enabled weapon family may be
-- visually replaced by a different Weapon Skill animation from that SAME family.
--
-- The real server action is never changed. Only the incoming 0x028 per-action
-- animation field is changed locally. No outgoing packets, combat commands,
-- targeting, TP, equipment, inventory, GearSwap, damage, message, or skillchain
-- fields are modified.
--
-- Weapon-family identity is resolved from current Windower Resources using the
-- real Weapon Skill ID (top-level action param). If the WS/family is unknown,
-- disabled, malformed, or already modified by another listener, do nothing.

require('actions')
local res = require('resources')

local UINT32 = 4294967296

local FAMILY_BY_SKILL = {
    [1]  = {key='h2h',          name='Hand-to-Hand'},
    [2]  = {key='dagger',       name='Dagger'},
    [3]  = {key='sword',        name='Sword'},
    [4]  = {key='greatsword',   name='Great Sword'},
    [5]  = {key='axe',          name='Axe'},
    [6]  = {key='greataxe',     name='Great Axe'},
    [7]  = {key='scythe',       name='Scythe'},
    [8]  = {key='polearm',      name='Polearm'},
    [9]  = {key='katana',       name='Katana'},
    [10] = {key='greatkatana',  name='Great Katana'},
    [11] = {key='club',         name='Club'},
    [12] = {key='staff',        name='Staff'},
    [25] = {key='archery',      name='Archery'},
    [26] = {key='marksmanship', name='Marksmanship'},
}

local ALIASES = {
    ['h2h']=1, ['handtohand']=1, ['hand-to-hand']=1, ['hand_to_hand']=1,
    ['dagger']=2,
    ['sword']=3,
    ['greatsword']=4, ['gs']=4, ['great-sword']=4, ['great_sword']=4,
    ['axe']=5,
    ['greataxe']=6, ['ga']=6, ['great-axe']=6, ['great_axe']=6,
    ['scythe']=7,
    ['polearm']=8, ['spear']=8,
    ['katana']=9,
    ['greatkatana']=10, ['gkt']=10, ['gk']=10, ['great-katana']=10, ['great_katana']=10,
    ['club']=11,
    ['staff']=12,
    ['archery']=25, ['bow']=25,
    ['marksmanship']=26, ['gun']=26, ['ranged']=26,
}

-- Vetted same-family visual pools. These are CLIENT ANIMATION IDs, not WS IDs.
-- Prime WS animations are intentionally not needed in the pool: Prime and normal
-- WSs alike can trigger the shuffle, while the replacement is selected from these
-- established same-family animations.
local VISUAL_POOLS = {
    [1] = {
        {name='Combo',animation=16}, {name='Shoulder Tackle',animation=17},
        {name='One Inch Punch',animation=18}, {name='Backhand Blow',animation=19},
        {name='Raging Fists',animation=20}, {name='Spinning Attack',animation=21},
        {name='Howling Fist',animation=22}, {name='Dragon Kick',animation=23},
        {name='Asuran Fists',animation=24}, {name='Final Heaven',animation=25},
        {name="Ascetic's Fury",animation=26}, {name='Stringing Pummel',animation=27},
        {name='Tornado Kick',animation=28}, {name='Victory Smite',animation=29},
        {name='Shijin Spiral',animation=30},
    },
    [2] = {
        {name='Wasp Sting',animation=31}, {name='Viper Bite',animation=32},
        {name='Shadowstitch',animation=33}, {name='Gust Slash',animation=34},
        {name='Cyclone',animation=35}, {name='Energy Steal',animation=36},
        {name='Energy Drain',animation=37}, {name='Dancing Edge',animation=38},
        {name='Shark Bite',animation=39}, {name='Evisceration',animation=40},
        {name='Mercy Stroke',animation=41}, {name='Mandalic Stab',animation=42},
        {name='Mordant Rime',animation=43}, {name='Pyrrhic Kleos',animation=44},
        {name='Aeolian Edge',animation=45}, {name="Rudra's Storm",animation=236},
        {name='Exenterator',animation=238},
    },
    [3] = {
        {name='Fast Blade',animation=1}, {name='Burning Blade',animation=2},
        {name='Red Lotus Blade',animation=3}, {name='Shining Blade',animation=4},
        {name='Seraph Blade',animation=5}, {name='Flat Blade',animation=6},
        {name='Circle Blade',animation=7}, {name='Spirits Within',animation=8},
        {name='Vorpal Blade',animation=9}, {name='Swift Blade',animation=10},
        {name='Savage Blade',animation=11}, {name='Knights of Round',animation=12},
        {name='Death Blossom',animation=13}, {name='Atonement',animation=14},
        {name='Expiacion',animation=15}, {name='Sanguine Blade',animation=230},
        {name='Chant du Cygne',animation=233}, {name='Requiescat',animation=237},
    },
    [4] = {
        {name='Hard Slash',animation=106}, {name='Power Slash',animation=107},
        {name='Frostbite',animation=108}, {name='Freezebite',animation=109},
        {name='Shockwave',animation=110}, {name='Crescent Moon',animation=111},
        {name='Sickle Moon',animation=112}, {name='Spinning Slash',animation=113},
        {name='Ground Strike',animation=114}, {name='Scourge',animation=115},
        {name='Herculean Slash',animation=116}, {name='Torcleaver',animation=117},
        {name='Resolution',animation=118}, {name='Dimidiation',animation=119},
    },
    [5] = {
        {name='Raging Axe',animation=46}, {name='Smash Axe',animation=47},
        {name='Gale Axe',animation=48}, {name='Avalanche Axe',animation=49},
        {name='Spinning Axe',animation=50}, {name='Rampage',animation=51},
        {name='Calamity',animation=52}, {name='Mistral Axe',animation=53},
        {name='Decimation',animation=54}, {name='Onslaught',animation=55},
        {name='Primal Rend',animation=56}, {name='Bora Axe',animation=57},
        {name='Cloudsplitter',animation=58}, {name='Ruinator',animation=59},
    },
    [6] = {
        {name='Shield Break',animation=91}, {name='Iron Tempest',animation=92},
        {name='Sturmwind',animation=93}, {name='Armor Break',animation=94},
        {name='Keen Edge',animation=95}, {name='Weapon Break',animation=96},
        {name='Raging Rush',animation=97}, {name='Full Break',animation=98},
        {name='Steel Cyclone',animation=99}, {name='Metatron Torment',animation=100},
        {name="King's Justice",animation=101}, {name='Fell Cleave',animation=102},
        {name="Ukko's Fury",animation=103}, {name='Upheaval',animation=104},
    },
    [7] = {
        {name='Slice',animation=61}, {name='Dark Harvest',animation=62},
        {name='Shadow of Death',animation=63}, {name='Nightmare Scythe',animation=64},
        {name='Spinning Scythe',animation=65}, {name='Vorpal Scythe',animation=66},
        {name='Guillotine',animation=67}, {name='Cross Reaper',animation=68},
        {name='Spiral Hell',animation=69}, {name='Catastrophe',animation=70},
        {name='Insurgency',animation=71}, {name='Infernal Scythe',animation=72},
        {name='Quietus',animation=73}, {name='Entropy',animation=74},
    },
    [8] = {
        {name='Double Thrust',animation=121}, {name='Thunder Thrust',animation=122},
        {name='Raiden Thrust',animation=123}, {name='Leg Sweep',animation=124},
        {name='Penta Thrust',animation=125}, {name='Vorpal Thrust',animation=126},
        {name='Skewer',animation=127}, {name='Wheeling Thrust',animation=128},
        {name='Impulse Drive',animation=129}, {name='Geirskogul',animation=130},
        {name='Drakesbane',animation=131}, {name='Sonic Thrust',animation=132},
        {name="Camlann's Torment",animation=133}, {name='Stardiver',animation=134},
    },
    [9] = {
        {name='Blade: Rin',animation=151}, {name='Blade: Retsu',animation=152},
        {name='Blade: Teki',animation=153}, {name='Blade: To',animation=154},
        {name='Blade: Chi',animation=155}, {name='Blade: Ei',animation=156},
        {name='Blade: Jin',animation=157}, {name='Blade: Ten',animation=158},
        {name='Blade: Ku',animation=159}, {name='Blade: Metsu',animation=160},
        {name='Blade: Kamu',animation=161}, {name='Blade: Yu',animation=162},
        {name='Blade: Hi',animation=163}, {name='Blade: Shun',animation=164},
    },
    [10] = {
        {name='Tachi: Enpi',animation=166}, {name='Tachi: Hobaku',animation=167},
        {name='Tachi: Goten',animation=168}, {name='Tachi: Kagero',animation=169},
        {name='Tachi: Jinpu',animation=170}, {name='Tachi: Koki',animation=171},
        {name='Tachi: Yukikaze',animation=172}, {name='Tachi: Gekko',animation=173},
        {name='Tachi: Kasha',animation=174}, {name='Tachi: Kaiten',animation=175},
        {name='Tachi: Rana',animation=176}, {name='Tachi: Ageha',animation=177},
        {name='Tachi: Fudo',animation=178}, {name='Tachi: Shoha',animation=179},
    },
    [11] = {
        {name='Shining Strike',animation=76}, {name='Seraph Strike',animation=77},
        {name='Brainshaker',animation=78}, {name='Starlight',animation=79},
        {name='Moonlight',animation=80}, {name='Skullbreaker',animation=81},
        {name='True Strike',animation=82}, {name='Judgment',animation=83},
        {name='Hexa Strike',animation=84}, {name='Black Halo',animation=85},
        {name='Randgrith',animation=86}, {name='Mystic Boon',animation=87},
        {name='Flash Nova',animation=88}, {name='Dagan',animation=89},
        {name='Realmrazer',animation=90},
    },
    [12] = {
        {name='Heavy Swing',animation=136}, {name='Rock Crusher',animation=137},
        {name='Earth Crusher',animation=138}, {name='Starburst',animation=139},
        {name='Sunburst',animation=140}, {name='Shell Crusher',animation=141},
        {name='Full Swing',animation=142}, {name='Spirit Taker',animation=143},
        {name='Retribution',animation=144}, {name='Gate of Tartarus',animation=145},
        {name='Vidohunir',animation=146}, {name='Garland of Bliss',animation=147},
        {name='Omniscience',animation=148}, {name='Myrkr',animation=150},
        {name='Cataclysm',animation=231}, {name='Shattersoul',animation=239},
    },
    [25] = {
        {name='Flaming Arrow',animation=191}, {name='Piercing Arrow',animation=192},
        {name='Dulling Arrow',animation=193}, {name='Sidewinder',animation=195},
        {name='Blast Arrow',animation=219}, {name='Arching Arrow',animation=220},
        {name='Empyreal Arrow',animation=221}, {name='Namas Arrow',animation=225},
        {name='Refulgent Arrow',animation=232}, {name="Jishnu's Radiance",animation=234},
        {name='Apex Arrow',animation=240},
    },
    [26] = {
        {name='Hot Shot',animation=196}, {name='Split Shot',animation=197},
        {name='Sniper Shot',animation=198}, {name='Slug Shot',animation=200},
        {name='Blast Shot',animation=222}, {name='Heavy Shot',animation=223},
        {name='Detonator',animation=224}, {name='Coronach',animation=226},
        {name='Trueflight',animation=227}, {name='Leaden Salute',animation=228},
        {name='Numbing Shot',animation=229}, {name='Wildfire',animation=235},
        {name='Last Stand',animation=241},
    },
}

local enabled = {}
local listener_id = nil
local substitutions_total = 0
local substitutions_by_skill = {}
local last_visual_by_skill = {}
local last_real_ws_by_skill = {}
local rng_state = nil

for skill_id in pairs(FAMILY_BY_SKILL) do
    enabled[skill_id] = false
    substitutions_by_skill[skill_id] = 0
end

local function chat(color, message)
    windower.add_to_chat(color or 207, '[OriginShuffle] '..tostring(message))
end

local function normalize_token(value)
    return tostring(value or ''):lower():gsub('%s+', '')
end

local function local_player_id()
    local player = windower.ffxi.get_player()
    if type(player) ~= 'table' then return nil end
    local id = tonumber(player.id)
    if not id or id <= 0 then return nil end
    return id
end

local function seed_rng(player_id)
    if rng_state ~= nil then return end
    local now = tonumber(os.time()) or 1
    local pid = tonumber(player_id) or 0
    local clock = tonumber(os.clock()) or 0
    local clock_part = math.floor((clock * 1000000) % UINT32)
    rng_state = (now + (pid * 2654435761) + clock_part) % UINT32
    if rng_state == 0 then rng_state = 0x6D2B79F5 end
end

local function next_random_u32(player_id)
    seed_rng(player_id)
    rng_state = (1664525 * rng_state + 1013904223) % UINT32
    return rng_state
end

local function resource_ws(ws_id)
    if not res or type(res.weapon_skills) ~= 'table' then return nil end
    local ws = res.weapon_skills[tonumber(ws_id)]
    if type(ws) ~= 'table' then return nil end
    return ws
end

local function resolve_family_from_ws(ws_id)
    local ws = resource_ws(ws_id)
    if not ws then return nil, nil end
    local skill_id = tonumber(ws.skill)
    if not skill_id or not FAMILY_BY_SKILL[skill_id] or not VISUAL_POOLS[skill_id] then return nil, ws end
    return skill_id, ws
end

local function resolve_family_token(token)
    token = normalize_token(token)
    return ALIASES[token]
end

local function collect_original_animations(original)
    local blocked = {}
    local target_count = tonumber(original.target_count)
    if not target_count then return nil end
    for i = 1, target_count do
        local target = original.targets[i]
        local action_count = target and tonumber(target.action_count)
        if not action_count then return nil end
        for n = 1, action_count do
            local action = target.actions and target.actions[n]
            local animation = action and tonumber(action.animation)
            if animation == nil then return nil end
            blocked[animation] = true
        end
    end
    return blocked
end

local function choose_visual(skill_id, blocked_animations, player_id)
    local pool = VISUAL_POOLS[skill_id]
    if type(pool) ~= 'table' or #pool < 1 then return nil end
    blocked_animations = blocked_animations or {}

    local candidates = {}
    local last = last_visual_by_skill[skill_id]
    for _, visual in ipairs(pool) do
        if not blocked_animations[visual.animation] and (not last or visual.animation ~= last.animation) then
            candidates[#candidates+1] = visual
        end
    end

    -- If the only extra restriction preventing a choice was the prior replacement,
    -- relax that rule but NEVER relax the "do not visually replay the real WS" rule.
    if #candidates == 0 then
        for _, visual in ipairs(pool) do
            if not blocked_animations[visual.animation] then
                candidates[#candidates+1] = visual
            end
        end
    end

    if #candidates == 0 then return nil end
    local index = (next_random_u32(player_id) % #candidates) + 1
    local visual = candidates[index]
    last_visual_by_skill[skill_id] = visual
    return visual
end

local function validate_ws_action(original, modified, player_id)
    if type(original) ~= 'table' or type(modified) ~= 'table' then return nil end
    if not player_id or tonumber(player_id) == nil then return nil end
    if tonumber(original.actor_id) ~= tonumber(player_id) then return nil end
    if tonumber(original.category) ~= 3 then return nil end

    local ws_id = tonumber(original.param)
    if not ws_id then return nil end
    local skill_id, ws = resolve_family_from_ws(ws_id)
    if not skill_id or not enabled[skill_id] then return nil end

    -- Identity/shape must still match the original server action. Fail closed if a
    -- prior listener has changed identity or animation before OriginShuffle sees it.
    if tonumber(modified.actor_id) ~= tonumber(original.actor_id) then return nil end
    if tonumber(modified.category) ~= tonumber(original.category) then return nil end
    if tonumber(modified.param) ~= ws_id then return nil end
    if tonumber(modified.target_count) ~= tonumber(original.target_count) then return nil end

    local target_count = tonumber(original.target_count)
    if not target_count or target_count < 1 or target_count ~= math.floor(target_count) then return nil end
    if type(original.targets) ~= 'table' or type(modified.targets) ~= 'table' then return nil end

    for i = 1, target_count do
        local ot, mt = original.targets[i], modified.targets[i]
        if type(ot) ~= 'table' or type(mt) ~= 'table' then return nil end
        if tonumber(ot.id) == nil or tonumber(mt.id) ~= tonumber(ot.id) then return nil end
        if tonumber(ot.action_count) == nil or tonumber(mt.action_count) ~= tonumber(ot.action_count) then return nil end
        local action_count = tonumber(ot.action_count)
        if action_count < 1 or action_count ~= math.floor(action_count) then return nil end
        if type(ot.actions) ~= 'table' or type(mt.actions) ~= 'table' then return nil end
        for n = 1, action_count do
            local oa, ma = ot.actions[n], mt.actions[n]
            if type(oa) ~= 'table' or type(ma) ~= 'table' then return nil end
            if tonumber(oa.animation) == nil or tonumber(ma.animation) == nil then return nil end
            if tonumber(ma.animation) ~= tonumber(oa.animation) then return nil end
        end
    end

    return {skill_id=skill_id, ws_id=ws_id, ws=ws}
end

local function apply_visual(original, modified, context, visual)
    if type(context) ~= 'table' or type(visual) ~= 'table' or tonumber(visual.animation) == nil then return nil end
    local target_count = tonumber(original.target_count)
    if not target_count then return nil end
    local animation = tonumber(visual.animation)
    for i = 1, target_count do
        local action_count = tonumber(original.targets[i].action_count)
        for n = 1, action_count do
            modified.targets[i].actions[n].animation = animation
        end
    end
    return modified
end

local function action_listener(original, modified)
    local player_id = local_player_id()
    if not player_id then return nil end

    local context = validate_ws_action(original, modified, player_id)
    if not context then return nil end

    local blocked = collect_original_animations(original)
    if not blocked then return nil end
    local visual = choose_visual(context.skill_id, blocked, player_id)
    if not visual then return nil end

    local transformed = apply_visual(original, modified, context, visual)
    if transformed then
        substitutions_total = substitutions_total + 1
        substitutions_by_skill[context.skill_id] = (substitutions_by_skill[context.skill_id] or 0) + 1
        last_real_ws_by_skill[context.skill_id] = context.ws and context.ws.en or ('WS ID '..context.ws_id)
    end
    return transformed
end

local function set_family(skill_id, value, quiet)
    if not FAMILY_BY_SKILL[skill_id] then return false end
    enabled[skill_id] = value and true or false
    if not quiet then
        chat(158, ('%s: %s'):format(FAMILY_BY_SKILL[skill_id].name, enabled[skill_id] and 'ON' or 'OFF'))
    end
    return true
end

local function set_all(value)
    for skill_id in pairs(FAMILY_BY_SKILL) do set_family(skill_id, value, true) end
    chat(158, 'All supported weapon families: '..(value and 'ON' or 'OFF'))
end

local function visual_pool_text(skill_id)
    local pool = VISUAL_POOLS[skill_id] or {}
    local names = {}
    for i, visual in ipairs(pool) do names[i] = visual.name end
    return table.concat(names, ', ')
end

local function print_family_status(skill_id)
    local family = FAMILY_BY_SKILL[skill_id]
    if not family then return end
    local pool = VISUAL_POOLS[skill_id] or {}
    local last = last_visual_by_skill[skill_id]
    local real = last_real_ws_by_skill[skill_id]
    chat(207, ('%-13s %s | pool %d | last: %s%s'):format(
        family.name,
        enabled[skill_id] and 'ON ' or 'OFF',
        #pool,
        last and last.name or 'none',
        real and (' <- '..real) or ''))
end

local ORDERED_SKILLS = {1,2,3,4,5,6,7,8,9,10,11,12,25,26}

local function print_status(skill_id)
    chat(207, ('OriginShuffle v%s | same-family ANY-WS visual shuffle'):format(_addon.version))
    if skill_id then
        print_family_status(skill_id)
    else
        for _, id in ipairs(ORDERED_SKILLS) do print_family_status(id) end
        chat(207, 'Substitutions this load: '..substitutions_total)
    end
end

local function print_pool(skill_id)
    local family = FAMILY_BY_SKILL[skill_id]
    if not family then return end
    local pool = VISUAL_POOLS[skill_id] or {}
    chat(207, ('%s visual pool (%d): %s'):format(family.name, #pool, visual_pool_text(skill_id)))
end

local function tokenize(...)
    local raw = {...}
    local out = {}
    for _, value in ipairs(raw) do
        for token in tostring(value or ''):gmatch('%S+') do out[#out+1] = token end
    end
    return out
end

local function print_help()
    chat(207, 'Commands: //originshuffle <weapon> on | off | status')
    chat(207, '          //originshuffle all on | off')
    chat(207, '          //originshuffle pool <weapon>')
    chat(207, '          //originshuffle status')
    chat(207, 'Examples: //originshuffle sword on | //originshuffle scythe on | //originshuffle all off')
    chat(207, 'Legacy:   //originshuffle on/off toggles Scythe only')
end

listener_id = ActionPacket.open_listener(action_listener)

windower.register_event('addon command', function(...)
    local args = tokenize(...)
    local a1 = normalize_token(args[1])
    local a2 = normalize_token(args[2])

    if a1 == '' or a1 == 'status' then
        print_status()
        return
    end

    if a1 == 'help' then
        print_help()
        return
    end

    -- Backward-compatible v0.1/v0.2 command: bare on/off controls Scythe.
    if a1 == 'on' or a1 == 'off' then
        set_family(7, a1 == 'on')
        return
    end

    if a1 == 'all' and (a2 == 'on' or a2 == 'off') then
        set_all(a2 == 'on')
        return
    end

    if a1 == 'pool' then
        local skill_id = resolve_family_token(args[2])
        if skill_id then print_pool(skill_id) else print_help() end
        return
    end

    local skill_id = resolve_family_token(args[1])
    if skill_id then
        if a2 == 'on' or a2 == 'off' then
            set_family(skill_id, a2 == 'on')
        elseif a2 == 'status' or a2 == '' then
            print_status(skill_id)
        elseif a2 == 'pool' then
            print_pool(skill_id)
        else
            print_help()
        end
        return
    end

    print_help()
end)

windower.register_event('load', function()
    if listener_id then
        chat(158, ('v%s loaded with all weapon families OFF. Use //originshuffle <weapon> on'):format(_addon.version))
    else
        chat(167, 'ERROR: action listener was not created. Addon is fail-closed.')
    end
end)

windower.register_event('unload', function()
    for skill_id in pairs(enabled) do enabled[skill_id] = false end
    if listener_id then
        ActionPacket.close_listener(listener_id)
        listener_id = nil
    end
end)

-- Test-only export. Normal Windower runtime does not create this table.
if rawget(_G, 'ORIGINSHUFFLE_TEST_MODE') then
    _G.OriginShuffle_Test = {
        resolve_family_from_ws = resolve_family_from_ws,
        resolve_family_token = resolve_family_token,
        collect_original_animations = collect_original_animations,
        validate_ws_action = validate_ws_action,
        apply_visual = apply_visual,
        choose_visual = choose_visual,
        set_family = set_family,
        set_all = set_all,
        get_enabled = function(skill_id) return enabled[skill_id] end,
        get_listener_id = function() return listener_id end,
        get_last_visual = function(skill_id) return last_visual_by_skill[skill_id] end,
        set_rng_state = function(v)
            rng_state = tonumber(v)
            last_visual_by_skill = {}
            last_real_ws_by_skill = {}
        end,
        constants = {
            family_by_skill = FAMILY_BY_SKILL,
            aliases = ALIASES,
            visual_pools = VISUAL_POOLS,
        },
    }
end

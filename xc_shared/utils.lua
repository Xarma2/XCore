XCoreUtils = {}

function XCoreUtils.FormatMoney(amount)
    amount = math.floor(amount or 0)
    local formatted = tostring(amount):reverse():gsub("(%d%d%d)", "%1.")
    formatted = formatted:reverse():gsub("^%.", "")
    if XCoreConfig.Currency.prefix then
        return XCoreConfig.Currency.symbol .. ' ' .. formatted
    else
        return formatted .. ' ' .. XCoreConfig.Currency.symbol
    end
end

function XCoreUtils.GeneratePlate()
    local chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
    local nums  = '0123456789'
    local function rc(s) return s:sub(math.random(1, #s), math.random(1, #s)) end
    return rc(chars)..rc(chars)..' '..rc(nums)..rc(nums)..rc(nums)..' '..rc(chars)..rc(chars)
end

function XCoreUtils.IsJSON(str)
    if type(str) ~= 'string' then return false, nil end
    local ok, result = pcall(json.decode, str)
    return ok, result
end

function XCoreUtils.SafeDecode(str)
    if not str or str == '' or str == 'null' then return nil end
    local ok, result = pcall(json.decode, str)
    return ok and result or nil
end

function XCoreUtils.Distance(v1, v2)
    return #(v1 - v2)
end

function XCoreUtils.Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

function XCoreUtils.Capitalize(str)
    if not str or str == '' then return '' end
    return str:sub(1,1):upper() .. str:sub(2):lower()
end

function XCoreUtils.IsNearCoords(coords, maxDist)
    if IsDuplicityVersion() then return false end
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    return XCoreUtils.Distance(pos, coords) <= maxDist
end

function XCoreUtils.Log(module, msg, level)
    level = level or 'info'
    local prefix = ('[XCore][%s]'):format(module:upper())
    if level == 'error' then
        print('^1' .. prefix .. ' ERROR: ' .. msg .. '^0')
    elseif level == 'warn' then
        print('^3' .. prefix .. ' WARN: ' .. msg .. '^0')
    else
        print('^4' .. prefix .. '^0 ' .. msg)
    end
end

function XCoreUtils.GeneratePhone()
    return ('3%02d%07d'):format(math.random(0,99), math.random(0,9999999))
end

function XCoreUtils.TableContains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

function XCoreUtils.DeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[XCoreUtils.DeepCopy(k)] = XCoreUtils.DeepCopy(v)
        end
        setmetatable(copy, XCoreUtils.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

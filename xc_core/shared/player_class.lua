XCorePlayer = {}
XCorePlayer.__index = XCorePlayer

function XCorePlayer.New(data, source)
    local self = setmetatable({}, XCorePlayer)

    self.source     = source
    self.identifier = data.identifier
    self.charId     = data.char_id
    self.slot       = data.slot or 1

    self.name = {
        first   = data.firstname or 'Sconosciuto',
        last    = data.lastname  or 'Sconosciuto',
        full    = (data.firstname or 'Sconosciuto') .. ' ' .. (data.lastname or 'Sconosciuto'),
    }

    self.dob         = data.dob
    self.gender      = data.gender or 0
    self.nationality = data.nationality or 'Italiana'
    self.phone       = data.phone

    self.job = {
        name  = data.job       or 'unemployed',
        grade = data.job_grade or 0,
        label = data.job_label or 'Disoccupato',
        gradeLabel = data.job_grade_label or 'Disoccupato',
        salary     = data.job_salary or 0,
        isBoss     = data.job_is_boss == 1 or false,
    }

    self.job2 = {
        name  = data.job2       or nil,
        grade = data.job2_grade or 0,
    }

    self.gang = {
        name  = data.gang       or 'none',
        grade = data.gang_grade or 0,
        label = data.gang_label or 'Nessuna',
        isBoss = data.gang_is_boss == 1 or false,
    }

    self.money = {
        cash        = data.cash        or 0,
        bank        = data.bank        or 0,
        black_money = data.black_money or 0,
    }

    self.position = XCoreUtils.SafeDecode(data.position) or XCoreConfig.DefaultSpawn
    self.metadata = XCoreUtils.SafeDecode(data.metadata) or {}
    self.status   = XCoreUtils.SafeDecode(data.status)   or XCoreUtils.DeepCopy(XCoreConfig.DefaultStatus)
    self.skin     = XCoreUtils.SafeDecode(data.skin)     or {}
    self.isDead   = data.is_dead == 1 or false

    self.group    = data.group or 'user'

    return self
end

function XCorePlayer:GetName()
    return self.name.full
end

function XCorePlayer:HasPermission(perm)
    local perms = XCoreConfig.Permissions[self.group]
    if not perms then return false end
    return perms[perm] == true
end

function XCorePlayer:IsAdmin()
    return XCoreUtils.TableContains(XCoreConfig.AdminGroups, self.group)
end

function XCorePlayer:GetMetadata(key)
    return self.metadata[key]
end

function XCorePlayer:SetMetadata(key, value)
    self.metadata[key] = value
end

function XCorePlayer:GetStatus(key)
    return self.status[key] or 0
end

function XCorePlayer:SetStatus(key, value)
    self.status[key] = XCoreUtils.Clamp(value, 0, 100)
end

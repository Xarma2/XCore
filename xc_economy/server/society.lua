AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `xcore_societies` (
            `name`    VARCHAR(50) NOT NULL,
            `label`   VARCHAR(100) NOT NULL,
            `balance` INT(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end)

exports('GetSocietyMoney', function(name)
    local row = exports.oxmysql:executeSync(
        'SELECT balance FROM xcore_societies WHERE name = ? LIMIT 1', { name }
    )
    return row and row[1] and row[1].balance or 0
end)

exports('AddSocietyMoney', function(name, amount)
    exports.oxmysql:execute(
        'INSERT INTO xcore_societies (name, label, balance) VALUES (?,?,?) ON DUPLICATE KEY UPDATE balance=balance+?',
        { name, name, amount, amount }
    )
end)

exports('RemoveSocietyMoney', function(name, amount)
    local balance = exports['xc_economy']:GetSocietyMoney(name)
    if balance < amount then return false end
    exports.oxmysql:execute(
        'UPDATE xcore_societies SET balance=balance-? WHERE name=?', { amount, name }
    )
    return true
end)

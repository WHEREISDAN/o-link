-- Default banking fallback.
-- Loads when no dedicated banking resource is running.

if not olink._guardImpl('Banking', '_default', false) then return end
if not olink._hasOverride('Banking') and GetResourceState('fd_banking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('kartik-banking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('okokBanking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('oxide-banking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('qb-banking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('Renewed-Banking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('renewed-banking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('tgg-banking') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('tgiann-bank') == 'started' then return end
if not olink._hasOverride('Banking') and GetResourceState('wasabi_banking') == 'started' then return end

olink._registerDefault('banking', olink._buildStub('banking', {
    'GetManagmentName',
    'GetAccountMoney',
    'AddAccountMoney',
    'RemoveAccountMoney',
}, {
    GetManagmentName = '_default',
    GetAccountMoney = 0,
    AddAccountMoney = false,
    RemoveAccountMoney = false,
}))

olink._registerDefault('banking', {
    GetResourceName = function() return '_default' end,
})

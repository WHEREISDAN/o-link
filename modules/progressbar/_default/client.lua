-- Default progressbar fallback.
-- Stub: logs a warning when no supported progress bar resource is running.

if not olink._guardImpl('ProgressBar', '_default', false) then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('esx_progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('keep-progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('lation_ui') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('ox_lib') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('oxide-progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('qb-progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('wasabi_uikit') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('ZSX_UIV2') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('zsxui') == 'started' then return end

olink._registerDefault('progressbar', olink._buildStub('progressbar', {
    'Open',
}, {
    Open = true,
}))

olink._registerDefault('progressbar', {
    GetResourceName = function() return '_default' end,
})

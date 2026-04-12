if GetResourceState('doors_creator') == 'missing' then return end

olink._register('doorlock', {
    ---@return string | nil
    GetClosestDoor = function()
        return exports["doors_creator"]:getClosestActiveDoor()
    end,

    ---@return string
    GetResourceName = function()
        return 'doors_creator'
    end,
})

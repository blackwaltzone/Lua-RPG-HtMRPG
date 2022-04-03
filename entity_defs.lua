-- WaitState, MoveState must already be loaded
assert(WaitState)
assert(MoveState)

-- Text ID -> controller state
gCharacterStates =
{
    wait = WaitState,
    move = MoveState,
    npc_stand = NPCStandState,
    plain_stroll = PlainStrollState,
}

gEntities =
{
    hero =
    {
        --texture     = "dantek.png",
        texture   = "walk_cycle.png",
        width     = 16,
        height        = 24,
        --width       = 32,
        --height      = 48,
        startFrame = 9,
        --startFrame  = 1,
        tileX       = 4,
        tileY       = 1,
        layer       = 1,
    },
    npc =
    {
        texture     = "walk_cycle.png",
        width       = 16,
        height      = 24,
        startFrame  = 73,
        tileX       = 3,
        tileY       = 9,
        layer       = 1
    }
}

gCharacters =
{
    strolling_npc =
    {
        entity = "npc",
        anims =
        {
            --up    = {1,2,3,4},
            --right = {5,6,7,8},
            --down  = {9,10,11,12},
            --left  = {13,14,15,16},
            up      = {65,66,67,68},
            right   = {69,70,71,72},
            down    = {73,74,75,76},
            left    = {77,78,79,80}
        },
        facing = "down",
        controller = {"plain_stroll","move"},
        state = "plain_stroll"
    },
    standing_npc =
    {
        entity = "npc",
        anims = {},
        facing = "down",
        controller = {"npc_stand"},
        state = "npc_stand"
    },
    hero =
    {
        entity = "hero",
        anims =
        {
            up = {1,2,3,4},
            right = {5,6,7,8},
            down = {9,10,11,12},
            left = {13,14,15,16},
            --up = {13,14,15,16},
            --right = {9,10,11,12},
            --down = {1,2,3,4},
            --left = {5,6,7,8},
        },
        facing = "down",
        controller = {"wait","move"},
        state = "wait"
    },
}

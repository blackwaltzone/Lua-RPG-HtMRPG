Actions =
{
    -- Teleport an entity from the current position to the given position
    Teleport = function(map, tileX, tileY)--, layer)
        layer = layer or 1
        return function(trigger, entity)
            entity:SetTilePos(tileX, tileY, layer, map)
        end
    end,

    --
    -- Note this should be used by the Quest manager!
    --
    AddNPC = function(map, npc)
        return function(trigger, entity)

            local charDef = gCharacters[npc.def]
            assert(charDef) -- Character should always exist!
            local char = Character:Create(charDef, map)

            -- Use npc def location by default
            -- Drop back to entities locations if missing
            local x = npc.x or char.mEntity.mTileX
            local y = npc.y or char.mEntity.mTileY
            local layer = npc.layer or char.mEntity.mLayer

            char.mEntity:SetTilePos(x, y, layer, map)

            table.insert(map.mNPCs, char)
        end
    end
}

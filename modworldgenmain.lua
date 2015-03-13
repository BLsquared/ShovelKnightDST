local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")
 
Layouts["sktiletroupplepondsetpiece"] = StaticLayout.Get("map/static_layouts/sktiletroupplepondsetpiece")

--AddRoomPreInit("Forest", function(room)
    --if not room.contents.countstaticlayouts then
        --room.contents.countstaticlayouts = {}
    --end
    --room.contents.countstaticlayouts["ResearchLab"] = 1
--end)

AddSetPiecePreInitAny = function(name, count, tasks)
 
    AddLevelPreInitAny(function(level)
        if not level.set_pieces then
            level.set_pieces = {}
        end
 
        level.set_pieces[name] = { count = count, tasks = tasks }
    end)
end 

local tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters" }

AddSetPiecePreInitAny("sktiletroupplepondsetpiece", 1, tasks)
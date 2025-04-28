-- Charming Discussion, A pleasant discussion between two civilized people on the game Garry's Mod.
-- Copyright (C) 2025  MrMarrant.

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

--[[
* Allows you to load all the name paths in a table.
* @string folderRoot The main path of the directory to load.
* @string directory The full path where the files are located.
* @string path The path to look for the files and directories in. (default: "LUA")
* @table tableAssets The table where the path of the files will be stored.
--]]
local function LoadAssets( folderRoot, directory, path, tableAssets )
    path = path or "GAME"
    folderRoot = folderRoot .. "/"
    local files = file.Find( folderRoot .. directory .. "*", path )
    for k, v in ipairs( files ) do
        table.insert( tableAssets, k, directory .. v )
    end
end

-- Net Var
CHARMING_DISCUSSION_CONFIG.NetVar = {}
CHARMING_DISCUSSION_CONFIG.NetVar.ScreamerHonk = "CHARMING_DISCUSSION_CONFIG.NetVar.ScreamerHonk"

-- Sound Path
CHARMING_DISCUSSION_CONFIG.Sounds = {}
CHARMING_DISCUSSION_CONFIG.Sounds.BadLanguage = {}
LoadAssets( "sound", "charming_discussion/bad_language/", "GAME", CHARMING_DISCUSSION_CONFIG.Sounds.BadLanguage )

CHARMING_DISCUSSION_CONFIG.Sounds.Response = {}
LoadAssets( "sound", "charming_discussion/response/", "GAME", CHARMING_DISCUSSION_CONFIG.Sounds.Response )

CHARMING_DISCUSSION_CONFIG.Sounds.Ouink = {}
LoadAssets( "sound", "charming_discussion/ouink/", "GAME", CHARMING_DISCUSSION_CONFIG.Sounds.Ouink )

CHARMING_DISCUSSION_CONFIG.Sounds.Special = {}
LoadAssets( "sound", "charming_discussion/special/", "GAME", CHARMING_DISCUSSION_CONFIG.Sounds.Special )

CHARMING_DISCUSSION_CONFIG.Sounds.Scream = {}
LoadAssets( "sound", "charming_discussion/scream/", "GAME", CHARMING_DISCUSSION_CONFIG.Sounds.Scream )

-- Images Path
CHARMING_DISCUSSION_CONFIG.Images = {}
LoadAssets( "materials", "charming_discussion/images/", "GAME", CHARMING_DISCUSSION_CONFIG.Images )

--Settings params
CHARMING_DISCUSSION_CONFIG.DistanceFucker = 500
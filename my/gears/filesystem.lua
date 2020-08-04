local Gio = require("lgi").Gio
local gstring = require("my.gears.string")
local gtable = require("my.gears.table")

local filesystem = {}

local function make_directory(gfile)
    local success, err = gfile:make_directory_with_parents()
    if success then return true end
    if err.domain == Gio.IOErrorEnum and err.code == "EXISTS" then

        return true
    end
    return false, err
end

function filesystem.make_directories(dir)
    return make_directory(Gio.File.new_for_path(dir))
end


function filesystem.make_parent_directories(path)
    return make_directory(Gio.File.new_for_path(path):get_parent())
end

function filesystem.file_readable(filename)
    local gfile = Gio.File.new_for_path(filename)
    local gfileinfo = gfile:query_info("standard::type,access::can-read",
                                       Gio.FileQueryInfoFlags.NONE)
    return gfileinfo and gfileinfo:get_file_type() ~= "DIRECTORY" and
               gfileinfo:get_attribute_boolean("access::can-read")
end

function filesystem.file_executable(filename)
    local gfile = Gio.File.new_for_path(filename)
    local gfileinfo = gfile:query_info("standard::type,access::can-execute",
                                       Gio.FileQueryInfoFlags.NONE)
    return gfileinfo and gfileinfo:get_file_type() ~= "DIRECTORY" and
               gfileinfo:get_attribute_boolean("access::can-execute")
end

function filesystem.dir_readable(path)
    local gfile = Gio.File.new_for_path(path)
    local gfileinfo = gfile:query_info("standard::type,access::can-read",
                                       Gio.FileQueryInfoFlags.NONE)
    return gfileinfo and gfileinfo:get_file_type() == "DIRECTORY" and
               gfileinfo:get_attribute_boolean("access::can-read")
end

function filesystem.is_dir(path)
    return Gio.File.new_for_path(path):query_file_type({}) == "DIRECTORY"
end

function filesystem.get_xdg_config_home()
    return (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") ..
               "/"
end

function filesystem.get_xdg_cache_home()
    return (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME") .. "/.cache") ..
               "/"
end

function filesystem.get_xdg_data_home()
    return
        (os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share") ..
            "/"
end

function filesystem.get_xdg_data_dirs()
    local xdg_data_dirs = os.getenv("XDG_DATA_DIRS") or
                              "/usr/share:/usr/local/share"
    return gtable.map(function(dir) return dir .. "/" end,
                      gstring.split(xdg_data_dirs, ":"))
end

function filesystem.get_configuration_dir()
    return awesome.conffile:match(".*/") or "./"
end

function filesystem.get_cache_dir()
    local result = filesystem.get_xdg_cache_home() .. "awesome/"
    filesystem.make_directories(result)
    return result
end

function filesystem.get_themes_dir()
    return (os.getenv('AWESOME_THEMES_PATH') or awesome.themes_path) .. "/"
end

function filesystem.get_awesome_icon_dir()
    return (os.getenv('AWESOME_ICON_PATH') or awesome.icon_path) .. "/"
end



function filesystem.get_random_file_from_dir(path, exts)
    local files, valid_exts = {}, {}

    if exts then for i, j in ipairs(exts) do valid_exts[j:lower()] = i end end

    local file_list = Gio.File.new_for_path(path):enumerate_children(
                          "standard::*", 0)
    for file in function() return file_list:next_file() end do
        if file:get_file_type() == "REGULAR" then
            local file_name = file:get_display_name()
            if not exts or
                valid_exts[file_name:lower():match(".+%.(.*)$") or ""] then
                table.insert(files, file_name)
            end
        end
    end

    return #files > 0 and files[math.random(#files)] or nil
end

return filesystem

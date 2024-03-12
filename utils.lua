local ffi = require("ffi")

function VLIB_IsArray(tbl)
    for k,_ in pairs(tbl) do
        if type(k) ~= "number" then
            return false
        end
    end
    return true
end

function VLIB_Merge(tbl, other)
    if VLIB_IsArray(other) then
        -- If the source table is an array, just append the values
        -- to the end of the destination table.
        for _,v in ipairs(other) do
            table.insert(tbl, v)
        end
    else
        for k,v in pairs(other) do
            -- Otherwise, just copy the value over.
            tbl[k] = v
        end
    end
    return tbl
end

function VLIB_GetWantedArtifactName()
    if ffi.os == "Windows" then
        if ffi.arch == "x64" then
            return "Vlib-x64-windows"
        else
            return "Vlib-win32-windows"
        end
    elseif ffi.os == "OSX" then
        return "Vlib-macos"
    else
        return "Vlib-ubuntu"
    end
end

function VLIB_GetWantedLibraryName()
    if ffi.os == "Windows" then
        name = "VVVVVV-"
        if ffi.arch == "x64" then
            name = name .. "x64.dll"
        else
            name = name .. "x86.dll"
        end
    elseif ffi.os == "OSX" then
        name = "libVVVVVV.dylib"
    else
        name = "libVVVVVV.so"
    end
    return name
end

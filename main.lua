local FS = require("fs")
local childprocess = require('childprocess')

local types = {
    FORCE_EXIT = "EXIT_WITH_CODE_1_WITHOUT_ERROR";
}
local function wait(int)
    local t = os.clock()
    repeat until os.clock() - t >= int
end

local function stringToTable(str)
    if not str:match("{(.+)}") then
        return nil, "Input string is not in the correct format"
    end
    local chunk = "return " .. str
    local func, err = load(chunk)
    if not func then
        return nil, "Error loading luaZ File: " .. err
    end
    local success, result = pcall(func)
    if not success then
        return nil, "Error loading luaZ File: " .. result
    end
    return result
end

local function loadluaz(file)
    local f = io.open(file, "r") or error("Failed to open file: " .. file)
    local str = f:read("*a")
    f:close()
    if string.find(str, "FORCE_EXIT") then
        str = string.gsub(str, "FORCE_EXIT", "'EXIT_WITH_CODE_1_WITHOUT_ERROR';")
    end
    return stringToTable(str)
end

local MAIN, a = loadluaz("modz.luaz")
local configZC = stringToTable(io.open("modz.zc", "r"):read("*a")) or function() print("Error loading config file: modz.zc") return end

if MAIN then
    print("MODZ | Using Version: " .. configZC.ModZ_Version)
    wait(0.1)
    print("Initializing package: " .. MAIN.name)
else
    print("Error loading package: " .. a)
    return
end

wait(0.4)
print("Installing Package: " .. MAIN.name .. " | " .. MAIN.version)
wait(0.5)
print("Installing Package Author(s): " .. table.concat(MAIN.authors, " | "))


if MAIN.onStart then
    for i = 1, #MAIN.onStart do
        print(MAIN.onStart[i].message)
        wait(0.2)
    end
end

local function downloadFile(url, path, filename)
    childprocess.exec('luvit createFile.lua "'..url..'" "'..filename..'" "'..path..'"',{},function(err,stdout,stderr) print(stdout) 
        if err then
            print("ERROR DEVELOP MODE: " .. p(err))
        end
end)
    if FS.existsSync(filename) then
        print("Downloaded file: " .. filename .. " has been created in: " .. path)
    else
        print("Failed to download file: " .. filename)
    end
    wait(1)
end

local function runCommand(tbl)
    if type(tbl) ~= "table" then
        print("ERROR DEVELOP MODE")
    end
    for j = 1 , #tbl do
        print("Running command: " .. tbl[j].cmd)
        wait(0.5)
        childprocess.exec(tbl[j].cmd, tbl[j].options or {}, function(err, stdout, stderr)
            if err then
                print("Error while running command,exited with code " .. err.code .. " : " .. err.code)
                if tbl[j].message then
                    print(tbl[j].message)
                end
                if tbl[j].onError == types.FORCE_EXIT then
                    os.exit(1)
                end
            return
            end
            print(stdout)
        end)
    end
end

if MAIN.install then
    print("Installation starting..")
    wait(0.5)
    for i = 1, #MAIN.install do
        if MAIN.install[i].DOWNLOAD then
            print("Downloading from link: " .. MAIN.install[i].DOWNLOAD.link)
            downloadFile(MAIN.install[i].DOWNLOAD.link, MAIN.install[i].DOWNLOAD.path, MAIN.install[i].DOWNLOAD.filename)
        end
        if MAIN.install[i].COMMAND then
            runCommand(MAIN.install[i].COMMAND)
        end
    end
end

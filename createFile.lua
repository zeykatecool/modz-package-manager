local HTTP,HTTPS = require("http"),require("https")
local FS = require("fs")
local url = require("url")

local URL = args[2]
local fileName = args[3]
local filePath = args[4]

local A = url.parse(URL).protocol == "https" and HTTPS or HTTP
local req = A.get(URL, function(res)
    local body = ""
    res:on("data", function(chunk)
        body = body .. chunk
    end)
    res:on("end", function()
        local file = FS.writeFileSync(filePath.."\\" .. fileName, body)
    end)
    res:on("error", function(err)
        print("Error while downloading file: " .. err)
    end)

end)

req:on("error", function(err)
    print("Error while downloading file: " .. err)
end)

req:done()


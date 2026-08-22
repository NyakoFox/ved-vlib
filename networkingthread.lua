local channel_in = love.thread.getChannel("vlib_https_in")
local channel_out = love.thread.getChannel("vlib_https_out")

require("love.filesystem")
local https = require("https_main")

-- Thread loop
while true do
    local msg = channel_in:demand()
    if msg == "stop" then
        break
    else
        local key = msg.key or 0
        local url = msg.url

        if https and type(https) == "table" then
            local response = https.request(url, function(dlnow, dltotal)
                channel_out:push({
                    key = key,
                    progress = {
                        dlnow = dlnow,
                        dltotal = dltotal
                    }
                })
            end)

            channel_out:push({
                key = key,
                response = response
            })
        else
            local response = https_request(url)
            channel_out:push({
                key = key,
                response = response
            })
        end
    end
end

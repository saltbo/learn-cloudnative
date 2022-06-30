function envoy_on_request(request_handle)
    timestamp = request_handle:timestamp()
    -- response_handle:logInfo(sts)
    request_handle:streamInfo():dynamicMetadata():set("envoy.filters.http.lua", "sts", timestamp)

    local uri = request_handle:headers():get(":path")
    local idx = string.find(uri, "?")
    if idx ~= nil then
        local query = string.sub(uri, idx + 1)
        request_handle:streamInfo():dynamicMetadata():set("envoy.filters.http.lua", "query", query)
    end

    request_handle:streamInfo():dynamicMetadata():set("envoy.filters.http.lua", "clusterInfo", {
        cluster = os.getenv("HOME"),
        env = os.getenv("HOME"),
    })
end

function envoy_on_response(response_handle)
    sts = response_handle:streamInfo():dynamicMetadata():get("envoy.filters.http.lua")["sts"]
    ets = response_handle:timestamp()
    response_handle:logInfo(sts)
    response_handle:logInfo(ets)
    response_handle:logInfo(ets - sts)
    ts = response_handle:timestamp()
    response_handle:logInfo(string.format("%s.%sZ", os.date("%Y-%m-%dT%H:%M:%S", ts / 1000),
        string.sub(tostring(ts), string.len(ts) - 2)))
    response_handle:body():setBytes("<html><b>Not Found<b></html>")
end

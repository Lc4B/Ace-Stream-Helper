local engine_open = false

local function ace_engine()
	local appdata = os.getenv('APPDATA')
	mp.commandv("run", appdata.."\\ACEStream\\engine\\ace_engine.exe")
	engine_open = true
	mp.add_timeout(1, function()
        mp.osd_message("Launched Ace Engine")
    end)
	mp.add_timeout(5, function()
		local time_pos = mp.get_property("time-pos")
		if time_pos == nil then
			local playlist_len = mp.get_property_number("playlist-count")
			if playlist_len > 1 then
				mp.command("playlist_next")
				mp.command("playlist_prev")
			elseif playlist_len == 1 then
				local url = mp.get_property("path")
				mp.commandv("loadfile", url, "replace")
			end
		end
    end)
end

local function ace_stream()
	local url = mp.get_property("path")
	if engine_open == false and url:match("^acestream://(%w+)") then
		ace_engine()
	end
end

local function ace_quit()
	if engine_open == true then
		mp.command_native({
			name = 'subprocess',
			args = {'taskkill', '/f', '/im', 'ace_engine.exe'},
			playback_only = false,
		})
		mp.command_native({
			name = 'subprocess',
			args = {'cmd', '/C', 'RD', '/S', '/Q', "C:\\_acestream_cache_"},
			playback_only = false,
		})
		engine_open = false
	end
end

mp.register_event("start-file", ace_stream)
mp.register_event("shutdown", ace_quit)
mp.observe_property("idle-active", "bool", function(name, value)
	if value == true then
		ace_quit()
	end
end)
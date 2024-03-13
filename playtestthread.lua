local savepath, pluginpath, vvvvvv_settings = ...

local channel_in = love.thread.getChannel("vlib_in")
local channel_out = love.thread.getChannel("vlib_out")
local channel_out_signal = love.thread.getChannel("vlib_out_signal")
local channel_out_draw = love.thread.getChannel("vlib_out_draw")

require("love.filesystem")
require("love.system")

local ffi = require("ffi")
require(pluginpath .. "utils")

local name

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

local path = vvvvvv_settings.path or (savepath .. "/libs/" .. name)

local success, v_lib = pcall(ffi.load, path)

if not success then
    error("Failed to load VVVVVV library at path " .. path .. ": " .. v_lib)
end

ffi.cdef([[
    int mainLoop(int argc, char* argv[]);
    void setScreenbufferPointer(void* ptr);
    const char* get_state(void);
    void set_base_path(const char* path);
    void deltaupdate(void);
    void deltadraw(float delta);
    void return_to_idlemode(void);
    bool should_vvvvvv_exit(void);

    void clear_input(void);
    bool get_flag(int flag);
    void set_flag(int flag, bool value);
    void set_invincibility(bool invincible);
    void set_roomname_bg(bool translucent);
    void set_volume(int volume);
    void set_sound_volume(int volume);
    void play_level_init(void);
    void set_texture_size(const char* texture, int w, int h);
    void play_level(const char* level_data, const char* playassets);
    void simulate_keyevent(const char* event_type, const char* new_key, bool repeat);
    void simulate_mouseevent(const char* event_type, int button, int x, int y);
    void simulate_mousemoveevent(int x, int y);

    typedef enum {
        DRAW_NONE = -1,
        DRAW_RECT = 0,
        DRAW_LINE = 1,
        DRAW_CIRCLE = 2,
        DRAW_TEXT = 3,
        DRAW_SET_COLOR = 4,
        DRAW_FILL_RECT = 5,
        DRAW_CLEAR = 6,
        DRAW_SET_TARGET = 7,
        DRAW_TEXTURE = 8,
        DRAW_TEXTURE_EXT = 9,
        DRAW_SET_TINT_COLOR = 10,
        DRAW_SET_TINT_ALPHA = 11
    } draw_type;

    typedef struct {
        int x;
        int y;
    } point;

    typedef struct {
        uint8_t r;
        uint8_t g;
        uint8_t b;
        uint8_t a;
    } color;

    typedef struct {
        int x;
        int y;
        int w;
        int h;
    } rect;

    typedef struct {
        draw_type type;
        point p1;
        point p2;
        point size;
        color color;
        char texture[255];
        rect src;
        rect dest;
        point center;
        int angle;
        bool flip_x;
        bool flip_y;
        bool src_whole;
        bool dest_whole;
    } draw_message;

    draw_message pop_draw_messages(void);
]])

local vvvvvv_state = "IDLEMODE"
local vvvvvv_flags = {}
for i = 1, 100 do
    vvvvvv_flags[i] = false
end

local args = {"-leveldebugger"}

local argv = ffi.new("const char*[" .. tostring(#args + 1) .. "]")
for i = 1, #args do
    argv[i] = args[i]
end

local started = false
local level_data = nil
local data_pos = {}

function VLIB_decode_message(message)
    local tbl = {
        type = tonumber(message.type),
        p1_x = tonumber(message.p1.x),
        p1_y = tonumber(message.p1.y),
        p2_x = tonumber(message.p2.x),
        p2_y = tonumber(message.p2.y),
        size_x = tonumber(message.size.x),
        size_y = tonumber(message.size.y),
        color_r = tonumber(message.color.r),
        color_g = tonumber(message.color.g),
        color_b = tonumber(message.color.b),
        color_a = tonumber(message.color.a),
        texture = ffi.string(message.texture),
        src_x = tonumber(message.src.x),
        src_y = tonumber(message.src.y),
        src_w = tonumber(message.src.w),
        src_h = tonumber(message.src.h),
        dest_x = tonumber(message.dest.x),
        dest_y = tonumber(message.dest.y),
        dest_w = tonumber(message.dest.w),
        dest_h = tonumber(message.dest.h),
        center_x = tonumber(message.center.x),
        center_y = tonumber(message.center.y),
        angle = tonumber(message.angle),
        flip_x = message.flip_x,
        flip_y = message.flip_y,
        src_whole = message.src_whole,
        dest_whole = message.dest_whole
    }
    return tbl
end

while true do
    local data = channel_in:demand()
    if data.type == "set_base_path" then
        v_lib.set_base_path(data.path)
    elseif data.type == "start" then
        v_lib.play_level_init()
        v_lib.mainLoop(#args + 1, ffi.cast("char**", argv))
        started = true
    elseif data.type == "settings" then
        vvvvvv_settings = data
        v_lib.set_invincibility(data.invincibility)
        v_lib.set_volume(data.music_volume)
        v_lib.set_sound_volume(data.sfx_volume)
    elseif data.type == "stop" then
        v_lib.return_to_idlemode()
    elseif data.type == "imagedata" then
        local casted_ptr = ffi.cast("uint8_t*", data.data)
        v_lib.setScreenbufferPointer(casted_ptr)
    elseif data.type == "level_data" then
        level_data = data.level_data
    elseif data.type == "data_pos" then
        data_pos = {
            x = data.x,
            y = data.y,
            rx = data.rx,
            ry = data.ry,
            gc = data.gc,
            music = data.music
        }
    elseif data.type == "set_texture_size" then
        v_lib.set_texture_size(data.name, data.w, data.h)
    elseif data.type == "start_level" then
        local modified_level_data = level_data:gsub(
            "</MapData>",
			"    <Playtest>\n" ..
			"        <playx>" .. data_pos.x .. "</playx>\n" ..
			"        <playy>" .. data_pos.y .. "</playy>\n" ..
			"        <playrx>" .. data_pos.rx .. "</playrx>\n" ..
			"        <playry>" .. data_pos.ry .. "</playry>\n" ..
			"        <playgc>" .. data_pos.gc .. "</playgc>\n" ..
			"        <playmusic>" .. data_pos.music .. "</playmusic>\n" ..
			"    </Playtest>\n" ..
			"</MapData>"
        )

        if (vvvvvv_settings.translucent_bg == nil) then
            v_lib.set_roomname_bg(data.translucent_bg)
        else
            v_lib.set_roomname_bg(vvvvvv_settings.translucent_bg)
        end

        local editingmap = data.editingmap
        v_lib.play_level(modified_level_data, (editingmap and editingmap ~= "untitled\n") and ("levels/" .. editingmap .. ".vvvvvv") or "")
    elseif data.type == "update" and started then
        v_lib.deltaupdate()
        local old_state = vvvvvv_state
        vvvvvv_state = ffi.string(v_lib.get_state())
        if old_state ~= vvvvvv_state then
            channel_out:push({
                type = "state",
                state = vvvvvv_state
            })
        end
        for i = 1, 100 do
            local value = v_lib.get_flag(i - 1)
            if value ~= vvvvvv_flags[i] then
                vvvvvv_flags[i] = value
                channel_out:push({
                    type = "flag",
                    flag = i,
                    value = value
                })
            end
        end
        if (v_lib.should_vvvvvv_exit()) then
            channel_out:push({
                type = "quit"
            })
        end
    elseif data.type == "setflag" and started then
        v_lib.set_flag(data.flag, data.value)
    elseif data.type == "delta" and started then
        v_lib.deltadraw(data.delta)
        local message = v_lib.pop_draw_messages()
        while message.type ~= -1 do -- -1 = DRAW_NONE
            local tbl = VLIB_decode_message(message)
            channel_out_draw:push(tbl)
            message = v_lib.pop_draw_messages()
        end
        channel_out_signal:push({
            type = "render"
        })
    elseif data.type == "clear_input" and started then
        v_lib.clear_input();
    elseif data.type == "key" and started then
        if data.state == "pressed" then
            v_lib.simulate_keyevent("keydown", data.key, data.repeating)
        elseif data.state == "released" then
            v_lib.simulate_keyevent("keyup", data.key, false)
        end
    elseif data.type == "mouse" and started then
        local mouse_to_id = {
            l = 1,
            m = 2,
            r = 3
        }
        if data.state == "pressed" then
            v_lib.simulate_mouseevent("mousedown", mouse_to_id[data.button], data.x, data.y)
        elseif data.state == "released" then
            v_lib.simulate_mouseevent("mouseup", mouse_to_id[data.button], data.x, data.y)
        elseif data.state == "moved" then
            v_lib.simulate_mousemoveevent(data.x, data.y)
        end
    end
end

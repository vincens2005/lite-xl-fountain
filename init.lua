-- lite-xl 2.0
local DocView = require "core.docview"
local command = require "core.command"
local core = require "core"
local style = require "core.style"
local common = require "core.common"

require "plugins.fountain.fountain"

local ScriptView = DocView:extend()

function ScriptView:draw_line_gutter() return end


local old_draw_line_text = ScriptView.draw_line_text

function ScriptView:draw_line_text(idx, x, y)
  local default_font = self:get_font()
  local tx, ty = x, y + self:get_line_text_y_offset()
  local vx, vy = self:get_content_offset()
  for _, type, text in self.doc.highlighter:each_token(idx) do
    local color = style.syntax[type]
    local font = style.syntax_fonts[type] or default_font
    local align = "left"
    local x_to_use = tx + 1
    if type == "character" then
			align = "center"
			text = text:match "^%s*@*%s*(.-)%s*$"
    end
    
    if type == "transition" then
			align = "right"
			text = text:match "^%s*>*%s*(.-)%s*$"
    end
    
    core.log_quiet(type)
    tx = common.draw_text(font, color, text, align, x_to_use, ty, self.size.x + vx - style.padding.x * 20, self:get_line_height())
    ::continue::
  end
end

local function open_script_view()
	local node = core.root_view:get_active_node()
	node:add_view(ScriptView(core.active_view.doc))
end

command.add(nil, {
	["script:open"] = open_script_view
})

return ScriptView

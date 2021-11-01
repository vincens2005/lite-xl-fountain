-- lite-xl 2.0
local DocView = require "core.docview"
local command = require "core.command"
local core = require "core"
local style = require "core.style"
local common = require "core.common"

require "plugins.fountain.fountain"

local ScriptView = DocView:extend()

function ScriptView.draw_line_gutter() return end


function ScriptView:get_col_x_offset(line, col)
  local default_font = self:get_font()
  local column = 1
  local xoffset = 0
  local x, y = self:get_line_screen_position(1)
  for _, type, text in self.doc.highlighter:each_token(line) do
    local font = style.syntax_fonts[type] or default_font
     if type == "character" then
			text = text:match "^%s*@*%s*(.-)%s*$"
			local w = font:get_width_subpixel(text)
			xoffset = xoffset + (self.size.x * font:subpixel_scale() - w) / 2
    end
    if type == "transition" then
			text = text:match "^%s*>*%s*(.-)%s*$"
			local w = font:get_width_subpixel(text)
			xoffset = xoffset + ((self.size.x - style.padding.x * 15) * font:subpixel_scale() - w)
    end
    for char in common.utf8_chars(text) do
      if column == col then
        return xoffset / font:subpixel_scale()
      end
      xoffset = xoffset + font:get_width_subpixel(char)
      column = column + #char
    end
  end

  return xoffset / default_font:subpixel_scale()
end

function ScriptView:draw_line_text(idx, x, y)
  local default_font = self:get_font()
  local tx, ty = x, y + self:get_line_text_y_offset()
  for _, type, text in self.doc.highlighter:each_token(idx) do
    local color = style.syntax[type]
    local font = style.syntax_fonts[type] or default_font
    local align = "left"
    if type == "character" then
			align = "center"
			text = text:match "^%s*@*%s*(.-)%s*$"
    end

    if type == "transition" then
			align = "right"
			text = text:match "^%s*>*%s*(.-)%s*$"
			tx = tx - style.padding.x * 15
    end

    tx = common.draw_text(font, color, text, align, tx, ty, self.size.x, self:get_line_height())
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

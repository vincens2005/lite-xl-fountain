-- lite-xl 2.0
local DocView = require "core.docview"
local command = require "core.command"
local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"

require "plugins.fountain.fountain"

local clean_patterns = {
	center = "^%s*>*%s*(.-)%s*<%s*$",
	character = "^%s*@*%s*(.-)%s*$",
	transition = "^%s*>*%s*(.-)%s*$",
	heading = "^%s*%.?%s*(.-)%s*$"
}

local ScriptView = DocView:extend()

function ScriptView:new(doc)
	ScriptView.super.new(self, doc)
	config.plugins.minimap.enabled = false
end

local old_name = ScriptView.get_name
function ScriptView:get_name()
	return old_name(self):match "(.-)%.fountain"
end

function ScriptView.draw_line_gutter() return end

local function offset_offset(self, type, font, text, xoffset, i, scale)
	if clean_patterns[type] ~= nil then
		text = text:match(clean_patterns[type])
	end
		if type == "character" or type == "center" then
		local w = font:get_width_subpixel(text)
		xoffset = xoffset + (self.size.x * scale - w) / 2
	end
	if type == "transition" then
		local w = font:get_width_subpixel(text)
		xoffset = xoffset + ((self.size.x - style.padding.x * 15) * scale - w)
	end
	if type == "normal" and i == 1 then
		xoffset = xoffset + (style.padding.x * 10) * scale
	end
	return xoffset
end

function ScriptView:get_col_x_offset(line, col)
  local default_font = self:get_font()
  local column = 1
  local xoffset = 0
  local x, y = self:get_line_screen_position(1)
  for i, type, text in self.doc.highlighter:each_token(line) do
    local font = style.syntax_fonts[type] or default_font
    xoffset = offset_offset(self, type, font, text, xoffset, i, font:subpixel_scale())
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

function ScriptView:get_x_offset_col(line, x)
  local line_text = self.doc.lines[line]

  local xoffset, last_i, i = 0, 1, 1
  local default_font = self:get_font()
  for i, type, text in self.doc.highlighter:each_token(line) do
    local font = style.syntax_fonts[type] or default_font
    xoffset = offset_offset(self, type, font, text, xoffset, i, 1)
    for char in common.utf8_chars(text) do
      local w = font:get_width(char)
      if xoffset >= x then
        return (xoffset - x > w / 2) and last_i or i
      end
      xoffset = xoffset + w
      last_i = i
      i = i + #char
    end
  end

  return #line_text
end

function ScriptView:draw_line_text(idx, x, y)
  local default_font = self:get_font()
  local tx, ty = x, y + self:get_line_text_y_offset()
  for i, type, text in self.doc.highlighter:each_token(idx) do
    local color = style.syntax[type]
    local font = style.syntax_fonts[type] or default_font
    local align = "left"
		if clean_patterns[type] ~= nil then
			text = text:match(clean_patterns[type])
		end
    if type == "character" then
			align = "center"
    end

		if type == "center" then
			align = type
		end

    if type == "transition" then
			align = "right"
			tx = tx - style.padding.x * 15
    end

    if type == "normal" and i == 1 then
			tx = tx + style.padding.x * 10
    end

    tx = common.draw_text(font, color, text, align, tx, ty, self.size.x, self:get_line_height())
  end
end

local function open_script_view()
	local node = core.root_view:get_active_node()
	node:add_view(ScriptView(core.active_view.doc))
end

command.add(DocView, {
	["script:open"] = open_script_view
})

return ScriptView

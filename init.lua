-- lite-xl 2.0
local DocView = require "core.docview"
local command = require "core.command"
local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local tokenizer = require "core.tokenizer"
local keymap = require "core.keymap"
--local autocomplete = require "plugins.autocomplete"
require "plugins.fountain.fountain"


local function clean_markup(text, type)
	local clean_patterns = {
		center = "^%s*>*%s*(.-%s*)<%s*$",
		character = "^%s*@*%s*(.-%s*)$",
		transition = "^%s*>*%s*(.-%s*)$",
		heading = "^%s*%.?%s*(.-%s*)$",
		normal = "^%s*!*%s*(.-%s*)$",
		lyrics = "^%s*~%s*(.-%s*)$"
	}
	if type == nil then return text end
	return text:match(clean_patterns[type] or ".*") or ""
end

local ScriptView = DocView:extend()

function ScriptView:new(doc)
	ScriptView.super.new(self, doc)
	config.plugins.minimap.enabled = false
end

local old_name = ScriptView.get_name
function ScriptView:get_name()
	return (old_name(self):match "(.-)%.fountain") .. (self.doc:is_dirty() and "*" or "") or old_name(self)
end

function ScriptView.draw_line_gutter() return end
ScriptView.draw_line_highlight = ScriptView.draw_line_gutter

-- stolen from docview.lua
local function move_to_line_offset(dv, line, col, offset)
	local xo = dv.last_x_offset
	if xo.line ~= line or xo.col ~= col then
		xo.offset = dv:get_col_x_offset(line, col)
	end
	xo.line = line + offset
	xo.col = dv:get_x_offset_col(line + offset, xo.offset)
	return xo.line, xo.col
end

ScriptView.translate = { -- TODO: make this work once the linewrap PR gets merged
	["previous_line"] = function(doc, line, col, dv)
		if line == 1 then
			return 1, 1
		end
		local line_text = dv.doc.lines[line]:match("^%s*(.-)%s*$")
		core.log(line_text)
		if #line_text == 0 then
			return ScriptView.translate.previous_line(doc, line - 1, col, dv)
		end
		return move_to_line_offset(dv, line, col, -1)
	end
}

local function offset_offset(self, type, font, text, xoffset, i, scale)
	text = clean_markup(text, type)
	if type == "character" or type == "center" then
		local w = font:get_width_subpixel(text)
		xoffset = xoffset + (self.size.x * scale - w) / 2
	end
	if type == "transition" then
		local w = font:get_width_subpixel(text) -- TODO: remove subpixel stuff when new font renderer is released
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
	for i, type, text in self.doc.highlighter:each_token(line) do
		local font = style.syntax_fonts[type] or default_font
		xoffset = offset_offset(self, type, font, text, xoffset, i, font:subpixel_scale())
		text = clean_markup(text, type)
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
	return #line_text -- I am literally a genius
end

function ScriptView:get_current_line()
	local idx, _, _, _ = self.doc:get_selection(true)
	return idx
end

function ScriptView:get_type(idx)
	local current_type = "character"
	for i, ty, _ in self.doc.highlighter:each_token(idx) do
		if i == 1 then
			current_type = ty
			break
		end
	end
	return current_type
end

function ScriptView:draw_line_text(idx, x, y)
	local default_font = self:get_font()
	local tx, ty = x, y + self:get_line_text_y_offset()
	for i, type, text in self.doc.highlighter:each_token(idx) do
		local color = style.syntax[type]
		local font = style.syntax_fonts[type] or default_font
		local align = "left"
		text = clean_markup(text, type)
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
		-- TODO: italic font for lyrics
		if type == "normal" and i == 1 then
			tx = tx + style.padding.x * 10
		end

		tx = common.draw_text(font, color, text, align, tx, ty, self.size.x, self:get_line_height())
	end
end

function ScriptView:set_current_block_type(type)
	local idx = self:get_current_line()
	local current_type = self:get_type(idx)

	if type == current_type then return end
	local text = clean_markup(self.doc.lines[idx], current_type)

	local prefixes = {
		character = "@",
		heading = ".",
		transition = ">",
		center = ">",
		normal = "!",
		lyrics = "~",
	}

	local postfixes = {
		center = "<"
	}

	local new_text = text
	if tokenizer.tokenize(self.doc.syntax, text)[1] ~= type then
		new_text = (prefixes[type] or "") .. text .. (postfixes[type] or "")
	end
	self.doc:remove(idx, 1, idx, #self.doc.lines[idx])
	self.doc:insert(idx, 1, new_text)
	--self.doc:remove(idx, #self.doc.lines[idx], idx + 1,#self.doc.lines[idx + 1])
end

local function open_script_view()
	local node = core.root_view:get_active_node()
	node:add_view(ScriptView(core.active_view.doc))
end

command.add(DocView, {
	["script:open"] = open_script_view
})

command.add(ScriptView, {
	["script:character"] = function()
		core.active_view:set_current_block_type("character")
	end,
	["script:center"] = function()
		core.active_view:set_current_block_type("center")
	end,
	["script:heading"] = function()
		core.active_view:set_current_block_type("heading")
	end,
	["script:transition"] = function()
		core.active_view:set_current_block_type("transition")
	end,
	["script:action"] = function()
		core.active_view:set_current_block_type("normal")
	end,
	["script:lyrics"] = function()
		core.active_view:set_current_block_type("lyrics")
	end,
	["script:clean"] = function()
		core.active_view:set_current_block_type("nothing")
	end
})

keymap.add {
	["ctrl+1"] = "script:heading",
	["ctrl+2"] = "script:action",
	["ctrl+3"] = "script:character",
	["ctrl+6"] = "script:transition",
	["ctrl+7"] = "script:lyrics",
	["ctrl+0"] = "script:clean"
}

-- so that autocomplete works
setmetatable(ScriptView, DocView)

return ScriptView

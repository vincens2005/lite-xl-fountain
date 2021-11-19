local syntax = require "core.syntax"

syntax.add {
	files = {"%.fountain$"},
	patterns = {
		{ pattern = {"/%*", "%*/"}, type = "comment" }, -- this is the boneyard
		{ regex = "^\\s*!\\s*.+", type = "normal"},
		{ regex = "^\\s*~\\s*.+", type = "lyrics" },
		{ pattern = {"%(", "%)"}, type = "parenthetical" },
		{ pattern = {"_", "_"}, type = "underline" },
		{ pattern = {"%*", "%*"}, type = "italic" },
		{ pattern = {"%*%*", "%*%*"}, type = "bold" },
		{ pattern = {"%[%[", "%]%]"}, type = "note"},
		{ pattern = "^===+", type = "linebreak" },
		{ regex = {"^\\s*[iIeE][nNxX][tT].*?\\n", "^\n"}, type = "heading" }, -- yes, this will detect "ixt." and "ent." but I don't care
		{ regex = "^\\s*\\..*", type = "heading" },
		{ regex = "^\\s*[A-Z\\s]*\\s+TO:\\s*$", type = "transition"},
		{ regex = "^\\s*>[^<]*$", type = "transition" },
		{ pattern = {">%s*", "%s*[<%c]"}, type = "center" },
		{ regex = {"^\\s*[A-Z\\.\\s^]+\\s*(\\(.*?\\))?\\s*\n", "^\n"}, type = "character" },
		{ regex = {"^\\s*@", "^\n"}, type = "character" },
	},
	symbols = {}
}


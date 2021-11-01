local syntax = require "core.syntax"

syntax.add {
	files = {"%.fountain$"},
	patterns = {
		{ pattern = {"%(", "%)"}, type = "parenthetical" },
		{ pattern = {"_", "_"}, type = "underline" },
		{ pattern = {"%*", "%*"}, type = "italic" },
		{ pattern = {"%*%*", "%*%*"}, type = "bold" },
		{ regex = "^\\s*[iIeE][nNxX][tT].*", type = "heading" },
		{ regex = "^\\s*\\..*", type = "heading" },
		{ regex = "^\\s*[A-Z\\s]+\\s+TO:", type = "transition"},
		{ regex = "^\\s*>[^<]*$", type = "transition" },
		-- TODO: character fix
		{ regex = {"^\\s*[A-Z\\s]+\\s*(\\(.*?\\))?\\s*\n", "^\n"}, type = "literal" },
	--	{ regex = "^\\s*@.+?\\n(.+\\n?)*", type = "literal" },
		-- end todo
		
	},
	symbols = {}
}


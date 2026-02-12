-- soup.lua --
--
-- exports the whole module
--
-- part of the soup files
-- https://github.com/if-not-nil/soup
local fmt = require("fmt")

return {
	result = require("result"),
	println = fmt.println,
	printf = fmt.printf,
	unfold = fmt.unfold,
	match = require("match"),
	cout = require("cout"),
	struct = require("struct"),
	lisp = require("lisp").Expression,
	lisp_lib = require("lisp").lib,
}

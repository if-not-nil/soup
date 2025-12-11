-- exporting everything and flattening it
local fmt = require("fmt")

return {
	result = require("result"),
	println = fmt.println,
	printf = fmt.printf,
	unfold = fmt.unfold,
	match = require("match"),
	cout = require("cout"),
	lisp = require("lisp").Expression,
	lisp_lib = require("lisp").lib,
}

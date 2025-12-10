-- exporting everything and flattening it
local fmt = require("fmt")

return {
	result = require("result"),
	println = fmt.println,
	printf = fmt.printf,
	unfold = fmt.unfold,
	match = require("match"),
	misc = {
		lisp = require("lisp"),
		writers = require("writers")
	}
}

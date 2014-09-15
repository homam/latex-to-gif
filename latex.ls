{promises: {new-promise, parallel-limited-sequence, serial-sequence, from-error-value-callback, from-void-callback, promise-monad}} = require \async-ls

fs = require \fs
md5 = require \md5
sh = require \execSync

main-template = fs.read-file-sync './latex-template.tex', encoding: \utf8

convert = (input, output-gif, output-latex) ->

	(succf, errf) <- new-promise

	input := (input.split "\\vspace{5} ").join ""
	temp-file-name = md5 input
	template = main-template.replace "{FORMULA}", "& " + ((input.split "\\\\" ).join "\\\\\n& ").trim!
	template = template.replace "{RAW}", input

	sh.exec "mkdir /tmp/latex-to-gif/#{temp-file-name}"

	_ <- fs.write-file "/tmp/latex-to-gif/#{temp-file-name}/input.tex", template, encoding: \utf8

	sh.exec "cd /tmp/latex-to-gif/#{temp-file-name} && latex input.tex && dvips -o input.eps -E input.dvi && convert +adjoin -antialias -density 150 input.eps input.gif"

	sh.exec "cp /tmp/latex-to-gif/#{temp-file-name}/input.gif #{output-gif}"
	sh.exec "cp /tmp/latex-to-gif/#{temp-file-name}/input.tex #{output-latex}"

	_ <- set-timeout _, 50

	#sh.exec "rm -rf /tmp/latex-to-gif/#{temp-file-name}"

	succf!



module.exports = convert
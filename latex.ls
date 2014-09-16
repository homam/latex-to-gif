{promises: {new-promise, parallel-limited-sequence, serial-sequence, from-error-value-callback, from-void-callback, promise-monad}} = require \async-ls

fs = require \fs
md5 = require \MD5
sh = require \execSync
exec = require('child_process').exec


main-template = fs.read-file-sync './latex-template.tex', encoding: \utf8

convert = (input, output-gif, output-latex) ->

	(succf, errf) <- new-promise

	input := input.replace /\\(h|v)space\{(\d+)\}/gi, '\\$1space{$2pt}' #(input.split "\\vspace{5} ").join ""
	temp-file-name = md5 input
	template = main-template.replace "{FORMULA}", "& " + ((input.split "\\\\" ).join "\\\\\n& ").trim!
	template = template.replace "{RAW}", input

	sh.exec "mkdir /tmp/latex-to-gif/#{temp-file-name}"

	_ <- fs.write-file "/tmp/latex-to-gif/#{temp-file-name}/input.tex", template, encoding: \utf8


	{pid} = exec do 
		"cd /tmp/latex-to-gif/#{temp-file-name} && latex input.tex && dvips -o input.eps -E input.dvi && convert +adjoin -antialias -density 150 input.eps input.gif"
		(error, stdout, stderr) ->
			# sh.exec "cd /tmp/latex-to-gif/#{temp-file-name} && latex input.tex && dvips -o input.eps -E input.dvi && convert +adjoin -antialias -density 150 input.eps input.gif"

			sh.exec "cp /tmp/latex-to-gif/#{temp-file-name}/input.gif #{output-gif}"
			sh.exec "cp /tmp/latex-to-gif/#{temp-file-name}/input.tex #{output-latex}"

			set-timeout  do
				-> sh.exec "rm -rf /tmp/latex-to-gif/#{temp-file-name}"
				50

			succf!

	# two seconds timeout
	set-timeout do
		-> 
			_ <- exec 'taskkill /PID ' + pid + ' /T /F'
			errf 'ERROR!'
		2000




module.exports = convert
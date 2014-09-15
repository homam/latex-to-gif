fs = require \fs
{map, filter} = require \prelude-ls
{promises: {new-promise, serial-map, parallel-limited-sequence, serial-sequence, from-error-value-callback, from-void-callback, promise-monad}} = require \async-ls


find-and-repalce = (regex, replacement, file) -->
	new-file = ""
	last-index = 0
	while m = regex.exec file
		new-file := new-file + (file.substring last-index, m.index) + replacement m
		last-index := m.index + m.0.length

	new-file + file.substring last-index, file.length


find-all-matches = (regex, selector, file) -->
	list = []

	while m = regex.exec file
		list.push selector m

	list


find-and-repalce-file = (regex, replacement, path) -->
	file <- promise-monad.bind (from-error-value-callback fs.read-file, fs) path, encoding: \utf8
	new-file = find-and-repalce regex, replacement, file
	(succf, errf) <- new-promise
	err <- fs.write-file path, new-file, encoding: \utf8
	return errf err if !!err
	succf!


find-and-repalce-many-files = (regex, replacement, paths) -->
	parallel-limited-sequence 4, (paths |> map find-and-repalce-file regex, replacement)





latex = require \./latex
md5 = require \md5




do-for-a-file = (path) ->
	console.log "Processing #path"
	file <- promise-monad.bind (from-error-value-callback fs.read-file, fs) path, encoding: \utf8
	r = /\[\{\(e(.+?)\)\}\]/gi
	serial-sequence <| (find-all-matches r, (.1), file) |> map ((m) -> console.log (unescape m); latex (unescape m), "~/Desktop/c5/#{md5 m}.gif", "~/Desktop/c5/#{md5 m}.tex")




# do-for-a-file "/Users/homam/dev/ma/maAssets/GeometryBasics/text/GeometryBasics-en.xml"
# 	..then -> console.log "done!"
# 	..catch -> console.log "error = ", arguments


(err, file) <- fs.read-file './xml-files.txt', encoding: \utf8
((file.split '\n') |> filter (.length > 0)) |> serial-map do-for-a-file
	..then -> console.log "done!"
	..catch -> console.log "error = ", arguments

# find-and-repalce-many-files /\[\{\(e(.+?)\)\}\]/gi  , (-> "[{(e" + (it.1.replace /\s+/ig, '').replace( /%26nbsp%3B/ig, '%20').replace( /%3Cbr%3E/ig, '%20').replace( /%5Cqua%20/ig, '%5Cquad%20') + ")}]"), ((file.split '\n') |> filter (.length > 0))
# 	..then -> console.log 'done!'
# 	..catch -> console.log "error = ", arguments
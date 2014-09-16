{
	promises: {
		promise-monad
		new-promise
		to-callback
	}
} = require \async-ls
express = require \express
path = require \path
http = require \http
body-parser = require \body-parser
{map, pairs-to-obj, Obj} = require \prelude-ls
fs = require \fs
latex = require \./latex
config = require \./config
md5 = require \MD5
cache = new (require \node-cache) stdTTL: 5*60, checkperiod: 6*60


# start the http server: lsc server.ls --port=3002
{port} = (process.argv.slice(2) |> require \minimist)
port = port or 3002


app = express!
app.use body-parser.urlencoded extended: true
app.set \port, port

# app.set \views, __dirname + \/
# app.engine \.html, (require \ejs).__express
# app.set 'view engine', \ejs
# app.use \/libs, express.static \../public/libs
# app.use \/graphs, express.static \../public/graphs

app.get '/:expression', (req, res) ->
	serve = (file) ->
		fs.create-read-stream file .pipe res

	expression = unescape req.params.expression
	hash = md5 expression

	(err, cached) <- cache.get hash

	return serve cached[hash] if !err and not (Obj.empty cached)

	file = "#{config.output-path}/#{hash}.gif"
	(file-exists) <- fs.exists file
	return serve file if file-exists

	latex expression, "#{file}", "#{config.output-path}/#{hash}.tex"
		..then ->
			cache.set hash, file
			fs.create-read-stream file .pipe res
		..catch ->
			res.end 'error!'



app.listen app.get \port
console.log "server started on port #{app.get \port}"
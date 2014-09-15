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
{map, pairs-to-obj} = require \prelude-ls
fs = require \fs
latex = require \./latex
md5 = require \md5


# start the http server: lsc server.ls --port=3002
{port} = (process.argv.slice(2) |> require \minimist)
port = port or 3002


app = express!
app.use body-parser.urlencoded extended: true
app.set \port, port
app.set \views, __dirname + \/
app.engine \.html, (require \ejs).__express
app.set 'view engine', \ejs
app.use \/libs, express.static \../public/libs
app.use \/graphs, express.static \../public/graphs

app.get '/:expression', (req, res) ->
	expression = unescape req.params.expression
	latex expression, "/Users/homam/Desktop/latex/tmp/#{md5 expression}.gif", "/Users/homam/Desktop/latex/tmp/#{md5 expression}.tex"
		..then ->
			fs.create-read-stream "/Users/homam/Desktop/latex/tmp/#{md5 expression}.gif" .pipe res
		..catch ->
			res.end 'error!'
	#res.end 'hello'



app.listen app.get \port
console.log "server started on port #{app.get \port}"
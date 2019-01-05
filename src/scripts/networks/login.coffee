open = require 'opn'
ora = require 'ora'
http = require './http'

request_token = () ->
  json = await http.post '/tokens', do http.make_options
  if not json.token
    fine.print.error json.message if json.message?
    fine.print.error 'unable to connect to server'
  json.token

request_session = (token) ->
#  token = 'bd74a5ab-eca4-4d4a-b959-9335d1aa76d4'
  try
    json = await http "/sessions/command/#{token}", do http.make_options
    return false if not json or not json.token
    json.token
  catch err
  
login = () ->
  wait = new ora
  token = await do request_token
  open "https://fine.sh/auth/validate?command_id=#{token}"
  wait.start 'waiting for login validation...'
  
  timer = setInterval((() ->
    session = await request_session token
    return if not session
    fine.storage.save 'session', session
    wait.succeed 'login successfully.'
    clearInterval timer
    process.exit 1
  ), 650)

module.exports =
  run: login

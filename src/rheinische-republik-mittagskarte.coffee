# Description
#   A Hubot Script that shows this weeks menu of Rheinische Republik Restaurant
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Till Kothe[till@kreditech.com]

pdfText = require 'pdf-text'

module.exports = (robot) ->
  robot.respond /rhein/, (res) ->
    buffer = []
    res.reply "fetching Speisekarte..."
    robot.http('http://www.rheinische-republik.de/pdf/rheinische-republik-wochenkarte.pdf')    
      .get (err, req) -> 
          req.end()
          req.addListener 'response', (resp) -> 
            resp.addListener 'data', (data) ->
              buffer.push(data)
            resp.addListener 'end', ->
              result = Buffer.concat(buffer)
              pdfText result, (err, chunks) -> 
                if err
                  res.reply 'something went wrong here...' + JSON.stringify(err) + "Error: " + typeof(err) + "\nBody: " + typeof(buffer)
                else
                  fulltext = chunks.join('')
                  endingnewlines = fulltext.replace /€.\d{1,2}\,\d{2}|RHEINISCHE REPUBLIK|Schnell.Lecker.Freundlich./gi, (x) ->
                    ' ' + x + '\n'
                  begginingandendingnewlines = endingnewlines.replace /Dienstag|Mittwoch|Donnerstag|Freitag|Und wie immer/gi, (x) ->
                    '\n' + x
                  res.reply begginingandendingnewlines

  robot.hear /hungry/, (res) ->
    res.send "you're hungry? Ask me about the current menu at Rheinische Republik"

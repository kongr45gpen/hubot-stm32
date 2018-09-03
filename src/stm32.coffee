# Description:
#   Allows instant searching for datasheets and reference manuals of the STM product line
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot stm datasheet <mcu> - Link to the datasheet of an STM32 microcontroller
#   hubot reference <mcu> - Link to the reference manual of an STM32 microcontroller
#
# Examples:
#   hubot stm datasheet stm32f103rb
#   hubot reference l432
#
# Notes:
#   All trademarks belong to their respective owners. 'STM32' is a registered trademark
#   of STMicroelectronics International N.V.
#
# Author:
#   kongr45gpen

module.exports = (robot) ->

  robot.respond /(stm datasheet|reference) (.*)/i, (res) ->
    documentType = res.match[1]
    wantedMcu = res.match[2].toLowerCase().replace /^\s+|\s+$/g, "" # trim/strip
    if robot.adapter != undefined and robot.adapter.client != undefined and robot.adapter.client.react != undefined
        # If the adapter supports it, add an hourglass reaction to the message, to show that the
        # request is begin processed
        robot.adapter.client.react(res.message.id, 'hourglass')

    robot.http("http://stmcufinder.com/API/getMCUsForMCUFinderPC.php")
        .header('Accept', 'application/json')
        .get() (err, response, body) ->
            if response.statusCode isnt 200 or err
                res.send "Unable to request. #{err}"

            data = JSON.parse body
            robot.logger.debug "Received #{data.MCUs.length} microcontrollers"

            mcu = null
            while mcu is null
                robot.logger.debug "Searching for MCU #{wantedMcu}..."
                for myMcu in data.MCUs.reverse()
                    if myMcu.name.toLowerCase().search(wantedMcu) >= 0
                        # MCU found!
                        robot.logger.debug "MCU found successfully. Match: #{myMcu.name.toLowerCase()} ~= #{wantedMcu}", myMcu.name.toLowerCase().search(wantedMcu)
                        mcu = myMcu
                        break
                # If we still haven't found the MCU, cut off the name and search again
                wantedMcu = wantedMcu.slice(0, -1)
            if mcu
                robot.logger.debug "Matched MCU #{mcu.name}"
                # Get the files
                robot.http("http://stmcufinder.com/API/getFiles.php")
                    .header('Accept', 'application/json')
                    .get() (err, response, body) ->
                        if response.statusCode isnt 200 or err
                            res.send "Unable to get files. #{err}"
                            return

                        if robot.adapter != undefined and robot.adapter.client != undefined and robot.adapter.client.unreact != undefined
                            # Remove emoji, the request is over
                            robot.adapter.client.unreact(res.message.id, 'hourglass')

                        data = JSON.parse body
                        robot.logger.debug "Got #{data.Files.length} total files."
                        mcuFile = if (documentType == "stm datasheet") then "Datasheet" else "Reference manual"
                        for mFile in mcu.files
                            for sFile in data.Files
                                if mFile.file_id == sFile.id_file and sFile.type == mcuFile
                                    res.reply "**#{sFile.type}** for **#{mcu.name}**: #{sFile.URL}\n(#{sFile.title})"
            else
                res.send "Error! Could not find requested MCU."

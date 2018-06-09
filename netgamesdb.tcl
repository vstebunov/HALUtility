package require http
package require json

source config.tcl

proc uploadFromCache { cache } {

    #Как то показывать что идёт загрузка

    ::http::config -urlencoding

    dict for {gameID game} $cache {
        dict with game {
            if {$uploaded eq 1} {
                continue
            }

            set preliminary [networkGetPreliminaryByName $name]

            dict update cache $gameID updateGame {
                dict set updateGame uploaded 1
                dict set updateGame preliminary $preliminary
            }

        }
    }

    return $cache
}

proc networkGetPreliminaryByName { name } {
    global userkey

    set urlSearchByName "http://api-endpoint.igdb.com/games/?search=$name&fields=id,name,cover,screenshots&limit=50"

    set token [http::geturl $urlSearchByName -headers "user-key $userkey" ]
    set resp [http::data $token]
    http::cleanup $token

    return [json::json2dict $resp]
}

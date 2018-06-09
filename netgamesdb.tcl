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

            set IDS [networkGetIDsByName $name]

            dict for {k gameDBID} $IDS {
                dict with gameDBID {
                    set response [networkGetInfoByID $id]
                    lappend preliminary $response
                }
            }

            dict update cache $gameID updateGame {
                dict set updateGame uploaded 1
                dict set updateGame gameDBID $IDS
                dict set updateGame preliminary $preliminary
            }

        }
    }

    return $cache
}

proc networkGetIDsByName { name } {

    global userkey

    set urlSearchByName "http://api-endpoint.igdb.com/games/?search=$name"

    if {0} {
        set token [http::geturl $urlSearchByName -headers "user-key $userkey" ]
        puts [http::data $token]
        http::cleanup $token
    }

    set jsonIDs {[{"id":125},{"id":101207},{"id":47452},{"id":246},{"id":38659},{"id":3182},{"id":90628},{"id":20057},{"id":126},{"id":120}]}
    return [json::json2dict $jsonIDs]
}

proc networkGetInfoByID { id } {

    global userkey

    puts $id
    set urlSearchByID "http://api-endpoint.igdb.com/games/$id?fields=cover,screenshots,name"

    set token [http::geturl $urlSearchByID -headers "user-key $userkey" ]
    set resp [http::data $token]
    http::cleanup $token

    puts $resp
    return [json::json2dict $resp]
}

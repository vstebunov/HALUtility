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
            cache::setPreliminaryToEntity $preliminary $gameID 
        }
    }
    return [cache::get]
}

proc uploadImage {filename URL {size ""}} {
    puts $filename

    if {$size ne ""} {
        set URL [string map [list thumb $size] $URL]
    }

    puts $URL

    set f [open $filename wb]
    set tok [http::geturl "http:$URL" -channel $f -binary 1]
    close $f

    if {[http::status $tok] eq "ok" && [http::ncode $tok] == 200} {
        puts "Downloaded successfully http:$URL"
    } else {
        puts "Download wrong! http:$URL"
        file delete $filename
        return 0
    }
    http::cleanup $tok
    return 1
}

proc networkGetPreliminaryByName { name } {
    global userkey

    set name [string map [list " " "%20"] $name]

    set urlSearchByName "http://api-endpoint.igdb.com/games/?search=$name&fields=id,name,cover,screenshots&limit=50"

    set token [http::geturl $urlSearchByName -headers "user-key $userkey" ]
    set resp [http::data $token]
    http::cleanup $token

    return [json::json2dict $resp]
}

proc URLToFilename { URL } {
    set pattern {[^\/]*\.[a-z]{3,4}$}
    regexp $pattern $URL coverFilename
    if {[info exists coverFilename] eq 0} {
        puts "pattern wrong! $URL"
        return ""
    }
    return $coverFilename
}

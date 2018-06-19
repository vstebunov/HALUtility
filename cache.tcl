namespace eval cache {

    variable games

    proc prepareGamesList {} {

        variable games

        #С божьей помощью надеемся что список у нас всегда от 0 и дальше
        #И порядок добавления соответствует индексу иначе всё поломается 
        #
        #name
        #cover
        #uploaded
        #preliminary

        dict set games 0 name "Golden Axe III"
        dict set games 0 cover "cover.jpg"
        dict set games 0 uploaded 1
        dict set games 1 name "Diablo"
        dict set games 1 uploaded 0
        dict set games 2 name "Earthworm%20Jim"
        dict set games 2 uploaded 0

        return $games
    }

    proc preliminaryToEntity {preliminaryIndex gameIndex} {
        variable games

        set game [dict get $games $gameIndex]
        set preliminary [lindex [dict get $game preliminary] $preliminaryIndex]

        dict update games $gameIndex updateGame {
            dict unset updateGame preliminary
            dict set updateGame cover [preliminaryGetCoverFilename $gameIndex $preliminaryIndex]
        }
    }

    proc preliminaryGetCoverFilename {gameIndex preliminaryIndex} {
        return [URLToFilename [preliminaryGetCoverURL $gameIndex $preliminaryIndex]]
    }

    proc preliminaryGetCoverURL {gameIndex preliminaryIndex} {
        variable games

        set game [dict get $games $gameIndex]
        set preliminaryEntry [lindex [dict get $game preliminary] $preliminaryIndex]

        if {[dict exists $preliminaryEntry cover] eq 0} {
            return
        }

        set coverEntry [dict get $preliminaryEntry cover]

        if {[dict exists $coverEntry url] eq 0} {
            return
        }

        return [dict get $coverEntry url]
    }

    proc preliminaryGetScreenshotsFilename {gameIndex preliminaryIndex} {
        variable games

        set game [dict get $games $gameIndex]
        set preliminaryEntry [lindex [dict get $game preliminary] $preliminaryIndex]

        if {[dict exists $preliminaryEntry screenshots] eq 0} {
            return
        }

        set screenshotsEntry [dict get $preliminaryEntry screenshots]

        foreach s $screenshotsEntry {
            if {[dict exists $s url] eq 0} {
                continue
            }
            lappend screenshots [dict get $s url]
        }

        return $screenshots
    }

    proc setPreliminaryToEntity {preliminary gameIndex} {
        variable games

        dict update games $gameIndex updateGame {
            dict set updateGame uploaded 1
            dict set updateGame preliminary $preliminary
        }
    }

    proc get {} {
        variable games
        return $games
    }

}


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

        set coverURL [dict get $coverEntry url]

        set pattern {[^\/]*\.[a-z]{3,4}$}

        regexp $pattern $coverURL coverFilename

        return $coverFilename
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


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
        dict set games 2 name "Earthworm Jim"
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

    proc save {} {
        variable games
        set f [open "cache.dic" wb]
        puts $f $games
        close $f
    }

    proc read {} {
        variable games
        if {[file exists "cache.dic"]} {
            set f [open "cache.dic" r]
            gets $f games
            close $f
            return $games
        } else {
            # Кэш пустой
            # Создать
                # Кэш не удаётся создать
                # Вывести сообщение что работа программы не возможна из-за невозможности
                # записи фалов.
            return [cache::prepareGamesList]
        }
    }

    proc update {listGame} {

        cache::read

        variable games

        set cachedGames ""

        dict for {id game} $games {
            dict with game {
                lappend cachedGames $name 
            }
        }

        set existInXML 0
        foreach cachedName $cachedGames {
            foreach XMLName $listGame {
                if {$XMLName eq $cachedName} {
                    set existInXML 1
                    break
                }
            }

            if {$existInXML eq 0} {
                #remove from dict and cache
                set listGame [lsearch -all -inline -not -exact $listGame $cachedName]
                continue
            }

        }

        foreach XMLName $listGame {
            #add to cache
            set k [dict size $games]

            puts $k
            puts $XMLName

            dict set games $k name $XMLName
            dict set games $k uploaded 0
        }

    }

}


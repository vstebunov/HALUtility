package require Tk
package require Img
package require Thread

# Internal: Check a game list not contain empty space and start with zero
#
# games - Dictionary with games and ids
#
# Examples
#
#   assertGamesIdOrderedAndWithoutEmptySpace( { id 100 game "wrong" } )
#   # => throw an error
#
# Returns nothing and throw error on wrong dictionary
proc assertGamesIdOrderedAndWithoutEmptySpace { games } {
    #С божьей помощью надеемся что список у нас всегда от 0 и дальше
    #И порядок добавления соответствует индексу иначе всё поломается 
    set dictIdOrderChecksum 0
    dict for {id game} $games {
        if {$id != $dictIdOrderChecksum} {
            error "Dictionary doesn't have right order! $id != $dictIdOrderChecksum"
        }
        set dictIdOrderChecksum [expr {$dictIdOrderChecksum + 1}]
    }
}

# Internal: Scale image by factor
#
# im - a image 
# xfactor - a factor for scale by x
# yfactor - a factor for scale by y default 0.0
#
# Examples
#
#   scaleImage $img 0.5
#   #=> img changed
#
# Returns nothing but change an original image
proc scaleImage {im xfactor {yfactor 0.0}} {
    set mode -subsample
    if {abs($xfactor) < 1} {
        set xfactor [expr round(1./$xfactor)]
    } elseif {$xfactor>=0 && $yfactor>=0} {
        set mode -zoom
        set xfactor [expr round($xfactor)]
    }
    if {$yfactor == 0} {set yfactor $xfactor}
    set t [image create photo]
    $t copy $im
    $im blank
    $im copy $t -shrink $mode $xfactor $yfactor
    image delete $t
}

# Internal: Get scale image by cover
# 
# simg - image
# cover - element to cover by image
#
# Examples
#   getScale $simg .window
#   # => 0.5
#
# Returns a scale factor of image
proc getScale {simg cover} {
    set ih [image height $simg]
    set iw [image width $simg]
    set cw [winfo width $cover]
    set ch [winfo height $cover]
    set scaleY [expr double($ch) / $ih]
    set scaleX [expr double($cw) / $iw]
    return $scaleX
}

# Internal: make filename from URL
#
# URL - string with URL and filename
#
# Examples
#   URLToFilename "http://test.com/1.jpg"
#   # => 1.jpg
#
# Returns filename
proc URLToFilename { URL } {
    set pattern {[^\/]*\.[a-z0-9]{3,4}$}
    regexp $pattern $URL coverFilename
    if {[info exists coverFilename] eq 0} {
        puts "pattern wrong! $URL"
        return ""
    }
    return $coverFilename
}

set jobList {}

set threadPool [ tpool::create -initcmd {

    source netgamesdb.tcl

    set jobCache {}

    # Internal: download and cache preliminary and call when all prepare
    #
    # mainThread - thread with window and callback
    # name - name of game to download
    #
    # Examples
    #   downloadPreliminary $windowThread "tetris"
    #
    # Returns nothing
    proc downloadPreliminary {mainThread name} {
        global jobCache
        if {[dict exists $jobCache $name]} {
            set preliminary [dict get $jobCache $name]
        } else {
            set preliminary [networkGetPreliminaryByName $name]
            dict set jobCache $name $preliminary
        }
        thread::send $mainThread [subst {::fillPreliminaryList [list $preliminary $name]}]
    }
}]

# Internal: show main window
#
# games - Dictionary with games from network
#
# Examples
#   showWindow $games
#   # show window with list of games
#
# Returns nothing
proc showWindow {games} {


    # Internal: handle selection of game in main list
    #           show background
    #           show cover
    #           start show it on preliminary list listbox
    #
    # games - Dictionary with games on store
    # threadPool - list with the thread poll that download games
    # jobList - list of current job for download
    #
    # Examples
    #   listSelectionChanged $games 
    #   # => put download in queue
    # 
    # Returns nothing
    proc listSelectionChanged {games threadPool jobList} {
        global name 

        set index [.lb curselection]
        if {![dict exists $games $index]} {
            return
        }

        .lb1 delete 0 [.lb1 size]
        .lb1 configure -state disabled

        if {[dict exists $games $index background] eq 1} {
            set backgroundFilename [dict get $games $index background]
            drawBackground $backgroundFilename
        } else {
            .coverCanvas delete background
        }
        if {[dict exists $games $index cover]} {
            set coverFilename [dict get $games $index cover]
            drawCover $coverFilename
        }

        .cloneButton configure -command ""
        set game [dict get $games $index]
        if {[dict exists $game filePath] ne 0} {
            .cloneButton configure -command "cloneGame {$game} {$games}"
            .cloneButton configure -state normal
        } else {
            .cloneButton configure -state disable
        }

        set name [dict get $games $index name]

        set mainThreadID [thread::id]

        tpool::cancel $threadPool $jobList

        set jobWithNetwork [tpool::post $threadPool [list downloadPreliminary $mainThreadID $name]]

        lappend jobList $jobWithNetwork

    }

    # Internal: fill list after download 
    #           set handler for edit button
    #
    # preliminary - Dictionary with games
    # uploadedName - game of name in main list
    #
    # Examples
    #   fillPreliminaryList {name "tetris"} "tetris"
    #   # => fill listbox if selected name in list equal uploadedName
    #
    # Returns nothing
    proc fillPreliminaryList {preliminary uploadedName} {
        global name

        #puts "fillPreliminaryList $preliminary $uploadedName $name"

        if {$uploadedName ne $name} {
            return
        }

        .lb1 configure -state normal
        foreach entry $preliminary {
            .lb1 insert end [dict get $entry name]
            if {[dict exists $entry cover] eq 0} {
                .lb1 itemconfigure [expr {[.lb1 size] - 1}] -background lightgray
            }
        }


        bind .lb1 <<ListboxSelect>> [list subListSelectionChanged $name $preliminary]
    }


    # Internal: load image from net|cache and draw it on main cover canvas
    #
    # backgroundFilename - string in XML that contains background
    #
    # Examples
    #   drawBackground $str
    #   # => show background
    #
    # Returns nothing
    proc drawBackground {backgroundFilename} {
        if {[string match "file:/data/user/0/net.i.akihiro.halauncher/*" $backgroundFilename]} {
            set renameMap { "file:/data/user/0/net.i.akihiro.halauncher/files" "Backup_HAL/images" }
            set backgroundFilename [string map $renameMap $backgroundFilename]
        } elseif {[string match "android.resource:*" $backgroundFilename]} {
            .coverCanvas delete background
            return
        } else {
            set backgroundFilename cache_img/$backgroundFilename
        }
        set img [image create photo -file $backgroundFilename]
        set scale [getScale $img .coverCanvas]
        scaleImage $img $scale
        .coverCanvas delete background
        .coverCanvas create image 0 0 -anchor nw -image $img -tags background
    }

    # Internal: load cover image and draw it on cover canvas
    #
    # coverFilename - strike in XML that contains covers
    #
    # Examples
    #   drawCover $str
    #   # => show cover
    #
    # Returns nothing
    proc drawCover {coverFilename} {
        .coverCanvas delete cover

        if {[string match "file:/data/user/0/net.i.akihiro.halauncher/*" $coverFilename]} {
            set renameMap { "file:/data/user/0/net.i.akihiro.halauncher/files" "Backup_HAL/images" }
            set coverFilename [string map $renameMap $coverFilename]
        } elseif {[string match "android.resource:*" $coverFilename]} {
            .coverCanvas delete cover
            return
        } else {
            set coverFilename cache_img/$coverFilename
        }

        if {![file exists $coverFilename] || [file isdirectory $coverFilename]} {
            return
        }

        set img [image create photo -file $coverFilename]
        set scale [getScale $img .coverCanvas]
        scaleImage $img [expr $scale * 0.3]
        set x [expr [winfo width .coverCanvas] / 2]
        set y [expr [winfo height .coverCanvas] / 2]
        .coverCanvas create image $x $y -image $img -tags cover
    }

    # Internal: refresh main list by new Dictionary with games
    #
    # games - Dictionary with games
    # threadPool - thread pool for downloading
    # jobList - list of downloading jobs
    #
    # Examples
    #   refreshMainWindow { id 0 game "Tetris" }
    #   # => set new list
    #
    # Returns nothing
    proc refreshMainWindow {games} {
        global threadPool
        global jobList

        .cloneButton configure -state disabled
        .lb delete 0 [.lb size]
        dict for {id game} $games {
            dict with game {
                .lb insert end $name
            }
        }
        bind .lb <<ListboxSelect>> [list listSelectionChanged $games $threadPool $jobList]
    }

    # Internal: save a preliminary item to a main XML
    #
    # name - old name of game
    # game - new entity for game
    #
    # Examples
    #   savePreliminary "Sokoban" { name "Tetris" }
    #   # => save to file and refresh window
    #
    # Returns nothing
    proc savePreliminary {name game} {
        backup::saveToXMLByName $name $game
        refreshMainWindow [backup::readXML]
    }

    # Internal: handle uploaded images in preliminary cover
    #
    # filename - string from json with filename
    # imageIndex - index of uploaded image
    # canvas - canvase to draw image
    # tag - image tag for delete and smth...
    #
    # Examples
    #   set uploadImageHandler as part of uploadImage to work with it
    #
    # Returns nothing and set image in canvas after upload
    proc uploadImageHandler {filename imageIndex canvas tag} {
        set idx [.lb1 curselection]
        if {$idx ne $imageIndex} {
            return
        }
        set img [image create photo -file $filename]
        set scaleX [getScale $img $canvas]
        if {$scaleX ne 0} {
            scaleImage $img $scaleX
        }
        $canvas configure -background gray
        $canvas create image 0 0 -anchor nw -image $img -tags $tag
    }

    # Internal: handle selection of game in preliminary list
    #           upload cover
    #           set handler for save button
    #
    # name - Current name of game in Dictionary
    # preliminary - uploaded from network Dictionary of preliminary games
    #
    # Examples
    #   subListSelectionChanged "testris" {name "testris" cover "xxx.jpg"}
    #   #make all from section
    # 
    # Returns nothing
    proc subListSelectionChanged {name preliminary} {

        .coverCanvas1 delete cover
        .coverCanvas1 delete screenshots

        .coverCanvas1 configure -background yellow

        set index [.lb1 curselection]
        set game [lindex $preliminary $index]
        puts "$index $game"

        if {[dict exists $game cover] ne 0} {
            if {[dict exists [dict get $game cover] url] ne 0} {
                set coverURL [dict get [dict get $game cover] url]
                if {$coverURL ne ""} {
                    set coverFilename cache_img/[URLToFilename $coverURL]
                    if {[file exists $coverFilename]} {
                        set img [image create photo -file $coverFilename]
                        set scaleX [getScale $img .coverCanvas1]
                        if {$scaleX ne 0} {
                            scaleImage $img $scaleX
                        }
                    } else {
                        .coverCanvas1 configure -background green
                        uploadImage $coverFilename $coverURL "cover_big" $index .coverCanvas1 cover uploadImageHandler
                    }
                }
            }
        }

        if {[info exists img]} {
            .coverCanvas1 configure -background gray
            .coverCanvas1 create image 0 0 -anchor nw -image $img -tags cover
        }

        .saveButton configure -command "savePreliminary {$name} {$game}"
    }

    # Internal get files from directory with current game and clone xml and save
    # it
    #
    # game - source game for clone
    #
    # Examples
    #   cloneGame { name "tetris" }
    #   # -> start clone process
    #
    # Returns nothing
    proc cloneGame {game games} {
        set filePath [dict get $game filePath]
        set dirname [tk_chooseDirectory -initialdir ~ -mustexist 1 -title "Where is file?"] 
        if {$dirname eq ""} {
            return
        }
        set filename [URLToFilename $filePath]
        set files [glob -tails -directory $dirname *]
        set filePosition [lsearch -exact $files $filename]
        if {$filePosition eq -1} {
            tk_messageBox -message "File not found! Please set directory with current file $filename" -icon warning -type ok
            return
        }

        dict for {id gm} $games {
            if {[dict exists $gm filePath]} {
                set existedFile [URLToFilename [dict get $gm filePath]]
                set filePosition [lsearch -exact $files $existedFile]
                if {$filePosition ne -1} {
                    set files [lreplace $files $filePosition 1]
                }
            }
        }

        backup::cloneFromIt $game $files

        refreshMainWindow [backup::readXML]

    }

    assertGamesIdOrderedAndWithoutEmptySpace $games

    wm title . "HAL Utility"

    listbox .lb -width 50 -yscrollcommand ".yscroll set" 
    scrollbar .yscroll -command ".lb yview" 
    canvas .coverCanvas
    button .cloneButton -text "Clone by directory"
    entry .currentName -textvariable name 

    listbox .lb1 -width 50 -yscrollcommand ".yscroll1 set"
    scrollbar .yscroll1 -command ".lb1 yview" 
    canvas .coverCanvas1
    button .saveButton -text "Save"

    grid .lb .yscroll .coverCanvas -sticky news -padx 1 -pady 1
    grid .saveButton - .cloneButton -sticky news -padx 1 -pady 1
    grid .currentName -sticky news -padx 1 -pady 1
    grid .lb1 .yscroll1 .coverCanvas1 -sticky news

    refreshMainWindow $games 
}

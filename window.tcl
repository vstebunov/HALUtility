package require Tk
package require Img
#package require Thread

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
    set pattern {[^\/]*\.[a-z]{3,4}$}
    regexp $pattern $URL coverFilename
    if {[info exists coverFilename] eq 0} {
        puts "pattern wrong! $URL"
        return ""
    }
    return $coverFilename
}

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
    #           set handler for edit button
    #           upload preliminary list from internet
    #           show it on preliminary list listbox
    #           set handler for listbox
    #
    # games - Dictionary with games on store
    #
    # Examples
    #   listSelectionChanged $games
    #   #make all from section
    # 
    # Returns nothing
    proc listSelectionChanged {games} {
        global name 

        set index [.lb curselection]
        if {![dict exists $games $index]} {
            return
        }

        .lb1 delete 0 [.lb1 size]

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
        set game [dict get $games $index]
        .editButton configure -command "showSubWindow {$game} $index"

        set name [dict get $games $index name]

        set preliminary [networkGetPreliminaryByName $name]

        foreach x $preliminary {
            .lb1 insert end [dict get $x name]
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
    #
    # Examples
    #   refreshMainWindow { id 0 game "Tetris" }
    #   # => set new list
    #
    # Returns nothing
    proc refreshMainWindow {games} {
        .lb delete 0 [.lb size]
        dict for {id game} $games {
            dict with game {
                .lb insert end $name
            }
        }
        bind .lb <<ListboxSelect>> [list listSelectionChanged $games]
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
        global currentEditableName

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

    assertGamesIdOrderedAndWithoutEmptySpace $games

    wm title . "HAL Utility"

    listbox .lb -width 50 -yscrollcommand ".yscroll set" 
    scrollbar .yscroll -command ".lb yview" 
    canvas .coverCanvas
    button .editButton -text "Edit" 
    entry .currentName -textvariable name 

    listbox .lb1 -width 50 -yscrollcommand ".yscroll1 set"
    scrollbar .yscroll1 -command ".lb1 yview" 
    canvas .coverCanvas1
    button .saveButton -text "Save"

    grid .lb .yscroll .coverCanvas -sticky news -padx 1 -pady 1
    grid .editButton  - .saveButton  -sticky news -padx 1 -pady 1
    grid .currentName -sticky news -padx 1 -pady 1
    grid .lb1 .yscroll1 .coverCanvas1 -sticky news

    refreshMainWindow $games

}

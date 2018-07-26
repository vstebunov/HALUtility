package require Tk
package require Img

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

proc showWindow {games} {
    assertGamesIdOrderedAndWithoutEmptySpace $games
    listbox .lb
    canvas .coverCanvas
    button .editButton -text "Edit" 
    grid .lb .editButton .coverCanvas -sticky ew
    bind . <Destroy> closeWindow

    proc ListSelectionChanged {listbox games} {
        set index [$listbox curselection]
        if {![dict exists $games $index]} {
            return
        }
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
    }

    proc drawBackground {backgroundFilename} {
        if {[string match "file:/data/user/0/net.i.akihiro.halauncher/*" $backgroundFilename]} {
            set backgroundFilename [string map {"file:/data/user/0/net.i.akihiro.halauncher/files" "Backup_HAL/images"} $backgroundFilename]
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

    proc drawCover {coverFilename} {
        .coverCanvas delete cover

        if {[string match "file:/data/user/0/net.i.akihiro.halauncher/*" $coverFilename]} {
            set coverFilename [string map {"file:/data/user/0/net.i.akihiro.halauncher/files" "Backup_HAL/images"} $coverFilename]
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

    proc refreshMainWindow {games} {
        .lb delete 0 [.lb size]
        dict for {id game} $games {
            dict with game {
                .lb insert end $name
            }
        }
        bind .lb <<ListboxSelect>> [list ListSelectionChanged %W $games]
    }

    proc closeWindow {} {
    }

    refreshMainWindow $games
}

proc showSubWindow { game index } {
    global name
    global currentEditableGame
    global currentEditableName

    set currentEditableGame $game

    set name [dict get $game name]
    set currentEditableName $name

    set preliminary [networkGetPreliminaryByName $name]
    set preliminary [linsert $preliminary 0 $game]
    toplevel .subwindow0

    entry .subwindow0.currentName -textvariable name 
    bind .subwindow0.currentName <Return> {recallNetworkDB $name $currentEditableGame}

    listbox .subwindow0.lb1
    canvas .subwindow0.coverCanvas1
    button .subwindow0.saveButton -text "Save"
    #button .subwindow0.lastBackground -text "<< Background" -command "changeBackground"
    #button .subwindow0.nextBackground -text ">>" -command "changeBackground"
    bind .subwindow0.lb1 <<ListboxSelect>> [list SubListSelectionChanged %W $name $preliminary]

    grid .subwindow0.currentName
    grid .subwindow0.lb1 .subwindow0.coverCanvas1 .subwindow0.saveButton -sticky ews

    foreach x $preliminary {
        .subwindow0.lb1 insert end [dict get $x name]
    }

    proc SubListSelectionChanged {listbox name preliminary} {
        global currentEditableName

        .subwindow0.coverCanvas1 delete cover
        .subwindow0.coverCanvas1 delete screenshots
        set index [$listbox curselection]
        set game [lindex $preliminary $index]
        puts "$index $game"

        proc uploadImageHandler {filename imageIndex canvas tag} {
            set idx [.subwindow0.lb1 curselection]
            if {$idx ne $imageIndex} {
                return
            }
            set img [image create photo -file $filename]
            set scaleX [getScale $img $canvas]
            if {$scaleX ne 0} {
                scaleImage $img $scaleX
            }
            $canvas create image 0 0 -anchor nw -image $img -tags $tag
        }

        if {[dict exists $game cover] ne 0} {
            if {[dict exists [dict get $game cover] url] ne 0} {
                set coverURL [dict get [dict get $game cover] url]
                if {$coverURL ne ""} {
                    set coverFilename cache_img/[URLToFilename $coverURL]
                    if {[file exists $coverFilename]} {
                        set img [image create photo -file $coverFilename]
                        set scaleX [getScale $img .subwindow0.coverCanvas1]
                        if {$scaleX ne 0} {
                            scaleImage $img $scaleX
                        }
                    } else {
                        uploadImage $coverFilename $coverURL "cover_big" $index .subwindow0.coverCanvas1 cover uploadImageHandler
                    }
                }
            }
        }

#        if {[dict exists $game screenshots] ne 0} {
#            set screenshots [dict get $game screenshots]
#            foreach URL $screenshots {
#                set realURL [dict get $URL url]
#                if {$realURL ne ""} {
#                    set filename cache_img/[URLToFilename $realURL]
#                    if {[file exists $filename]} {
#                        set simg [image create photo -file $filename]
#                        set scaleX [getScale $simg .subwindow0.coverCanvas1]
#                        if {$scaleX ne 0} {
#                            scaleImage $simg $scaleX
#                        }
#                    } else {
#                        uploadImage $filename $realURL "720p" $index .subwindow0.coverCanvas1 screenshots uploadImageHandler
#                    }
#                }
#            }
#        }

        #if {[info exists simg]} {
        #    .subwindow0.coverCanvas1 create image 0 0 -anchor nw -image $simg -tags screenshots
        #}

        if {[info exists img]} {
            .subwindow0.coverCanvas1 create image 0 0 -anchor nw -image $img -tags cover
        }

        .subwindow0.saveButton configure -command "savePreliminary {$currentEditableName} {$game}"
    }

    proc savePreliminary {name game} {
        backup::saveToXMLByName $name $game
        refreshMainWindow [backup::readXML]
        destroy .subwindow0
    }

    proc changeBackground {} {
    }

    proc recallNetworkDB {name game} {
        .subwindow0.lb1 delete 0 [expr [.subwindow0.lb1 size] - 1]

        set preliminary [networkGetPreliminaryByName $name]
        set preliminary [linsert $preliminary 0 $game]
        foreach x $preliminary {
            .subwindow0.lb1 insert end [dict get $x name]
        }
        bind .subwindow0.lb1 <<ListboxSelect>> [list SubListSelectionChanged %W $name $preliminary]
    }

}

proc getScale {simg cover} {
    set ih [image height $simg]
    set iw [image width $simg]
    set cw [winfo width $cover]
    set ch [winfo height $cover]
    set scaleY [expr double($ch) / $ih]
    set scaleX [expr double($cw) / $iw]
    return $scaleX
}

package require tdom

namespace eval backup {

    # Internal: read a backup HAL XML and parse it to a dictionary
    #
    # Returns a dictionary with games
    proc readXML {} {
        set filename "Backup_HAL/_serialized_AppList.dat.xml"

        #Read
        set f [open $filename]
        set doc [dom parse [read $f]]
        close $f

        set root [$doc documentElement]
        set xpath2 {//net.i.akihiro.halauncher.data.AppItem}

        set i 0
        foreach appItem [$root selectNode $xpath2] {
            dict set xmlGames $i id $i
            dict set xmlGames $i name [[$appItem selectNodes {title/text()}] nodeValue]
            dict set xmlGames $i uploaded 1
            if {[$appItem selectNodes {bgImageUrl/text()}] ne ""} {
                dict set xmlGames $i background [[$appItem selectNodes {bgImageUrl/text()}] nodeValue]
            }
            if {[$appItem selectNodes {cardImageUrl/text()}] ne ""} {
                dict set xmlGames $i cover [[$appItem selectNodes {cardImageUrl/text()}] nodeValue]
            }
            if {[$appItem selectNodes {intentInfo/data/text()}] ne ""} {
                dict set xmlGames $i filePath [[$appItem selectNodes {intentInfo/data/text()}] nodeValue]
            }

            incr i
        }

        return $xmlGames
    }

    # Internal: save in a backup XML from dictionary
    #
    # name - string for finding entity in XML
    # game - new entity with game
    #
    # Examples
    #   saveToXMLByName "Tetris" {id 0 name Tetris}
    #   # => saved to backup
    #
    # Returns nothing
    proc saveToXMLByName {name game} {
        set filename "Backup_HAL/_serialized_AppList.dat.xml"
        #Read
        set f [open $filename]
        set doc [dom parse [read $f]]
        close $f
        #Search
        set root [$doc documentElement]
        set xpath2 {//net.i.akihiro.halauncher.data.AppItem}

        foreach test [$root selectNode $xpath2] {
            foreach node [$test selectNodes title/text()[format {[contains(., "%s")]} $name]] {
                #Set
                $node nodeValue [dict get $game name]
                set parent [[$node parentNode] parentNode]
                foreach sib [$parent selectNodes cardImageUrl/text()] {
                    if {[copyImageToBackup [dict get $game cover]]} {
                        set coverURL [dict get [dict get $game cover] url]
                        set fn [URLToFilename $coverURL]
                        $sib nodeValue "file:/data/user/0/net.i.akihiro.halauncher/files/$fn"
                    }
                }
            }
        }
        #Save
        set changed [$doc asXML]
        set fileId [open $filename "w"]
        puts -nonewline $fileId $changed
        close $fileId
    }

    # Internal: place an image in a directory with a backup XML
    #
    # image - dictionary entity with game image
    #
    # Examples
    #   copyImageToBackup { url test.jpg }
    #   # => true and copy to directory
    #
    # Returns true when an image in a directory and false when image not finded
    proc copyImageToBackup {image} {
        set coverURL [dict get $image url]
        set destCoverFilename [URLToFilename $coverURL]
        if {$coverURL ne ""} {
            set coverFilename cache_img/$destCoverFilename
            if {[file exists Backup_HAL/images/$destCoverFilename]} {
                return true
            }
            if {[file exists $coverFilename] && ![file exists Backup_HAL/images/$destCoverFilename]} {
                file copy $coverFilename Backup_HAL/images/$destCoverFilename
                return true
            } 
        }
        return false
    }

    # Internal: find node in XML and paste new nodes after it
    #
    # src - source game 
    # newcomers - games for paste
    #
    # Examples
    #   cloneFromIt { name "tetris" } { { name "xxx" } { name "yyy" } }
    #
    # Returns nothing
    proc cloneFromIt {src newcomers} {
        set XMLfilename "Backup_HAL/_serialized_AppList.dat.xml"
        #Read
        set f [open $XMLfilename]
        set doc [dom parse [read $f]]
        close $f

        set root [$doc documentElement]
        set xpath2 {//net.i.akihiro.halauncher.data.AppItem}

        set filePath [dict get $src filePath]

        set filename [URLToFilename $filePath]

        foreach test [$root selectNode $xpath2] {
            foreach node [$test selectNodes intentInfo/data/text()[format {[contains(., "%s")]} $filePath]] {
                set srcNode [[[$node parentNode] parentNode] parentNode]
                set prntNode [$srcNode parentNode]

                foreach n $newcomers {
                    set renameMap "{$filename} {$n}"
                    set newPath [string map $renameMap $filePath]

                    set renameName "{[dict get $src name]} {$n}"
                    set renamePath "{$filePath} {$newPath}"

                    $prntNode appendXML [string map "$renamePath $renameName" [$srcNode asXML]]
                }

                break
            }
        }

        #Save
        set changed [$doc asXML]
        set fileId [open $XMLfilename w]
        puts -nonewline $fileId $changed
        close $fileId
    }

}


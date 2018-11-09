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
        foreach test [$root selectNode $xpath2] {
            dict set xmlGames $i id $i
            dict set xmlGames $i name [[$test selectNodes {title/text()}] nodeValue]
            dict set xmlGames $i uploaded 1
            if {[$test selectNodes {bgImageUrl/text()}] ne ""} {
                dict set xmlGames $i background [[$test selectNodes {bgImageUrl/text()}] nodeValue]
            }
            if {[$test selectNodes {cardImageUrl/text()}] ne ""} {
                dict set xmlGames $i cover [[$test selectNodes {cardImageUrl/text()}] nodeValue]
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

}


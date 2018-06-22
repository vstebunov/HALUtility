lappend ::auto_path [file dirname [zvfs::list */tdom/pkgIndex.tcl]]

package require tdom

namespace eval backup {

    variable li

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

}


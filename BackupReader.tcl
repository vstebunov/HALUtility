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

        set xpath {//net.i.akihiro.halauncher.data.AppItem/title/text()}

        set game_name {}

        foreach test [$root selectNode $xpath] {
            #puts [$test nodeName]
            lappend game_name [$test nodeValue]
        }

        set li [lsort -dictionary -unique $game_name]
        return $li
    }

}


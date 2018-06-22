namespace eval initiator {

    variable config

    proc read {} {
        variable config
        if {[file exists "init.dic"]} {
            set f [open "init.dic" r]
            gets $f config
            close $f
            return $config
        } else {
            return 0
        }
    }

}


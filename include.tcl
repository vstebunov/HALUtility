if {(zvfs)} {
    lappend ::auto_path [file dirname [zvfs::list */tdom/pkgIndex.tcl]]
    lappend ::auto_path [file dirname [zvfs::list */Img-win64/pkgIndex.tcl]]
}

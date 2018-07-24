if {[namespace exists ::freewrap]} {
    lappend ::auto_path [file dirname [zvfs::list */tdom/pkgIndex.tcl]]
    lappend ::auto_path [file dirname [zvfs::list */Img-win64/pkgIndex.tcl]]
    console show
}

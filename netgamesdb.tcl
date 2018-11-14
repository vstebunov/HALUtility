package require http
package require json

source config.tcl

# Internal: upload image from site and call handler
#
# filename - file name from json
# URL - url from it to be downloaded
# size - specifiactor for image size by default empty
# index - index for handler
# canvas - canvas for handler
# tag - for handler
# handler - hadler that calls after downloading
#
# Examples
#   uploadImage "i.jpg" "/test.com/" "XL"
#   # => 1 after good download
#
# Returns 0 for error and 1 for success and call handler on good path
proc uploadImage {filename URL {size ""} index canvas tag handler} {
    puts $filename

    if {$size ne ""} {
        set URL [string map [list thumb $size] $URL]
    }

    puts $URL

    set f [open $filename wb]
    set tok [http::geturl "http:$URL" -channel $f -binary 1]
    close $f

    if {[http::status $tok] eq "ok" && [http::ncode $tok] == 200} {
        puts "Downloaded successfully http:$URL"
    } else {
        puts "Download wrong! http:$URL"
        file delete $filename
        return 0
    }
    http::cleanup $tok
    $handler $filename $index $canvas $tag
    return 1
}

# Internal: download json by requesting name of game
#
# name - string with name of game (non-normalized)
#
# Examples
#   networkGetPreliminaryByName "Tetris"
#   # => { name "Testris" cover "1.jpg" }
#
# Returns Dictionary with preliminary
proc networkGetPreliminaryByName { name } {
    global userkey

    set name [string map [list " " "%20" "!" "%20" "\[" "%20" "\]" "%20"] $name]

    set urlSearchByName "http://api-endpoint.igdb.com/games/?search=$name&fields=id,name,cover,screenshots&limit=50"

    #puts $urlSearchByName

    set token [http::geturl $urlSearchByName -headers "user-key $userkey" ]
    set resp [http::data $token]
    http::cleanup $token

    return [json::json2dict $resp]
}

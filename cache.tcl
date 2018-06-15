proc prepareGamesList {} {

    #С божьей помощью надеемся что список у нас всегда от 0 и дальше
    #И порядок добавления соответствует индексу иначе всё поломается 
    #
    #name
    #cover
    #uploaded
    #preliminary

    dict set games 0 name "Golden Axe III"
    dict set games 0 cover "cover.jpg"
    dict set games 0 uploaded 1
    dict set games 1 name "Diablo"
    dict set games 1 uploaded 0

    return $games
}

namespace eval windowState {
    variable xy 0
    proc setState {x} {
        variable xy $x
        puts "setState $x"
    }
    proc getState {} {
        variable xy
        puts $xy
    }
}


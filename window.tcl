lappend ::auto_path [file dirname [zvfs::list */Img-win64/pkgIndex.tcl]]

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


proc scaleImage {im xfactor {yfactor 0}} {
    set mode -subsample
    if {abs($xfactor) < 1} {
        set xfactor [expr round(1./$xfactor)]
    } elseif {$xfactor>=0 && $yfactor>=0} {
        set mode -zoom
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

    grid .lb .coverCanvas -sticky ew

    proc ListSelectionChanged {listbox games} {

        set index [$listbox curselection]

        #Проверить что это новое пополнение
        if {[dict exists $games $index preliminary] eq 1} {
            #Вывести окно с названиями и картинками для выбора настоящего
            showSubWindow $games $index
            return 
        }

        #Проверить что картинка существует
        if {[dict exists $games $index cover] eq 0} {
            error "Link to cover not exists!"
        }

        # Загрузить картинку зная что выбранно
        set coverFilename [dict get $games $index cover]

        #Проверить что файл с таким именем существует

        set img [image create photo -file $coverFilename]

        # Сделать картинку по размеру окна
        scaleImage $img 0.2

        #Стереть старую картинку
        .coverCanvas delete cover
        
        # Вывести картинку
        .coverCanvas create image 0 0 -anchor nw -image $img -tags cover
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

    refreshMainWindow $games
}

proc showSubWindow { games index } {

    set preliminary [dict get $games $index preliminary]

    toplevel .subwindow0

    listbox .subwindow0.lb1

    foreach x $preliminary {
        .subwindow0.lb1 insert end [dict get $x name]
    }

    canvas .subwindow0.coverCanvas1

    button .subwindow0.saveButton -text "Save" -command "savePreliminary .subwindow0.lb1 $index"
    button .subwindow0.lastCover -text "<< Cover" -command "changeCover"
    button .subwindow0.nextCover -text ">>" -command "changeCover"
    button .subwindow0.lastBackground -text "<< Background" -command "changeBackground"
    button .subwindow0.nextBackground -text ">>" -command "changeBackground"

    grid .subwindow0.lb1 .subwindow0.coverCanvas1 .subwindow0.lastCover .subwindow0.nextCover .subwindow0.lastBackground .subwindow0.nextBackground .subwindow0.saveButton -sticky ews

    bind .subwindow0.lb1 <<ListboxSelect>> [list SubListSelectionChanged %W $index $preliminary]

    proc SubListSelectionChanged {listbox gameIndex preliminary} {

        #Очищать картинку если её нет
        .subwindow0.coverCanvas1 delete cover
        .subwindow0.coverCanvas1 delete screenshots

        #Выгружать картинки побольше
        #Сохранять картинку и игру

        set index [$listbox curselection]

        set coverURL [cache::preliminaryGetCoverURL $gameIndex $index]
        set coverFilename [cache::preliminaryGetCoverFilename $gameIndex $index]

        if {$coverFilename ne "" && ![file exists $coverFilename]} {
            uploadImage $coverFilename $coverURL "cover_big"
        } else {
            set img [image create photo -file $coverFilename]
        }

        set screenshots [cache::preliminaryGetScreenshotsFilename $gameIndex $index]

        foreach URL $screenshots {
            set filename [URLToFilename $URL]
            if {$filename ne "" && ![file exists $filename]} {
                uploadImage $filename $URL "720p"
            } else {
                set simg [image create photo -file $filename]

                set ih [image height $simg]
                set iw [image width $simg]

                set cw [winfo width .subwindow0.coverCanvas1]
                set ch [winfo height .subwindow0.coverCanvas1]

                set scaleY [expr double($ch) / $ih]
                set scaleX [expr double($cw) / $iw]

                if {$scaleX ne 0 && $scaleY ne 0} {
                    #scaleImage $simg $scaleX $scaleY
                    scaleImage $simg $scaleX
                }

                .subwindow0.coverCanvas1 create image 0 0 -anchor nw -image $simg -tags screenshots
            }
        }

        if {[info exists img] eq 1} {
            # Вывести картинку
            .subwindow0.coverCanvas1 create image 0 0 -anchor nw -image $img -tags cover
        }
    }

    proc savePreliminary {listbox gameIndex} {
        set preliminaryIndex [$listbox curselection]

        cache::preliminaryToEntity $preliminaryIndex $gameIndex

        refreshMainWindow [cache::get]

        destroy .subwindow0
    }

    proc changeBackground {} {
    }

    proc changeCover {} {
    }

}

# Взять список новых для кэша

    # Загрузить список возможных вариантов
        # Загрузка не получилась вывести что нет свзяи с инетом или БД
    # Данные не совпадают с форматом
        # Вывести что форматы не совпадают
    # Список пуст
        # Добавить флаг не содержится в БД
    # Список из одного элемента
        # Добавить этот элемент как единственный распарсив и поставив ковер по
        # умолчанию и данные в кэш
    # Список из многих элементов
        # Отметить флагом множественность вариантов
        # Подгрузить каждый вариант с доп инфой и кавером и сохранить в кэш эти
        # данные

# Вывести окно со списком и вариантами подстановки
    # Прочитать кэш
    # Нарисовать список с подсписками
    # Поставить обработчик
    # При выборе элемента подгружать его
        # Можно выбрать иконку и бэкграунд из всего списка связанных с этим
        # картинок 
        # Можно выбрать другое название и поискать по нему игру БД
        # Можно удалить из списка элемент
        # Сохранить 

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


proc scaleImage {im xfactor {yfactor 0.0}} {
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

    button .editButton -text "Edit" -command {
        puts $games
    }

    grid .lb .editButton .coverCanvas -sticky ew

    bind . <Destroy> closeWindow

    proc ListSelectionChanged {listbox games} {

        variable index

        set index [$listbox curselection]

        #Проверить что это новое пополнение
        if {[dict exists $games $index preliminary] eq 1} {
            #Вывести окно с названиями и картинками для выбора настоящего
            showSubWindow $games $index
            return 
        }

        if {[dict exists $games $index background] eq 1} {
            set backgroundFilename [dict get $games $index background]
            drawBackground $backgroundFilename
        } else {
            .coverCanvas delete background
        }

        #Проверить что картинка существует
        if {[dict exists $games $index cover] eq 0} {
            error "Link to cover not exists!"
        }

        set coverFilename [dict get $games $index cover]

        drawCover $coverFilename
    }

    proc drawBackground {backgroundFilename} {
        # Загрузить картинку зная что выбранно
        # Проверить что файл с таким именем существует

        if {[string match "file:/data/user/0/net.i.akihiro.halauncher/*" $backgroundFilename]} {
            set backgroundFilename [string map {"file:/data/user/0/net.i.akihiro.halauncher/files" "Backup_HAL/images"} $backgroundFilename]
        } elseif {[string match "android.resource:*" $backgroundFilename]} {

            puts "test"
            .coverCanvas delete background

            return
        } else {
            set backgroundFilename cache_img/$backgroundFilename
        }

        set img [image create photo -file $backgroundFilename]

        # Сделать картинку по размеру окна

        set scale [getScale $img .coverCanvas]
        scaleImage $img $scale

        #Стереть старую картинку
        .coverCanvas delete background
        
        # Вывести картинку
        .coverCanvas create image 0 0 -anchor nw -image $img -tags background
    }

    proc drawCover {coverFilename} {
        # Загрузить картинку зная что выбранно
        # Проверить что файл с таким именем существует

        if {[string match "file:/data/user/0/net.i.akihiro.halauncher/*" $coverFilename]} {
            set coverFilename [string map {"file:/data/user/0/net.i.akihiro.halauncher/files" "Backup_HAL/images"} $coverFilename]
        } elseif {[string match "android.resource:*" $coverFilename]} {

            .coverCanvas delete cover

            return
        } else {
            set coverFilename cache_img/$coverFilename
        }

        set img [image create photo -file $coverFilename]

        # Сделать картинку по размеру окна
        set scale [getScale $img .coverCanvas]
        scaleImage $img [expr $scale * 0.3]

        #Стереть старую картинку
        .coverCanvas delete cover
        

        set x [expr [winfo width .coverCanvas] / 2]
        set y [expr [winfo height .coverCanvas] / 2]
        # Вывести картинку
        .coverCanvas create image $x $y -image $img -tags cover
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

    proc closeWindow {} {
        cache::save
    }

    proc showEditWindow {games} {
        variable index
        puts [info vars]
        showSubWindow $games $index
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
        set coverFilename cache_img/[cache::preliminaryGetCoverFilename $gameIndex $index]

        if {$coverFilename ne "" && ![file exists $coverFilename]} {
            uploadImage $coverFilename $coverURL "cover_big"
        } else {
            set img [image create photo -file $coverFilename]
        }

        set screenshots [cache::preliminaryGetScreenshotsFilename $gameIndex $index]

        foreach URL $screenshots {
            set filename cache_img/[URLToFilename $URL]
            if {$filename ne "" && ![file exists $filename]} {
                uploadImage $filename $URL "720p"
            } else {
                set simg [image create photo -file $filename]

                set $scaleX [getScale $simg .subwindow0.coverCanvas1]
                if {$scaleX ne 0} {
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

proc getScale {simg cover} {
    set ih [image height $simg]
    set iw [image width $simg]

    set cw [winfo width $cover]
    set ch [winfo height $cover]

    set scaleY [expr double($ch) / $ih]
    set scaleX [expr double($cw) / $iw]

    return $scaleX
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

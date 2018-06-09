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

proc showWindow { games } {

    assertGamesIdOrderedAndWithoutEmptySpace $games

    listbox .lb

    dict for {id game} $games {
        dict with game {
            .lb insert end $name
        }
    }

    bind .lb <<ListboxSelect>> [list ListSelectionChanged %W $games]

    canvas .coverCanvas

    grid .lb .coverCanvas -sticky ew

    proc ListSelectionChanged {listbox games} {

        set index [$listbox curselection]

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
        
        # Вывести картинку
        .coverCanvas create image 0 0 -anchor nw -image $img
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

lappend ::auto_path [file dirname [zvfs::list */Img-win64/pkgIndex.tcl]]

package require Tk
package require Img

proc prepareGamesList {} {

    #С божьей помощью надеемся что список у нас всегда от 0 и дальше
    #И порядок добавления соответствует индексу иначе всё поломается 

    dict set games 0 name "Golden Axe III"
    dict set games 0 cover "cover.jpg"
    dict set games 1 name "Diablo"
    dict set games 1 cover "cover2.jpg"

    return $games
}

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

proc showWindow { games } {

    assertGamesIdOrderedAndWithoutEmptySpace $games

    listbox .lb

    dict for {id game} $games {
        dict with game {
            .lb insert end $name
        }
    }

    bind .lb <<ListboxSelect>> [list ListSelectionChanged %W $games]

    canvas .c

    grid .lb .c -sticky ew

    proc ListSelectionChanged {listbox games} {

        set index [$listbox curselection]

        #Проверить что картинка существует
        if {[dict exists $games $index cover] eq 0} {
            error "Link to cover not exists!"
        }

        # Загрузить картинку зная что выбранно
        set coverFilename [dict get $games $index cover]

        #Проверить что файл с таким именем существует

        set img [image create photo -file $coverFilename ]

        # Сделать картинку по размеру окна
        
        # Вывести картинку
        .c create image 0 0 -anchor nw -image $img
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

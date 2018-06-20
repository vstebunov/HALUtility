source cache.tcl
source window.tcl
source netgamesdb.tcl

# Проверить есть ли прошлый вариант

    # Проверить рабочий ли прошлый вариант

    # Найти файл если прошлый вариант не рабочий

    # Файл не найден и прошлого варианта нет. 
        # Вывести сообщение 
        # предложить загрузить любой файл

# Прочитать файл

    # Файл пустой
    # Файл не читается
    # Файл не содержит необходимых полей
        # Вывести сообщение 
        # предложить выбрать другой файл
    
# Прочитать кэш
    set cache [cache::read]

    #Кэш не совпадает с настоящим файлом
        #Добавить в кэш новые записи 
        #Пометить их как новые
            # Кэш не удаётся создать
            # Вывести сообщение что работа программы не возможна из-за невозможности
            # записи фалов.

# Пройтись по кэшу 

    # Достать иконку, бэкграунд, айди в БД, название пользователя, название в БД,
    # категории в БД, ссылку на программу, категорию,
    # возможные картинки
    # флаг о том что это новое 

# Взять список новых для кэша

    console show
    set cacheWithUploads [uploadFromCache $cache]
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

    showWindow $cacheWithUploads

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

# Сохранить варианты и выйти
    # Сохранить в кэш
    # Преобразовать кэш в выходной файл
    # Сохранить файл и старую версию

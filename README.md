# HALUtility

## version 0.9.0.1

### Пролог

Мне надоело править через свою приставку HALauncher и для этого я написал
скрипт который позволяет загружать из сети с сайта IGDB.com обложки и скриншоты
и полные названия для игр и подставлять их вместо имеющихся.

### Как скомпилировать

Я компилировал для двух платформ Windows 7 и Debian. 

#### Windows 7

Я воспользовался пакетом freewrap и дополнительными библиотеками Img-win64 и
tdom их нужно скачать и положить в ту же папку что и сама программа.

#### Debian

Нужно дополнительно установить библиотеки через консоль и запустить через tclsh

### Как работать

1. Сделать в HALauncher бэкап текущего состояния
2. Скопировать его в папку со скриптом
3. Запустить скрипт и выбрать редактируемую иконку
4. Нажать кнопку save после того как выбраны новые иконки
5. Скопировать папку обратно на старое место


Utility for HALauncher

They could now:

+ Load predefined list of games
+ Show predefined list of games
+ Download search from igdb 
+ Download screenshot from igdb
+ Download different size of image
+ Resize image to canvas and show it on right aligment
+ Read and save games to cache
+ Sanitize name before make call to server
+ Read predefined XML
+ Save cache img to different directory
+ Read cover and background from XML
+ Show cover and background on window
+ Remove unused cache call
+ Show cover and background with ratio
+ Show cover on center
+ Add Edit button
+ Download screenshots after Edit clicked
+ Show scaled image without error
+ Save changed name to XML
+ Save changed cover to XML and copy to backup
+ Run on Ubuntu (with simple edition)
+ Run on Ubuntu (as is)
+ Run on Windows
+ File cache.dic don't created
+ Don't show error when cover not exists
+ Load cover first
+ Clear old cover
+ Show loaded cover and background for current game
+ Don't show error on Ubuntu when start subwindow
+ Add current view as first element on subwindow
+ User could rename game and search it in preliminary

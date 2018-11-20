# HALUtility

version 0.9.0.2

Edit your HAL backup file and upload game images and titles from IGDB.

![img](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/screenshot.png)

Before

![before](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/before.png)

After

![after](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/after.png)

## Download and Run

[Download](https://github.com/vstebunov/HALUtility/releases/download/v.0.1.1/halutility_x64.exe)

## Usage

+ __Before start make backup of your backup of HALauncher!__

+ Make backup of your HALauncher 

![save-restore](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/save-restore.png)

+ Click save on screen

![screen](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/save-restore-screen.png)

+ Copy HALBackup directory to directory with HALUtility

+ Run

![img](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/screenshot.png)

    + First list - your current apps in backup
    + Current cover of selected application
    + Input for editing name of selected application
    + Button Search for search in IGDB 
    + Button Save for saving suggestion in backup
    + Result list with suggestions from IGDB
    + Button Clone by directory. If you have a directory full of roms. You can create one shortcut that contains one rom from this directory.
        + Choose that shortcut
        + Click Clone by directory
        + Choose the directory with this rom
        + All files will be cloned to this list

+ Copy HALBackup to source directory

+ Restore from backup

![screen](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/save-restore-screen.png)

## Contributing

Pull requests are welcome.

## License
[MIT](https://choosealicense.com/licenses/mit/)

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

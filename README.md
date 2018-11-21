# HALUtility

version 0.9.0.2

Edit your HAL backup file and upload game images and titles from IGDB.

![img](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/screenshot.png)

Before

![before](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/before.png)

After

![after](https://raw.githubusercontent.com/vstebunov/HALUtility/master/imgs/after.png)

## Download and Run

[Download](https://github.com/vstebunov/HALUtility/releases/download/0.9.0.2/halutility_x64.exe)

## Usage

+ __Before start make backup of your BackupHAL directory!__

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

+ That's all

## Contributing

Pull requests are welcome.

For developing you need additional library:

* Threads
* Img
* tdom

On linux you need to install it by apt-get

On windows you need to download Img and tdom and use FreeWrap

## License

[MIT](https://choosealicense.com/licenses/mit/)

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

#0 {name {Golden Axe III} cover cover.jpg uploaded 1} 1 {name Diablo uploaded 1 gameDBID {{id 125} {id 101207} {id 47452} {id 246} {id 38659} {id 3182} {id 90628} {id 20057} {id 126} {id 120}} preliminary {{{id 101207 name DiabloSlayer}} {{id 246 name {Diablo II: Lord of Destruction} screenshots {{url //images.igdb.com/igdb/image/upload/t_thumb/vdtrupxiet21znw0jmo4.jpg cloudinary_id vdtrupxiet21znw0jmo4 width 800 height 600} {url //images.igdb.com/igdb/image/upload/t_thumb/u4dsjjjgneqxqug0krwe.jpg cloudinary_id u4dsjjjgneqxqug0krwe width 800 height 600}} cover {url //images.igdb.com/igdb/image/upload/t_thumb/kfvnrf9jgsib4kym8gbn.jpg cloudinary_id kfvnrf9jgsib4kym8gbn width 394 height 500}}} {{id 3182 name {Diablo III: Reaper of Souls} screenshots {{url //images.igdb.com/igdb/image/upload/t_thumb/ksobg1idwl6gn89d46w7.jpg cloudinary_id ksobg1idwl6gn89d46w7 width 1920 height 1080} {url //images.igdb.com/igdb/image/upload/t_thumb/fsyoqfsz51n2y82qbbj2.jpg cloudinary_id fsyoqfsz51n2y82qbbj2 width 1920 height 1080} {url //images.igdb.com/igdb/image/upload/t_thumb/quuu3tvcq0jy9rs0bjzp.jpg cloudinary_id quuu3tvcq0jy9rs0bjzp width 1920 height 1080}} cover {url //images.igdb.com/igdb/image/upload/t_thumb/qbgh5zqabojbi9ftnujg.jpg cloudinary_id qbgh5zqabojbi9ftnujg width 1057 height 1500}}} {{id 20057 name {duplicate Diablo III: Ultimate Evil Edition} screenshots {{url //images.igdb.com/igdb/image/upload/t_thumb/oocwtypeycfx4vacuoyu.jpg cloudinary_id oocwtypeycfx4vacuoyu width 1145 height 641}}}} {{id 120 name {Diablo III} screenshots {{url //images.igdb.com/igdb/image/upload/t_thumb/auqwklwf1olq6obxzw89.jpg cloudinary_id auqwklwf1olq6obxzw89 width 1920 height 1080} {url //images.igdb.com/igdb/image/upload/t_thumb/dg58xb7dullhcvrlenxm.jpg cloudinary_id dg58xb7dullhcvrlenxm width 704 height 396} {url //images.igdb.com/igdb/image/upload/t_thumb/sq4xtjnigqionni9pdet.jpg cloudinary_id sq4xtjnigqionni9pdet width 704 height 440} {url //images.igdb.com/igdb/image/upload/t_thumb/rj1rbspgpom5xt7tgsej.jpg cloudinary_id rj1rbspgpom5xt7tgsej width 704 height 396} {url //images.igdb.com/igdb/image/upload/t_thumb/c7e3ld6bqctsg82n5wvh.jpg cloudinary_id c7e3ld6bqctsg82n5wvh width 704 height 396}} cover {url //images.igdb.com/igdb/image/upload/t_thumb/hohtqw21z8ucbsylj7i1.jpg cloudinary_id hohtqw21z8ucbsylj7i1 width 640 height 906}}}}}

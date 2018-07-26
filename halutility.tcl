source include.tcl
source window.tcl
source netgamesdb.tcl
source BackupReader.tcl

set XMLList [backup::readXML]
showWindow $XMLList

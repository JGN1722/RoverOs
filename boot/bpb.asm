    nop						;nop
    bsOEMString		db "RoverOS "		; OEM String,8 bytes ASCII code
    bsSectSize		dw 0x0200 		; Bytes per sector
    bsClusterSize	db 0x01			; Sectors per cluster
    bsReservedSect	dw 0x0001		; # of reserved sectors
    bsFatCount		db 0x02			; # of fat
    bsRootDirSize	dw 0x00e0 		; size of root directory
    bsTotalSect		dw 0x0b40		; total # of sectors if < 32 meg
    bsMediaType		db 0xf0			; Media Descriptor
    bsSectPerFat	dw 0x0009		; Sectors per FAT
    bsSectPerTrack	dw 0x0012		; Sectors per track
    bsHeadCount		dw 0x0002		; number of read-write heads
    bsHiddenSect	dd 0x00000000		; number of hidden sectors
    bsHugeSect		dd 0x00000000		; if bsTotalSect is 0 this value is the number of sectors
    bsBootDrv		db 0x00			; holds drive that the bs came from
			db 0x00			; not used for anything
    bsBootSign		db 0x29 		; boot signature 29h
    bsVolumeID		dd 0x0214FABE		; Disk volume ID also used for temp sector # / # sectors to load
    bsVolumeLabel	db 'RoverOSVOL '	; Volume Label
    bsFSType		db 'FAT12    ' 	  	; File System type <- FAT 12 File system

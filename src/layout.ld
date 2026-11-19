ENTRY(bootstrap)
SECTIONS {
    . = 0x7c00;
    .bootstrap : { *(.bootstrap) }
    .kernel : { *(.text*) *(.rodata*) }
    .signature 0x7dfe : { SHORT(0xaa55) }
}

/* Early diagnostic on the QEMU PC's first serial port. */
static void write_port(unsigned short port, unsigned char value)
{
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

void kernel_entry(void)
{
    const unsigned short uart = 0x3f8;
    write_port(uart + 3, 0x80);
    write_port(uart, 1);
    write_port(uart + 1, 0);
    write_port(uart + 3, 3);

    for (const char *p = "Hello from LibreVMS! :)\r\n"; *p; ++p) {
        unsigned char status;
        do {
            __asm__ volatile ("inb %1, %0" : "=a"(status) : "Nd"((unsigned short)(uart + 5)));
        } while (!(status & 0x20));
        write_port(uart, *p);
    }
}

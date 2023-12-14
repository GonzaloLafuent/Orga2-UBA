/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
  // Inicializamos PIC1
  outb(PIC1_PORT,0x11);  // ICW1: IRQs activas por flanco, modo cascada ICW4 Si
  outb(PIC1_PORT + 1,0x20); // ICW2: INT base para el 
  outb(PIC1_PORT + 1,0x04); // ICW3: PIC1 Master, tiene un Slave conectado a IRQ2
  outb(PIC1_PORT + 1,0x01); // ICW4: Modo No Buffered, Fin de Interrupcion Normal
  outb(PIC1_PORT + 1,0xFF); // OCW1: Set o Clearel IMR

  // Inicializamos PIC2
  outb(PIC2_PORT,0x11);  // ICW1: IRQs activas por flanco, modo cascada ICW4 Si
  outb(PIC2_PORT + 1,0x28); // ICW2: INT base para el 
  outb(PIC2_PORT + 1,0x02); // ICW3: PIC1 Master, tiene un Slave conectado a IRQ2
  outb(PIC2_PORT + 1,0x1); // ICW4: Modo No Buffered, Fin de Interrupcion Normal
  outb(PIC2_PORT + 1,0xff); // OCW1: Set o Clearel IMR

}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
  // intentamos hacer el 12? pero no entendemos como es la cuenta ni qué
  // tendriamos que escribir
  outb(0x40,0xFF);
  outb(0x40,0xFF);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}

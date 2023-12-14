/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {

}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  paddr_t free_page = next_free_kernel_page;
  next_free_kernel_page+=PAGE_SIZE;
  return free_page;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  paddr_t free_page = next_free_user_page;
  next_free_user_page+=PAGE_SIZE;
  return free_page;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
  zero_page(KERNEL_PAGE_TABLE_0);
  zero_page(KERNEL_PAGE_DIR);

  // kpd es un puntero a KERNEL_PAGE_DIR
  kpd[0].attrs = MMU_P | MMU_W; 
  kpd[0].pt = KERNEL_PAGE_TABLE_0 >> 12; 
  //  Para cada una de las entrys de la tabla de paginas creo una PageTableEntry con sus atributos y la base
  for (int i = 0; i < 1024; i++) {
    // kpt es un puntero a KERNEL_PAGE_TABLE
    kpt[i].attrs = MMU_P | MMU_W;
    kpt[i].page = VIRT_PAGE_TABLE(i * PAGE_SIZE);
  }
  return KERNEL_PAGE_DIR;
}

/** 
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {
  pd_entry_t* pageDirectory = (pd_entry_t*)(CR3_TO_PAGE_DIR(cr3));
  int pd_index = VIRT_PAGE_DIR(virt);
  int pt_index = VIRT_PAGE_TABLE(virt);
  // Si el bit P de la PDE es 0
  if((pageDirectory[pd_index].attrs & MMU_P) == 0){ 
    paddr_t new_pt = mmu_next_free_kernel_page(); // Pido una nueva pagina 
    zero_page(new_pt); // La cargo con 0s
    // Completo la PD
    pageDirectory[pd_index].pt = (new_pt >> 12);  // Me quedo con los 20 bits mas significativos
  }
  pageDirectory[pd_index].attrs |= attrs | MMU_P; // Seteo el bit P de la PDE en 1
  // Obtengo la PT de la PD
  pt_entry_t* pageTable = (pt_entry_t*)(pageDirectory[pd_index].pt << 12); // Me quedo con los 20 bits mas significativos 
  // Completo la PTE con el marco de pagina que busco mapear
  pageTable[pt_index].page = (phy >> 12); // Direccion base fisica 
  pageTable[pt_index].attrs = MMU_P | attrs; // Seteo el bit P de la PDE en 1 
  // Invalido las entradas de la TLB
  tlbflush();
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente 
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
    pd_entry_t* pageDirectory = (pd_entry_t*)(CR3_TO_PAGE_DIR(cr3));
    uint32_t pd_index = VIRT_PAGE_DIR(virt);
    uint32_t pt_index = VIRT_PAGE_TABLE(virt); 
    uint32_t page_offset = VIRT_PAGE_OFFSET(virt);

    pd_entry_t pageDirectoryEntry = pageDirectory[pd_index];
    paddr_t page = 0;
    // Si el bit de present de la PDE es 1, es decir, si esta en memoria la pagina
    if ((pageDirectoryEntry.attrs & MMU_P) == 1) {
      // Obtener la PageTable
      pt_entry_t* pageTable = (pt_entry_t* )(pageDirectory[pd_index].pt << 12);
      // Le seteo el attr de Presente en 0 a la PageTableEntry, 0xFFE, son todos 1s menos el bit menos significativo que es 0
      pageTable[pt_index].attrs = 0xFFE; 
      // La direcc fisica a retornar a partir del .pt del entry, entonces me paro en la base de la PT y le sumo el offset
      page = pageTable[pt_index].page | page_offset;
      // Alcanza con poner presente en 0 ?
      pageTable[pt_index].page = 0; 
      tlbflush();
    }
    // Devolvemos 0 en caso de que no exista
    return page;
}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
  //mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) 
    uint32_t cr3 = rcr3();
    // Mapear ambas paginas
    mmu_map_page(cr3, DST_VIRT_PAGE, dst_addr, 3); // Lectura y escritura, supervirsor y presente 
    mmu_map_page(cr3, SRC_VIRT_PAGE, src_addr, 3); // Lectura y escritura, supervirsor y presente
    // Copio
    uint32_t* dst_virt_page =  (uint32_t *)DST_VIRT_PAGE; 
    uint32_t* src_virt_page =  (uint32_t *)SRC_VIRT_PAGE;
    for (int i = 0; i < 1024; i++) {
        dst_virt_page[i] = src_virt_page[i];
    }
    // Desmapear0x80000000
    mmu_unmap_page(cr3, DST_VIRT_PAGE);
    mmu_unmap_page(cr3, SRC_VIRT_PAGE);
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {
  // Pido 1 pagina, para el PD
  paddr_t cr = mmu_next_free_kernel_page();  
  zero_page(cr);   
  
  // Identity mapping de los primeros 4MB
  for(paddr_t i = 0; i < identity_mapping_end; i+=PAGE_SIZE){ // esto es mas rapido que hacerlo de a direccion
    mmu_map_page(cr, i, i, MMU_P | MMU_W);
  }

  // Mapeo las 2 paginas de codigo
  for(vaddr_t i = 0; i < TASK_CODE_PAGES; i += 1){
    uint32_t offset = (i*PAGE_SIZE);
    mmu_map_page(cr, TASK_CODE_VIRTUAL + offset, phy_start + offset, (MMU_P | MMU_U)); // Solo lectura, supervirsor y presente
  }
  // Mapeo la Pila, cambiado TASK_STACK_BASE por 0x08003000
  mmu_map_page(cr, TASK_STACK_BASE - PAGE_SIZE, mmu_next_free_user_page(), (MMU_P | MMU_W| MMU_U)); // Lectura y escritura, supervirsor y presente 

  // Mapeo el Shared Space 
  mmu_map_page(cr, TASK_SHARED_PAGE, SHARED, (MMU_W | MMU_P| MMU_U)); // Supongo que Lectura y escritura, supervirsor y presente

  return cr;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  // En caso de que si, mapear la pagina
  // Chequeo si esta en rango
  // DUDOSO
  if(ON_DEMAND_MEM_START_VIRTUAL<= virt && ON_DEMAND_MEM_END_VIRTUAL>=virt){
    uint32_t cr3 = rcr3();
    // Chequeo si esta mapeado 
    mmu_map_page(cr3,virt,ON_DEMAND_MEM_START_PHYSICAL,MMU_W | MMU_U); // Lectura y escritura, usuario
    return true;
  } 
  return false;
}  


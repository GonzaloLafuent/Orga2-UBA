#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3


void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema?
	while (true)
	{
	// Completar:
	// - Pueden definir funciones auxiliares para imprimir en pantalla
	// - Pueden usar `task_print`, `task_print_dec`, etc. 
		syscall_draw(pantalla);
		//task_print(pantalla,"GANO MASSA POR AMPLIA DIFERENCIA",5,5,10);
		//uint32_t* pointer_score = (uint32_t*) SHARED_SCORE_BASE_VADDR;
		uint8_t offset = 6;
		uint32_t* pointer_score = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) 0 * sizeof(uint32_t)*2);
		uint32_t score_0 = pointer_score[0];
		uint32_t score_1 = pointer_score[1];

		task_print_dec(pantalla,score_0,3,offset + 0,3,10);
		task_print_dec(pantalla,score_1,3,offset + 5,3,10);
		pointer_score = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) 1 * sizeof(uint32_t)*2);
		score_0 = pointer_score[0];
		score_1 = pointer_score[1];

		task_print_dec(pantalla,score_0,3,offset + 0,6,10);
		task_print_dec(pantalla,score_1,3,offset + 5,6,10);
		pointer_score = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) 2 * sizeof(uint32_t)*2);
		score_0 = pointer_score[0];
		score_1 = pointer_score[1];

		task_print_dec(pantalla,score_0,3,offset + 0,9,10);
		task_print_dec(pantalla,score_1,3,offset + 5,9,10);

		/*
		pointer_score = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) 3 * sizeof(uint32_t)*2);
		score_0 = pointer_score[0];
		score_1 = pointer_score[1];
		task_print_dec(pantalla,score_0,3,offset + 0,12,10);
		task_print_dec(pantalla,score_1,3,offset + 5,12,10);
		*/
		//task_print(pantalla,"RECUENTO DE VOTOS: ",5,9,10);
		//task_print(pantalla,"MASSA: ",5,9,10);
		//task_print(pantalla,"MILEI: ",3,13,10);

	}
}

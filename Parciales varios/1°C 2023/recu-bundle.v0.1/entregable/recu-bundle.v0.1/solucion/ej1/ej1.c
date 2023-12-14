#include "ej1.h"
#include <stdio.h>

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
    uint32_t* ptr = calloc(10,sizeof(uint32_t));
    for(uint8_t i=0; i<cantidadDePagos; i++){
        if (arr_pagos[i].aprobado==1) {
            ptr[arr_pagos[i].cliente] += arr_pagos[i].monto;
        } 
    }
    return ptr;
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
    for(uint8_t i=0; i<n;i++){
        if(strcmp(comercio,lista_comercios[i])==0)
            return 1;
    }
    return 0;
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
}



#include "ej1.h"

uint32_t cuantosTemplosClasicos_c(templo *temploArr, size_t temploArr_len){
    uint32_t cant = 0;
    for(size_t i=0; i<temploArr_len; i++){
        if(temploArr[i].colum_corto*2 + 1 == temploArr[i].colum_largo)
            cant++;
    }
    return cant;
}
  
templo* templosClasicos_c(templo *temploArr, size_t temploArr_len){
    uint32_t cant = cuantosTemplosClasicos(temploArr,temploArr_len);
    templo* ret = malloc(cant* sizeof(templo));
    int j = 0;
    for(size_t i=0; i< temploArr_len; i++){
        if(temploArr[i].colum_corto*2 + 1 == temploArr[i].colum_largo){
            ret[j] = temploArr[i];
            j++;
        }
    }
    return ret; 
}

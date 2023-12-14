#include "ej1.h"

char** agrupar_c(msg_t* msgArr, size_t msgArr_len){
    char** ptr = malloc(msgArr_len*sizeof(char*));
    
    for(size_t i = 0;i<msgArr_len;i++){
        if(ptr[msgArr[i].tag]=="")
            ptr[msgArr[i].tag] = msgArr[i].text;
        else strcat(ptr[msgArr[i].tag],msgArr[i].text);  
    }
    return ptr;
}

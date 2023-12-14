#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    uint8_t indice_cons = 0, indice_voc = 0;
    for (uint64_t indice_string = 0; string[indice_string] != 0; indice_string++)
    {
        switch (string[indice_string])
        {
        case 'A':
        case 'a':
        case 'E':
        case 'e':
        case 'I':
        case 'i':
        case 'O':
        case 'o':
        case 'U':
        case 'u':
            vowels_and_cons[0][indice_voc++]=string[indice_string];
            break;
        default:
            vowels_and_cons[1][indice_cons++]=string[indice_string];
            break;
        }
    }
    
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for (uint64_t i = 0; i < size_of_array; i++)
    {
        array[i].vowels_and_consonants = malloc(2*sizeof(char*));
        array[i].vowels_and_consonants[0] = calloc(64, sizeof(char));
        array[i].vowels_and_consonants[1] = calloc(64, sizeof(char));
        classify_chars_in_string(array[i].string,array[i].vowels_and_consonants);
    }
    
}

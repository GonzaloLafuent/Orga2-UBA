#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

lista_t *nueva_lista(void)
{
    lista_t *l = malloc(sizeof(lista_t));
    l->head = NULL;
    return l;
}

uint32_t longitud(lista_t *lista)
{
    uint32_t longitud = 0;
    nodo_t *nodo = lista->head;
    while (nodo != NULL)
    {
        longitud++;
        nodo = nodo->next;
    }
    return longitud;
}

void agregar_al_final(lista_t *lista, uint32_t *arreglo, uint64_t longitud)
{
    nodo_t **nodo = &(lista->head);
    uint32_t i = 0;
    while (*nodo != NULL)
    {
        nodo = &((*nodo)->next);
    }
    *nodo = malloc(sizeof(nodo_t));
    (*nodo)->next = NULL;
    (*nodo)->longitud = longitud;
    (*nodo)->arreglo = malloc(longitud * sizeof(uint32_t));
    while (i < longitud)
    {
        (*nodo)->arreglo[i] = arreglo[i];
        i++;
    }
}

nodo_t *iesimo(lista_t *lista, uint32_t i)
{
    uint32_t indice = 0;
    nodo_t *n = lista->head;
    while (indice < i)
    {
        n = n->next;
        indice++;
    }
    return n;
}

uint64_t cantidad_total_de_elementos(lista_t *lista)
{
    uint64_t i = 0;
    nodo_t *n = lista->head;
    while (n != NULL)
    {
        i+=n->longitud;
        n = n->next;
    }
    return i;
}

void imprimir_lista(lista_t *lista)
{
    // "| 10 | -> | 20 | -> | 30 | -> | 40 | -> null
    nodo_t *n = lista->head;
    while (n != NULL)
    {
        printf("| %lu | -> ", n->longitud);
        n = n->next;
    }
    printf("null");
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t *array, uint64_t size_of_array, uint32_t elemento_a_buscar)
{
    uint64_t i = 0;
    while (i < size_of_array)
    {
        if(array[i++] == elemento_a_buscar)
        return 1;
    }
    return 0;
}

int lista_contiene_elemento(lista_t *lista, uint32_t elemento_a_buscar)
{
    nodo_t *n = lista->head;
    while (n != NULL)
    {
        if(array_contiene_elemento(n->arreglo,n->longitud,elemento_a_buscar))
            return 1;
        n = n->next;
    }
    return 0;
}

// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t *lista)
{
    nodo_t *current = lista->head;
    while(current != NULL){
        nodo_t *next = current->next;

        free(current->arreglo);
        free(current);

        current = next;
    }

    free(lista);
}
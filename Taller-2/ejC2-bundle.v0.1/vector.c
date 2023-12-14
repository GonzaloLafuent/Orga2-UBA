#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

vector_t *nuevo_vector(void)
{
    vector_t *vec;
    vec = malloc(sizeof(vector_t));
    vec->capacity = 2;
    vec->size = 0;
    vec->array = malloc(2 * sizeof(uint32_t));
    return vec;
}

uint64_t get_size(vector_t *vector)
{
    if (vector == NULL)
        return 0;
    return vector->size;
}

void push_back(vector_t *vector, uint32_t elemento)
{
    if (vector->size == vector->capacity)
    {
        vector->size++;
        vector->capacity*=2;
        vector->array = realloc(vector->array, vector->capacity * sizeof(uint32_t));
        // si anduvo el realloc, se asigna el ultimo elemento
        vector->array[vector->size - 1] = elemento;
    }
    else
    {
        vector->size++;
        vector->array[vector->size - 1] = elemento;
    }
}

int son_iguales(vector_t *v1, vector_t *v2)
{
    if (v1->size != v2->size)
    {
        return 0;
    }

    for (uint16_t i = 0; i < v1->size; i++)
    {
        if (v1->array[i] != v2->array[i])
        {
            return 0;
        }
    }
    return 1;
}

uint32_t iesimo(vector_t *vector, size_t index)
{
    if (index >= vector->size)
        return 0;
    return vector->array[index];
}

void copiar_iesimo(vector_t *vector, size_t index, uint32_t *out)
{
    *out = iesimo(vector, index);
}

// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t *vector_mas_grande(vector_t **array_de_vectores, size_t longitud_del_array)
{
    vector_t *vec = NULL;
    for (uint16_t i = 0; i < longitud_del_array; i++)
    {
        if (vec == NULL)
        {
            vec = array_de_vectores[i];
        }
        else
        {
            if (get_size(vec) < get_size(array_de_vectores[i]))
            {
                vec = array_de_vectores[i];
            }
        }
    }
    return vec;
}

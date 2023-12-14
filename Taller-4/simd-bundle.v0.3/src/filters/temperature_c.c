
#include <math.h>
#include "../simd.h"


bool between(unsigned int val, unsigned int a, unsigned int b)
{
	return a <= val && val <= b;
}


void temperature_c    (
	unsigned char *src,
	unsigned char *dst,
	int width,
	int height,
	int src_row_size,
	int dst_row_size)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            bgra_t *p_src = (bgra_t *)&src_matrix[i][j * 4];
            bgra_t *p_dst = (bgra_t *)&dst_matrix[i][j * 4];
            // puse un par de parentesis por las dudas y arregle la trasparencia
            // el valor de trasparencia lo pongo en 255
            p_dst->a = 255;
            // calculo t
            int t = (p_src->r + p_src->g + p_src->b) / 3;
            // aplico los casos
            if (between(t, 0, 31)) {
                p_dst->b = 0;
                p_dst->g = 0;
                p_dst->r = 128 + (t * 4);
            } else if (between(t, 32, 95)) {
                p_dst->b = 0;
                p_dst->g = (t - 32) * 4;
                p_dst->r = 255;
            } else if (between(t, 96, 159)) {
                int c = (t - 96) * 4;
                p_dst->b = c;
                p_dst->g = 255;
                p_dst->r = 255 - c;
            } else if (between(t, 160, 223)) {
                p_dst->b = 255;
                p_dst->g = 255 - ((t - 160) * 4);
                p_dst->r = 0;
            } else {
                p_dst->b = 255 - ((t - 224) * 4);
                p_dst->g = 0;
                p_dst->r = 0;
            }
        }
    }

}

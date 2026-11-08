/* fft8_fixed.c -- the hardware's 8-point FFT as C, bit-exact, with a timer.
 *
 * The same arithmetic as rtl/fft_bfly.v and rtl/fft8.v (and fft8_fixed in
 * fft_sw.py): Q1.15 inputs, 17-bit internal values, sqrt(2)/2 = 23170/2^15,
 * truncation after every multiply and every halving. This is what the FFT
 * would cost as firmware on a CPU, without any interpreter in the way.
 *
 *   cc -O2 -o fft8_fixed fft8_fixed.c
 *   ./fft8_fixed [frames]      prints a checksum and the time per FFT in ns
 *
 * The checksum is compared with the Python model by benchmark.py, so a
 * mismatch between C and Python is caught.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N  8
#define IW 17
#define C  23170

static const int bitrev[N] = {0, 4, 2, 6, 1, 5, 3, 7};

/* Keep the low `bits` bits of v as a signed number, like a Verilog wire. */
static inline int32_t wrap(int64_t v, int bits)
{
    int64_t m = (int64_t)1 << bits;
    v &= m - 1;
    return (int32_t)(v >= (m >> 1) ? v - m : v);
}

static inline void bfly(int32_t *ar, int32_t *ai, int32_t *br, int32_t *bi, int k)
{
    int32_t tr, ti;
    if (k == 0) {
        tr = *br; ti = *bi;
    } else if (k == 2) {
        tr = *bi; ti = -*br;
    } else {
        /* >> on a negative int64_t is arithmetic with gcc and clang */
        int32_t cs = wrap(((int64_t)(*br + *bi) * C) >> 15, IW + 1);
        int32_t cd = wrap(((int64_t)(*bi - *br) * C) >> 15, IW + 1);
        if (k == 1) { tr = cs; ti = cd; } else { tr = cd; ti = -cs; }
    }
    int32_t a_re = *ar, a_im = *ai;
    *ar = wrap((a_re + tr) >> 1, IW);
    *ai = wrap((a_im + ti) >> 1, IW);
    *br = wrap((a_re - tr) >> 1, IW);
    *bi = wrap((a_im - ti) >> 1, IW);
}

static void fft8(const int32_t *x_re, const int32_t *x_im, int32_t *y_re, int32_t *y_im)
{
    for (int i = 0; i < N; i++) { y_re[i] = x_re[bitrev[i]]; y_im[i] = x_im[bitrev[i]]; }
    for (int span = 1; span < N; span *= 2) {
        int step = N / (2 * span);
        for (int start = 0; start < N; start += 2 * span)
            for (int j = 0; j < span; j++)
                bfly(&y_re[start + j], &y_im[start + j],
                     &y_re[start + j + span], &y_im[start + j + span], j * step);
    }
}

/* Same generator as benchmark.py's lcg_frames() so the checksums can match. */
static uint32_t lcg_state = 12345;
static int32_t lcg_sample(void)
{
    lcg_state = lcg_state * 1103515245u + 12345u;
    return (int32_t)((lcg_state >> 16) & 0xffff) - 32768;
}

static double now_ns(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1e9 + t.tv_nsec;
}

int main(int argc, char **argv)
{
    long frames = argc > 1 ? atol(argv[1]) : 1000000;
    const int distinct = 1024;               /* inputs reused round robin */
    static int32_t in_re[1024][N], in_im[1024][N];
    for (int f = 0; f < distinct; f++)
        for (int n = 0; n < N; n++) { in_re[f][n] = lcg_sample(); in_im[f][n] = lcg_sample(); }

    /* Checksum over one pass of the distinct inputs */
    int64_t checksum = 0;
    int32_t y_re[N], y_im[N];
    for (int f = 0; f < distinct; f++) {
        fft8(in_re[f], in_im[f], y_re, y_im);
        for (int k = 0; k < N; k++) checksum += (int64_t)(k + 1) * y_re[k] - (int64_t)(k + 3) * y_im[k];
    }

    /* Timed loop; `sink` stops the compiler from deleting the work */
    volatile int32_t sink = 0;
    double t0 = now_ns();
    for (long f = 0; f < frames; f++) {
        fft8(in_re[f & (distinct - 1)], in_im[f & (distinct - 1)], y_re, y_im);
        sink += y_re[f & 7];
    }
    double t1 = now_ns();
    printf("checksum %lld\n", (long long)checksum);
    printf("ns_per_fft %.3f\n", (t1 - t0) / frames);
    return 0;
}

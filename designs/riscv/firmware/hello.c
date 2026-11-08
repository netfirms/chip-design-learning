// hello.c -- an ordinary C program, running on a CPU we wrote in Verilog.
//
// There is no operating system and no C library: the program talks to the
// testbench through three memory-mapped registers (see link.ld). Everything
// else is plain C, compiled with gcc for rv32i.
//
// The CPU has no multiply or divide instruction, so `a * b`, `a / b` and
// `a % b` become calls to libgcc routines (__mulsi3, __udivsi3, __umodsi3)
// that do the arithmetic with shifts and adds. Look for them in hello.lst.
//
// main() returns the number of failed checks: 0 means PASS.

#include <stdint.h>

#define CONSOLE (*(volatile uint32_t *)0x10000000)
#define EXIT    (*(volatile uint32_t *)0x10000004)
#define CYCLES  (*(volatile uint32_t *)0x10000008)

// ---- A tiny printf replacement -------------------------------------------
static void putch(char c) { CONSOLE = (uint8_t)c; }

static void print(const char *s)
{
    while (*s)
        putch(*s++);
}

static void print_dec(uint32_t n)
{
    char buf[11];
    int i = 0;
    do {
        buf[i++] = '0' + n % 10;    // % and / are software here (libgcc)
        n /= 10;
    } while (n);
    while (i)
        putch(buf[--i]);
}

static void print_hex(uint32_t n)
{
    print("0x");
    for (int i = 28; i >= 0; i -= 4)
        putch("0123456789abcdef"[(n >> i) & 15]);
}

static int errors;

static void check(const char *what, uint32_t got, uint32_t want)
{
    print(got == want ? "  ok    " : "  FAIL  ");
    print(what);
    if (got != want) {
        print(": got ");
        print_hex(got);
        print(", want ");
        print_hex(want);
        errors++;
    }
    putch('\n');
}

// ---- The work ------------------------------------------------------------
static uint32_t fib(int n)
{
    uint32_t a = 0, b = 1;
    while (n--) {
        uint32_t t = a + b;
        a = b;
        b = t;
    }
    return a;
}

static uint32_t factorial(uint32_t n)
{
    return n <= 1 ? 1 : n * factorial(n - 1);   // recursion: uses the stack
}

static int count_primes(int limit)
{
    static uint8_t composite[100];
    int count = 0;
    for (int i = 2; i < limit; i++) {
        if (composite[i])
            continue;
        count++;
        for (int j = i + i; j < limit; j += i)
            composite[j] = 1;
    }
    return count;
}

static void sort(int32_t *a, int n)             // insertion sort
{
    for (int i = 1; i < n; i++) {
        int32_t v = a[i];
        int j = i - 1;
        while (j >= 0 && a[j] > v) {
            a[j + 1] = a[j];
            j--;
        }
        a[j + 1] = v;
    }
}

static uint32_t crc32(const char *s)            // the same CRC as zlib and Ethernet
{
    uint32_t crc = 0xffffffff;
    while (*s) {
        crc ^= (uint8_t)*s++;
        for (int k = 0; k < 8; k++)
            crc = (crc >> 1) ^ (0xedb88320 & -(crc & 1));
    }
    return ~crc;
}

int main(void)
{
    uint32_t start = CYCLES;
    volatile uint32_t seven = 7;    // volatile: stop gcc dividing at compile time

    print("\nHello from minirv, a RISC-V CPU written in Verilog!\n");
    print("Hardware is the new Software.\n\n");

    print("Fibonacci:");
    for (int i = 1; i <= 12; i++) {
        putch(' ');
        print_dec(fib(i));
    }
    print("\n\n");

    check("fib(30) = 832040", fib(30), 832040);
    check("10! = 3628800 (software multiply)", factorial(10), 3628800);
    check("1000000 / 7 = 142857 (software divide)", 1000000u / seven, 142857);
    check("25 primes below 100", count_primes(100), 25);

    static int32_t a[10] = {42, -7, 19, 0, 1000, -300, 5, 5, 77, -1};
    sort(a, 10);
    int sorted = 1;
    for (int i = 1; i < 10; i++)
        sorted &= a[i - 1] <= a[i];
    check("sort 10 numbers", sorted && a[0] == -300 && a[9] == 1000, 1);

    check("crc32(\"Hardware is the new Software\")",
          crc32("Hardware is the new Software"), 0xb708b47b);

    print("\nThat took ");
    print_dec(CYCLES - start);
    print(" clock cycles.\n");
    return errors;
}

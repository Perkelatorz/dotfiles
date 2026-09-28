// clangd + clang-tidy + clang-format smoke test.
// Expect: a -Wshadow warning on the inner `n` (clangd in the editor, and in quickfix after
// <leader>lb). <leader>lr should build, run, and print an ASan report for the leaked `buf`.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int sum(const int *xs, int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        total += xs[i];
    }
    return total;
}

int main(void) {
    int xs[] = {1, 2, 3, 4};
    int n = sizeof xs / sizeof xs[0];
    printf("sum = %d\n", sum(xs, n));

    char *buf = malloc(32);
    if (buf == NULL) {
        return 1;
    }
    strcpy(buf, "hello");
    {
        int n = (int)strlen(buf);
        printf("%s has %d chars\n", buf, n);
    }
    return 0;
}

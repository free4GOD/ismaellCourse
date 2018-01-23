#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <limits.h>
#include <stdbool.h>

void main()
{
	char s[6] = "      ";
        int n = 6;
	int i = n;
	int j = 0;
	while (i-- > 0) {
		if (j < n) s[j] = '#';
		j++;
        	printf("%s", s);
		printf("%c", '\n');
	}
}

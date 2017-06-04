char ch[]="1234567";
char copy[256];

int strlen(char *s)
	{
	int size=0;
	while (*s++) size++;
	return size;
	}

char * strcpy(char *dest, const char *src)
	{
	char *d = dest;
	while (*src) *d++ = *src++;
	*d = '\0';
	return dest;
	}

int strcmp(const char *s1, const char *s2)
	{
	do
		{
		if (*s1 < *s2) return -1;
		if (*s1 > *s2++) return 1;
		}
	while (*s1++);
	return 0;
	}

int main()
	{
	if (strlen(ch) != 7) return 1;
	if (strlen("ABC") != 3) return 1;
	if (strcpy(copy, ch) != copy) return 1;
	if (strcmp(copy, ch) != 0) return 1;
	return 0;
	}

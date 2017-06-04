#define NB_VAL 32
int tab[NB_VAL];

void init_tab(int *tab, int n)
	{
	int i;
	static unsigned long int val = 1446568394; // date
	for(i=0 ;i< NB_VAL; i++)
		{
      val = ((((val >> 31)
				^ (val >> 6)
				^ (val >> 4)
				^ (val >> 2)
				^ (val >> 1)
				^ val)
				& 0x0000001)
				<<31)
				| (val >> 1);
		tab[i] = val & 0xff;
		}
	}


int split(int *tab, int n)
	{
	int i, ipiv = 0;
	int piv = tab[0];
	for(i = 1; i < n; i++)
		{
		if (tab[i] < piv)
			{
			int tmp = tab[++ipiv];
			tab[ipiv] = tab[i];
			tab[i] = tmp;
			}
		}
	tab[0] = tab[ipiv];
	tab[ipiv] = piv;

	return ipiv;
	}

void qsort(int *tab, int n)
	{
	if (n > 1)
		{
		int ipiv = split(tab, n);
		qsort(tab, ipiv);
		qsort(tab + ipiv + 1, n - ipiv - 1);
		}
	}

int est_trie(int *tab, int n)
	{
	int i;
	for( i=1; i<n; i++)
		if ( tab[i] < tab[i-1]) return 0;
	return 1;
	}

int main()
	{
	init_tab(tab, NB_VAL);
	qsort(tab, NB_VAL);
	if (est_trie(tab, NB_VAL)) return 0;
	return 1;
	}

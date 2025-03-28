typedef unsigned long size_t;

long      a64l(const char *);
void      abort(void);
int       abs(int);
int       atexit(void (*)(void));
int       atoi(const char *);
long      atol(const char *);
void     *bsearch(const void *, const void *, size_t, size_t, int (*)(const void *, const void *));
void     *calloc(size_t, size_t);
void      exit(int);
void      free(void *);
char     *getenv(const char *);
int       getsubopt(char **, char *const *, char **);
// int       grantpt(int);   cannot find in C11 stdlib
char     *initstate(unsigned int, char *, size_t);
long      jrand48(unsigned short[3]);
char     *l64a(long);
long      labs(long);
void      lcong48(unsigned short[7]);
long      lrand48(void);
void     *malloc(size_t);
int       mblen(const char *, size_t);
char     *mktemp(char *);
int       mkstemp(char *);
long      mrand48(void);
long      nrand48(unsigned short [3]);
char     *ptsname(int);
int       putenv(char *);
void      qsort(void *, size_t, size_t, int (*)(const void *, const void *));
int       rand(void);
int       rand_r(unsigned int *);
long      random(void);
void     *realloc(void *, size_t);
char     *realpath(const char *, char *);
unsigned short seed48(unsigned short[3]);
// void      setkey(char *);   cannot find in C11 stdlib
char     *setstate(char *);
void      srand(unsigned int);
void      srand48(long);
void      srandom(unsigned);
long      strtol(const char *, char **, int);
size_t strtoul(const char *, char **, int);
int       system(const char *);
int       unlockpt(int);
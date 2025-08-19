char buffd[9];
char* cstrud(uint32_t num) {
	buffd[8] = '\0';
	
	char c;
	int i = 0;
	while (i != 9) {
		c = (num >> (i << 2)) & 0xf;
		
		if (c >= 0xa)	c += 'A' - 10;
		else		c += '0';
		buffd[7 - i] = c;
		i++;
	}
	return &buffd;
}

char buffb[3];
char* cstrub(uint8_t num) {
	buffb[2] = '\0';
	
	char c;
	int i = 0;
	while (i != 2) {
		c = (num >> (i << 2)) & 0xf;
		
		if (c >= 0xa)	c += 'A' - 10;
		else		c += '0';
		buffb[1 - i] = c;
		i++;
	}
	return &buffb;
}
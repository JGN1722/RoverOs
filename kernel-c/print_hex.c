char buffd[9];
char* cstrud(uint32_t num) {
	buffd[8] = '\0';
	
	char c;
	for (int i = 0; i < 8; i++) {
		c = (num >> (i * 4)) & 0xf;
		
		if (c >= 0xa)	c += 'A' - 10;
		else		c += '0';
		buffd[7 - i] = c;
	}
	return &buffd;
}

char buffb[3];
char* cstrub(uint8_t num) {
	buffb[2] = '\0';
	
	char c;
	for (int i = 0; i < 2; i++) {
		c = (num >> (i * 4)) & 0xf;
		
		if (c >= 0xa)	c += 'A' - 10;
		else		c += '0';
		buffb[1 - i] = c;
	}
	return &buffb;
}
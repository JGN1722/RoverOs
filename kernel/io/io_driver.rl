int clear_screen() {
	int videomem_addr, white_on_black, len, i;
	
	videomem_addr = 0xB8000;
	white_on_black = 0x0f;
	len = 80 * 25;
	i = 0;
	
	while (i < len) {
		WORD *videomem_addr = white_on_black * 256 + ' ';
		videomem_addr += 2;
		i++;
	}
}
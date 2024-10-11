include "C:\Users\comedelfini--thibaud\Desktop\RoverOs\kernel\io\io_driver.rl"

int main() {
	int videomem_addr, white_on_black;
	
	videomem_addr = 0xB8000;
	white_on_black = 0x0f;
	
	clear_screen();
	
	BYTE *videomem_addr = 'B';
	videomem_addr++;
	BYTE *videomem_addr = white_on_black;

	
	\ hang \
	do {}
}
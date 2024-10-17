include "C:\Users\comedelfini--thibaud\Desktop\RoverOs\main_source\constants.inc"
include "C:\Users\comedelfini--thibaud\Desktop\RoverOs\kernel\io\io_driver.rl"

int main() {
	clear_screen();
	
	printf("Hello\n");
	printf("This is a test\r");
	
	putchar("A",5,2);
	putchar("B",5,1);
	putchar("C",5,0);
	
	set_cursor_pos(0, #MAX_ROWS - 3);
	
	do {
		printf("Hey There!\r\n");
		sleep();
	}
	
	do {}
}
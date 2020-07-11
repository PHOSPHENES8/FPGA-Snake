

#define display_number_addr 0xbfaf2018
#define display_vaild_addr  0xbfaf2024
#define display_value_addr  0xbfaf2020
#define display_name_addr   0xbfaf2000

#define SNAKE_MAP_ADDR  0x00000600
#define LED_DOT1_ADDR  0xbfaf8044    // 32'hbfaf_8044
#define LED_DOT2_ADDR  0xbfaf8048    // 32'hbfaf_8048

void show(int value1, int value2){   // stolen from wjl
    int *p;

    p = LED_DOT1_ADDR;
    *p = value1;
    p = LED_DOT2_ADDR;
    *p = value2;
}



void delay()
{ 
 for(int i=0;i<10000;i++);
}




void flush(int rank, int data)    //update the lcd screen 22*2 
{
int *display_number = display_number_addr;
int *display_vaild = display_vaild_addr;
int *display_value = display_value_addr;
int *display_name = display_name_addr;
int *p = 0xbfaff010;
  *display_number = (rank<<1)-1;
  *display_value = data;
  *display_name = rank;
	*p = rank; 
  *display_vaild = 1;
  for(int j=0; j<5000; j++);
  *display_vaild = 0;
  for(int j=0;j<5000;j++);
}

void draw()
{
for(int rk = 1; rk <=10; rk++)
for(int i=0; i<5;i++)
{
  flush(rk,i);
  delay();
}



while(1)
{
show(0xffff18ff, 0xf18ffff);
delay();
show(0xfefe30fe, 0xfe30fefe);
delay();
show(0xfcfc60fc, 0xfc60fcfc);
delay();
show(0xf8f8c0f8, 0xf8c0f8f8);
delay();
}


}


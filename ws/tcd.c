#define RS_ADDR 0xbfaf2018
#define RD_ADDR 0xbfaf2024
#define WR_ADDR 0xbfaf2020
#define D_ADDR  0xbfaf2000

/*void delay()
{
  for(int i=0;i<50000;i++);
}*/

void draw()
{

	int *rs = RS_ADDR;
	int *rd = RD_ADDR;	
	int *wr = WR_ADDR;
	int *D = D_ADDR;
// set 
*rs = 0;
*wr = 0;
*D = 0x36;
*rd = 1;
*wr = 1;

*rs = 1;
// set mvxy
*wr = 0;
*D = 0x00;
*wr = 1;

// send X
	*rs = 0;
	*wr = 0;
 	*D = 0x2a;
	*rd = 1;
	*wr = 1;

	*rs = 1;
// send x_min
	*wr = 0;
	*D = 0x0;
	*wr = 1;
	*wr = 0;
	*D = 0x19;
	*wr = 1;
// send x_max
	*wr = 0;
	*D = 0x0;
	*wr = 1;
	*wr = 0;
	*D = 0x4b;
	*wr = 1;

// send Y
	*rs = 0;
	*wr = 0;
 	*D = 0x2b;
	*rd = 1;
	*wr = 1;
	*rs = 1;
// send y_min
	*wr = 0;
	*D = 0x0;
	*wr = 1;
	*wr = 0;
	*D = 0x19;
	*wr = 1;
// send y_max
	*wr = 0;
	*D = 0x0;
	*wr = 1;
	*wr = 0;
	*D = 0x4b;
	*wr = 1;
// send color
	*rs = 0;
	*wr = 0;
 	*D = 0x2c;
	*rd = 1;
	*wr = 1;
	*rs = 1;
	for(int i=0; i<50;i++)
	{
	  for(int j=0; j<50; j++)
	  {
		*wr = 0;
		*D = 0xf800;
		*wr = 1;
	  }
	}		
}

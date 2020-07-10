//soc confreg
#include<conio.h>
#include<stdio.h>
#include<bits/stdc++.h>

#define IO_SIMU_ADDR            0xffec
#define UART_ADDR               0xfff0
#define SIMU_FLAG_ADDR          0xfff4
#define OPEN_TRACE_ADDR         0xfff8
#define NUM_MONITOR_ADDR        0xfffc
#define LED_ADDR                0xf000
#define LED_RG0_ADDR            0xf004
#define LED_RG1_ADDR            0xf008
#define NUM_ADDR                0xf010
#define SWITCH_ADDR             0xf020
#define BTN_KEY_ADDR            0xf024
#define BTN_STEP_ADDR           0xf028
#define SW_INTER_ADDR           0xf02c //switch interleave
#define TIMER_ADDR              0xe000

// ------- extra confreg ------
#define RAND_DATA_ADDR               0x8040
#define LED_DOT1_ADDR  0x8044    // 32'hbfaf_8044
#define LED_DOT2_ADDR  0x8048    // 32'hbfaf_8048
#define BUTTON_ADDR    0x804c    // 32'hbfaf_804c 
// ----------------------------


// #define SNAKE_ADDR              0xbfca0004
// #define SNALE_LEN_ADDR          0xbfca0000

#define SNAKE_SIZE              16
#define SNAEK_SIZE_LOG          2 // p++ : p + 4

// ----- RETURE ADDR -----
#define G_ADDR             0x1000 // 1 int
#define GET_SNAKE_ADDR     0x1020 // 4 int
#define RAND_ADDR          0x1040 // 1 int 
#define PRESSBUTTON_ADDR   0x1044 // 1 int 
#define CHECK_OVER_ADDR    0x1048 // 1 int
// -----------------------


// ----- GLOBAL VAR ADDR ----
#define SNAKE_LEN_ADDR  0x0000
#define SNAKE_DIR_ADDR  0x0004
#define FOOD_X_ADDR     0x0008
#define FOOD_Y_ADDR     0x000c

#define SNAKE_ADDR      0x0200
#define SNAKE_MAP_ADDR  0x0600
// --------------------------

/*
 * struct node
 * {
 *     int pre_x, pre_y, x, y;
 * };
*/
int stack[700000];
void store(int addr, int val)
{
    // int *p;
    // p=addr;
    // *p=val;
    stack[addr]=val;
}

void load(int addr1, int addr2)//$addr1=$addr2
{
    // int *p,q;
    // p=addr1;
    // q=addr2;
    // *p=q;
    stack[addr1]=stack[addr2];
}

void geTdata(int *x, int addr)
{
    *x=stack[addr];
}

void delay(int x){
    int i , j;
    for(i = 0; i < x; i++) 
        for(j = 0; j < 1000; j++) 
        ;
}

void set_number(int x){
    int p = NUM_ADDR;
    // *p = x;
    store(p,x);
}

void set_led(int x){
    int p = LED_ADDR;
    // *p = x;
    store(p,x);
}

void raNd(){
    // int res = RAND_ADDR;
    // int *p = RAND_DATA_ADDR ;
    // res = *p;
//    load(RAND_ADDR,RAND_DATA_ADDR);
	srand(time(0));
	int x=rand();
	stack[RAND_DATA_ADDR]=x;
	stack[RAND_ADDR]=x;
    // printf("rand=%d\n",x);
}

void pressButton(){
    // int *p = BUTTON_ADDR;
    int button_value ;
    geTdata(&button_value,BUTTON_ADDR);
    //printf("bt=%d\n",button_value);
//    int status;
    int q = PRESSBUTTON_ADDR;
    if(button_value == 0b1110){
        // q = 1;
        store(q,1);
    }
    else if(button_value == 0b1101){
        // q = 2;
        store(q,2);
    }
    else if(button_value == 0b1011){
        // q = 3;
        store(q,3);
    }
    else if(button_value == 0b0111){
        // q = 4;
        store(q,4);
    }
    else{
        // q = 5;
        store(q,5);
    }
}

void init(){
    // int x=1;
    int p = SNAKE_LEN_ADDR;
    // *p = 1;
    store(p,1);
    p = SNAKE_DIR_ADDR;
    // p = 1;
    store(p,1);
}

void set_snake(int idx, int pre_x, int pre_y, int x, int y){
    int p = SNAKE_ADDR;
    p += idx << SNAEK_SIZE_LOG ;
    // *p = pre_x; 
    store(p,pre_x);p++;
    // *p = pre_y; 
    store(p,pre_y);p++;
    // *p = x;     
    store(p,x);p++;
    // *p = y;
    store(p,y);

}

void set_food(int x, int y){
    int p = FOOD_X_ADDR;
    // *p = x;
    store(p,x);
    p = FOOD_Y_ADDR;
    // *p = y;
    store(p,y);
    printf("setfood %d %D\n",stack[FOOD_X_ADDR],stack[FOOD_Y_ADDR]);
}

void get_snake(int idx){
    int res = GET_SNAKE_ADDR;
    int p = SNAKE_ADDR;
    p += idx << SNAEK_SIZE_LOG;
    // res = *p;
    load(res,p); 
    res ++; p++;
    // res = *p; 
    load(res,p);
    res ++; p++;
    // res = *p; 
    load(res,p);
    res ++; p++;
    // res = *p;
    load(res,p);
}



void snake_move(int dir, int dx, int dy){

//    printf("1\n");
// printf("dx=%d,dy=%d\n",dx,dy);
    int p = SNAKE_DIR_ADDR;
    int snake_dir;
    geTdata(&snake_dir,p);
    p = FOOD_X_ADDR;
    int food_x;
    geTdata(&food_x,p);
    p = FOOD_Y_ADDR;
    int food_y;
    geTdata(&food_y,p);
    int get_food = 0;
//    int turn = 1;
    if(dir > 4) return ;
    if((snake_dir == 1 || snake_dir == 2) && (dir == 1 || dir == 2))
        return;
    if((snake_dir == 3 || snake_dir == 4) && (dir == 3 || dir == 4))  
        return 
    // if(turn == 0) {
    //     if(snake_dir == 1) {
    //         dx = -1; dy = 0; 
    //     }
    //     else if(snake_dir == 2) {
    //         dx = 1; dy =0 ;
    //     }
    //     else if(snake_dir == 3) {
    //         dx = 0; dy = -1; 
    //     }
    //     else {
    //         dx = 0; dy = -1;
    //     }
    // }
    get_snake(0);
    p = GET_SNAKE_ADDR;
    // int x = *(p+2);
    int x;geTdata(&x,p+2);
    // int y = *(p+3);
    int y;geTdata(&y,p+3);
    printf("snake:%d,%d\n",x,y);
    int last_x = x , last_y = y;
    x += dx;
    y += dy;
    if(x == food_x && y == food_y) get_food = 1;
    set_snake(0, -1, -1, x, y);
    p = SNAKE_LEN_ADDR;
    // int len = *p;
    int len;geTdata(&len,p);
    int i;
    for(i = 1; i < len; i++){
        get_snake(i);
        p = GET_SNAKE_ADDR;
        // int pre_x = *p;
        int pre_x;geTdata(&pre_x,p);
        // int pre_y = *(p+1);
        int pre_y;geTdata(&pre_y,p+1);
        // int cur_x = *(p+2);
        int cur_x;geTdata(&cur_x,p+2);
        // int cur_y = *(p+3);
        int cur_y;geTdata(&cur_y,p+3);
        set_snake(i, x, y, pre_x, pre_y);
        x = pre_x;
        y = pre_y;
        last_x = cur_x;
        last_y = cur_y;
    }

    get_snake(0);
    p = GET_SNAKE_ADDR;
    // int head_x = *(p+2);
    int head_x;geTdata(&head_x,p+2);
    // int head_y = *(p+3);
    int head_y;geTdata(&head_y,p+3);

    // get food
    set_led(~get_food);
    // printf("getfood=%d\n",get_food);
    if(get_food != 0) {
        p = SNAKE_LEN_ADDR;
        // *p = len+1;
        store(p,len+1);
        set_snake(len, x, y, last_x, last_y);

        int food_ok = 0;
        while(food_ok == 0){
            raNd();
            p = RAND_ADDR;
            // int t = *p;
            int t;geTdata(&t,p);
            t = t & 0x0000003f;
            x = t >> 3;
            y = t & 0x00000007;
            if(x != head_x || y != head_y) 
                food_ok = 1;
        }
        p = FOOD_X_ADDR; 
        // *p = x;
        store(p,x);
        p = FOOD_Y_ADDR; 
        // *p = y;
        store(p,y);
    }
}

void check_over(){
    int p = SNAKE_ADDR;
    // int x = *(p+2);
    // int y = *(p+3);
    int x;geTdata(&x,p);
    int y;geTdata(&y,p);
    int over = 0;
    if(x < 0 || x > 7)  over = 1;
    if(y < 0 || y > 7)  over = 1;
    p = SNAKE_LEN_ADDR;
    // int len = *p;
    int len;geTdata(&len,p);
    int i;
    for(i = 1; i < len; i++){
        get_snake(i);
        p = GET_SNAKE_ADDR;
        // int cur_x = *(p+2);
        // int cur_y = *(p+3);
        int cur_x;geTdata(&cur_x,p+2);
        int cur_y;geTdata(&cur_y,p+3);
        if(x == cur_x && y == cur_y) 
            over = 1;
    }
    p =  CHECK_OVER_ADDR;
    // *p = over;
    store(p,over);
}

void get_food(){

}

void show(){
    int p = SNAKE_MAP_ADDR;
    // int map_data1 = *p;
    // int map_data2 = *(p+1);
    int map_data1;geTdata(&map_data1,p);
    int map_data2;geTdata(&map_data2,p+1);
    // printf("mapdata1:%d\n",map_data1);
    // printf("mapdata2:%d\n",map_data2);
    p = LED_DOT1_ADDR;
    // *p = map_data1;
    store(p,map_data1);
    p = LED_DOT2_ADDR;
    // *p = map_data2;
    store(p,map_data2);
//    while(1)
//    {
//    	if(kbhit())
//    	{
//    		char ch=getchar();
//    		break;
//    	}
        int tem=stack[LED_DOT1_ADDR];
        int cnt=1;
//        while(tem)
//        {
//            printf("%d",tem%2);
//            tem>>=1;
//            if(cnt%8==0)printf("\n");
//            cnt++;
//        }
		printf("%d\n",tem);
        tem=stack[LED_DOT2_ADDR];
        cnt=1;
        printf("%d\n",tem);
        printf("\n");
//        while(tem)
//        {
//            printf("%d",tem%2);
//            tem>>=1;
//            if(cnt%8==0)printf("\n");
//            cnt++;
//        }
//        system("cls");
//    }
    
}

void update_snake_map(){
    int map_data1 = 0;
    int map_data2 = 0;

    // int *p = SNAKE_MAP_ADDR;
    // *p = 0;
    int p = SNAKE_LEN_ADDR;
    // int len = *p;
    int len;geTdata(&len,p);
    int i;
    for(i = 0; i < len; i++){
        get_snake(i);
        p = GET_SNAKE_ADDR;
        // int x = *(p+2);
        // int y = *(p+3);
        int x;geTdata(&x,p+2);
        int y;geTdata(&y,p+3);
        // printf("sy%d %d\n",x,y);
        if(x < 4) {
            int t = (x<<3) + y;
            t = 31 - t;
            map_data1 |= 1 << t;
        }
        else {
            x -= 4;
            int t = (x<<3) + y;
            t = 31 - t;
            map_data2 |= 1 << t;
        }
    }
    p = SNAKE_MAP_ADDR;
    // *p = map_data1;
    store(p,map_data1);
    p++;
    // *p = map_data2;
    store(p,map_data2);
}

void update_food_map(int x, int y){
    int p = SNAKE_MAP_ADDR;
    // int map_data1 = *p;
    // int map_data2 = *(p+1);
    int map_data1;geTdata(&map_data1,p);
    int map_data2;geTdata(&map_data2,p+1);
    if(x < 4) {
        int t = (x<<3) + y;
        map_data1 |= 1 << t;
        // *p = map_data1;
        store(p,map_data1);
    }
    else {
        x -= 4;
        int t = (x<<3) + y;
        map_data2 |= 1 << t;
        // *(p+1) = map_data2;
        store(p+1,map_data2);
    }
}

void snake_main(){
    init();
    int x = 3, y = 3;
    int p;
    // show();
    set_snake(0, -1, -1, x, y);
    update_snake_map();
    show();
    int food_ok = 0;
    while(food_ok == 0){
        raNd();
        int p = RAND_ADDR;
        int t = stack[p];
        t = t & 0x0000003f;
        x = t >> 3;
        y = t & 0x00000007;
        if(x != 3 || y != 3) 
            food_ok = 1;
    }
    p = FOOD_X_ADDR;
    // *p = x;
    store(p,x);
    p = FOOD_Y_ADDR ;
    // *p = y;
    store(p,y);
    update_food_map(x, y);
    printf("food1%d %d\n",stack[FOOD_X_ADDR],stack[FOOD_Y_ADDR]);

    // int q = SNAKE_LEN_ADDR;
    // q = 2;
    // set_snake(1, 3, 3, 3, 4);
    show();
    while (1)
    {
        // delay(1000);

        // int i = 0;
        // for(i = 0; i < 1; i++) ;
        while(1)
        {
            if(kbhit())
            {
                char ch=getch();
                // printf("%c",ch);
                if(ch=='w')
                {
                    store(BUTTON_ADDR,0b1110);
                    break;
                }
                else if(ch=='s')
                {
                    store(BUTTON_ADDR,0b1101);
                    break;
                }
                else if(ch=='a')
                {
                    store(BUTTON_ADDR,0b1011);
                    break;
                }
                else if(ch=='d')
                {
                    store(BUTTON_ADDR,0b0111);
                    break;
                }
            }
        }
        raNd();
        //show();
        p = RAND_ADDR;
        // int  t = *p;
        int t;geTdata(&t,p);
        p = NUM_ADDR;
        // *p = t;
        store(p,t);

        int dx, dy;
        // ----- input ----- 
        pressButton();
        p = PRESSBUTTON_ADDR;
        // int btn_dir = *p;
        int btn_dir;geTdata(&btn_dir,p);
        // p = NUM_ADDR;
        // *p = btn_dir;
        if(btn_dir == 1) {
            dx = -1;
            dy = 0;
        }
        else if(btn_dir == 2) {
            dx = 1;
            dy = 0;
        }
        else if(btn_dir == 3) {
            dx = 0;
            dy = -1;
        }
        else if(btn_dir == 4) {
            dx = 0;
            dy = 1;
        }
        else {
            dx = 0; dy = 0;
        }

        delay(1000);

        // ----- update -----
        snake_move(btn_dir, dx, dy);
        // printf("btn%d %d %d",btn_dir,dx,dy);

        get_snake(0);
        p = GET_SNAKE_ADDR ;
        // x = *(p+2);
        // y = *(p+3);
        geTdata(&x,p+2);
        geTdata(&y,p+3);

        // x += dx;
        // y += dy;
        p = FOOD_X_ADDR;
        // int tmp_x = *p;
        int tmp_x;geTdata(&tmp_x,p);
        p = FOOD_Y_ADDR;
        // int tmp_y = *p;
        int tmp_y;geTdata(&tmp_y,p);
        // set_number(( x << 24 )| (y << 16 )| ( tmp_x << 8) | (tmp_y));
        // int tmp = ( x << 24 )| (y << 16 )| (dx << 8) | (dy);
        int tmp = ( x << 24 )| (y << 16 )| ( tmp_x << 8) | (tmp_y);
        p = NUM_ADDR;
        // *p = tmp;
        store(p,tmp);
        // int x = *(p+2);
        // int y = *(p+3);
        // x += dx ; y += dy;

        

        // set_snake(0, -1, -1, x, y);

        update_snake_map();
        p = FOOD_X_ADDR;
        // int food_x = *p;
        int food_x;geTdata(&food_x,p);
        p = FOOD_Y_ADDR;
        // int food_y = *p;
        int food_y;geTdata(&food_y,p);
        update_food_map(food_x, food_y); 
        // ----- show ------
        show();
    }
    
}

int main()
{
    snake_main();
    return 0;
}
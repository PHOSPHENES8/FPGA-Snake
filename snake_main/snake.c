//soc confreg
#define CONFREG_NULL            0xbfaf8ffc

#define CONFREG_CR0             0xbfaf8000
#define CONFREG_CR1             0xbfaf8004
#define CONFREG_CR2             0xbfaf8008
#define CONFREG_CR3             0xbfaf800c
#define CONFREG_CR4             0xbfaf8010
#define CONFREG_CR5             0xbfaf8014
#define CONFREG_CR6             0xbfaf8018
#define CONFREG_CR7             0xbfaf801c

#define IO_SIMU_ADDR            0xbfafffec
#define UART_ADDR               0xbfaffff0
#define SIMU_FLAG_ADDR          0xbfaffff4
#define OPEN_TRACE_ADDR         0xbfaffff8
#define NUM_MONITOR_ADDR        0xbfaffffc
#define LED_ADDR                0xbfaff000
#define LED_RG0_ADDR            0xbfaff004
#define LED_RG1_ADDR            0xbfaff008
#define NUM_ADDR                0xbfaff010
#define SWITCH_ADDR             0xbfaff020
#define BTN_KEY_ADDR            0xbfaff024
#define BTN_STEP_ADDR           0xbfaff028
#define SW_INTER_ADDR           0xbfaff02c //switch interleave
#define TIMER_ADDR              0xbfafe000

// ------- extra confreg ------
#define RAND_DATA_ADDR               0xbfaf8040
#define LED_DOT1_ADDR  0xbfaf8044    // 32'hbfaf_8044
#define LED_DOT2_ADDR  0xbfaf8048    // 32'hbfaf_8048
#define BUTTON_ADDR    0xbfaf804c    // 32'hbfaf_804c 
// ----------------------------


// #define SNAKE_ADDR              0xbfca0004
// #define SNALE_LEN_ADDR          0xbfca0000

#define SNAKE_SIZE              16
#define SNAEK_SIZE_LOG          2 // p++ : p + 4

// ----- RETURE ADDR -----
#define G_ADDR             0x00010000 // 1 int
#define GET_SNAKE_ADDR     0x00010020 // 4 int
#define RAND_ADDR          0x00010040 // 1 int 
#define PRESSBUTTON_ADDR   0x00010044 // 1 int 
#define CHECK_OVER_ADDR    0x00010048 // 1 int
// -----------------------


// ----- GLOBAL VAR ADDR ----
#define SNAKE_LEN_ADDR  0x00000000
#define SNAKE_DIR_ADDR  0x00000004
#define FOOD_X_ADDR     0x00000008
#define FOOD_Y_ADDR     0x0000000c

#define SNAKE_ADDR      0x00000200
#define SNAKE_MAP_ADDR  0x00000600
// --------------------------

/*
 * struct node
 * {
 *     int pre_x, pre_y, x, y;
 * };
*/


void delay(int x){
    int i , j;
    for(i = 0; i < x; i++) 
        for(j = 0; j < 1000; j++) 
        ;
}

void set_number(int x){
    int *p = NUM_ADDR;
    *p = x;
}

void set_led(int x){
    int *p = LED_ADDR;
    *p = x;
}

void rand(){
    int *res = RAND_ADDR;
    int *p = RAND_DATA_ADDR ;
    *res = *p;
}

void pressButton(){
    int *p = BUTTON_ADDR;
    int button_value = *p;
    int status;
    int *q = PRESSBUTTON_ADDR;
    if(button_value == 0b1110){
        *q = 1;
    }
    else if(button_value == 0b1101){
        *q = 2;
    }
    else if(button_value == 0b1011){
        *q = 3;
    }
    else if(button_value == 0b0111){
        *q = 4;
    }
    else{
        *q = 5;
    }
}

void init(){
    int *p = SNAKE_LEN_ADDR;
    *p = 1;
    p = SNAKE_DIR_ADDR;
    p = 1;
}

void set_snake(int idx, int pre_x, int pre_y, int x, int y){
    int *p = SNAKE_ADDR;
    p += idx << SNAEK_SIZE_LOG ;
    *p = pre_x; p++;
    *p = pre_y; p++;
    *p = x;     p++;
    *p = y;
}

void get_snake(int idx){
    int *res = GET_SNAKE_ADDR;
    int *p = SNAKE_ADDR;
    p += idx << SNAEK_SIZE_LOG;
    *res = *p; res ++; p++;
    *res = *p; res ++; p++;
    *res = *p; res ++; p++;
    *res = *p;
}


void snake_move(int dir, int dx, int dy){

    int *p = SNAKE_DIR_ADDR;
    int snake_dir = *p;
    p = FOOD_X_ADDR;
    int food_x = *p;
    p = FOOD_Y_ADDR;
    int food_y = *p;
    int get_food = 0;
    int turn = 1;
    if(dir > 4) turn = 0 ;
    if((snake_dir == 1 || snake_dir == 2) && (dir == 1 || dir == 2))
        turn = 0 ;
    if((snake_dir == 3 || snake_dir == 4) && (dir == 3 || dir == 4))  
        turn = 0;
    if(turn == 0) {
        if(snake_dir == 1) {
            dx = -1; dy = 0; 
        }
        else if(snake_dir == 2) {
            dx = 1; dy =0 ;
        }
        else if(snake_dir == 3) {
            dx = 0; dy = -1; 
        }
        else {
            dx = 0; dy = -1;
        }
    }
    get_snake(0);
    p = GET_SNAKE_ADDR;
    int x = *(p+2);
    int y = *(p+3);
    int last_x = x , last_y = y;
    x += dx;
    y += dy;
    if(x == food_x && y == food_y) get_food = 1;
    set_snake(0, -1, -1, x, y);
    p = SNAKE_LEN_ADDR;
    int len = *p;
    int i;
    for(i = 1; i < len; i++){
        get_snake(i);
        p = GET_SNAKE_ADDR;
        int pre_x = *p;
        int pre_y = *(p+1);
        int cur_x = *(p+2);
        int cur_y = *(p+3);
        set_snake(i, x, y, pre_x, pre_y);
        x = pre_x;
        y = pre_y;
        last_x = cur_x;
        last_y = cur_y;
    }
    // get food
    if(get_food != 0) {
        p = SNAKE_LEN_ADDR;
        *p = len+1;
        set_snake(len, last_x, last_y, x, y);

        int food_ok = 0;
        while(food_ok == 0){
            rand();
            p = RAND_ADDR;
            int t = *p;
            t = t & 0x0000003f;
            x = t >> 3;
            y = t & 0x00000007;
            if(x != 3 || y != 3) 
                food_ok = 1;
        }
        p = FOOD_X_ADDR; *p = x;
        p = FOOD_Y_ADDR; *p = y;
    }
}

void check_over(){
    int *p = SNAKE_ADDR;
    int x = *(p+2);
    int y = *(p+3);
    int over = 0;
    if(x < 0 || x > 7)  over = 1;
    if(y < 0 || y > 7)  over = 1;
    p = SNAKE_LEN_ADDR;
    int len = *p;
    int i;
    for(i = 1; i < len; i++){
        get_snake(i);
        p = GET_SNAKE_ADDR;
        int cur_x = *(p+2);
        int cur_y = *(p+3);
        if(x == cur_x && y == cur_y) 
            over = 1;
    }
    p =  CHECK_OVER_ADDR;
    *p = over;
}

void get_food(){

}

void show(){
    int *p = SNAKE_MAP_ADDR;
    int map_data1 = *p;
    int map_data2 = *(p+1);

    p = LED_DOT1_ADDR;
    *p = map_data1;
    p = LED_DOT2_ADDR;
    *p = map_data2;
}

void update_snake_map(){
    int map_data1 = 0;
    int map_data2 = 0;

    // int *p = SNAKE_MAP_ADDR;
    // *p = 0;
    int *p = SNAKE_LEN_ADDR;
    int len = *p;
    int i;
    for(i = 0; i < len; i++){
        get_snake(i);
        p = GET_SNAKE_ADDR;
        int x = *(p+2);
        int y = *(p+3);
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
    *p = map_data1;
    p++;
    *p = map_data2;
}

void update_food_map(int x, int y){
    int *p = SNAKE_MAP_ADDR;
    int map_data1 = *p;
    int map_data2 = *(p+1);
    if(x < 4) {
        int t = (x<<3) + y;
        map_data1 |= 1 << t;
        *p = map_data1;
    }
    else {
        x -= 4;
        int t = (x<<3) + y;
        map_data2 |= 1 << t;
        *(p+1) = map_data2;
    }
}

void snake_main(){
    init();
    int x = 3, y = 3;
    int *p;
    set_snake(0, -1, -1, x, y);
    update_snake_map();
    int food_ok = 0;
    while(food_ok == 0){
        rand();
        int *p = RAND_ADDR;
        int t = *p;
        t = t & 0x0000003f;
        x = t >> 3;
        y = t & 0x00000007;
        if(x != 3 || y != 3) 
            food_ok = 1;
    }
    p = FOOD_X_ADDR;
    *p = x;
    p = FOOD_Y_ADDR ;
    *p = y;
    update_food_map(x, y);

    // int *q = SNAKE_LEN_ADDR;
    // *q = 2;
    // set_snake(1, 3, 3, 3, 4);
    
    while (1)
    {
        // delay(1000);

        // int i = 0;
        // for(i = 0; i < 1; i++) ;
        rand();
        *p = RAND_ADDR;
        int  t = *p;
        p = NUM_ADDR;
        *p = t;

        int dx, dy;
        // ----- input ----- 
        pressButton();
        p = PRESSBUTTON_ADDR;
        int btn_dir = *p;
        p = NUM_ADDR;
        *p = btn_dir;
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

        get_snake(0);
        p = GET_SNAKE_ADDR ;
        x = *(p+2);
        y = *(p+3);

        // x += dx;
        // y += dy;

        set_number(( x << 24 )| (y << 16 )| (dx << 8) | (dy));
        // int tmp = ( x << 24 )| (y << 16 )| (dx << 8) | (dy);
        // p = NUM_ADDR;
        // *p = tmp;
        // int x = *(p+2);
        // int y = *(p+3);
        // x += dx ; y += dy;

        

        // set_snake(0, -1, -1, x, y);

        update_snake_map();
        p = FOOD_X_ADDR;
        int food_x = *p;
        p = FOOD_Y_ADDR;
        int food_y = *p;
        update_food_map(food_x, food_y); 
        // ----- show ------
        show();
    }
    
}


// rd:BUTTON bfaf_e004
// input data:1110,1101,1011,0111
#define NUM_ADDR           0xbfaff010
#define PRESSBUTTON_ADDR   0x000aaaa0
#define BUTTON             0xbfafe004

void pressButton(){
    while(1){
        int *p = BUTTON;
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
}
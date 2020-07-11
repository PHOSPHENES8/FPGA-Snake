#define NUM_ADDR       0xbfaff010 
#define LED_ADDR       0xbfaff000 

void mytesting()
{
    int* brightness;
    brightness = LED_ADDR;
    *brightness = 0xffff;    
    int second;
    int i, j, k;
    second = 0;

    int *numDisplay;
    numDisplay = NUM_ADDR;
    *numDisplay = 0x8888;
    while(1){
            while(1){
                *numDisplay = 0x6666;
                second++;
                if(second == 60000-2){
                    break;
                }
                *brightness = 0x0000;
                for(i=0;i<second;i=i+1000);  
                *brightness = 0xffff;
                for(i=second;i<60000;i=i+1000); 
            }   

            while(1){
                *numDisplay = 0x2333;
                second--;
                if(second == 0){
                    break;
                }
                *brightness = 0x0000;
                for(i=0;i<second;i=i+1000);   
                *brightness = 0xffff;
                for(i=second;i<60000;i=i+1000);
            }  

            while(1){
                *numDisplay = 0x6666;
                second++;
                if(second == 60000-2){
                    break;
                }
                *brightness = 0x0000;
                for(i=0;i<second;i=i+1000);  
                *brightness = 0xffff;
                for(i=second;i<60000;i=i+1000); 
            }   

            while(1){
                *numDisplay = 0x2333;
                second--;
                if(second == 0){
                    break;
                }
                *brightness = 0x0000;
                for(i=0;i<second;i=i+1000);   
                *brightness = 0xffff;
                for(i=second;i<60000;i=i+1000);
            }          
    }


}
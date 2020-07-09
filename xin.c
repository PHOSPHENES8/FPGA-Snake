
void f()
{
    short *love,*p,*q;
    int c,r;
    love=0xbfaf8000;
    *love=0x0000;
    *(love+1)=0x0066;
    *(love+2)=0x00ff;    
    *(love+3)=0x00ff;    
    *(love+4)=0x00ff;    
    *(love+5)=0x007e;    
    *(love+6)=0x003c;    
    *(love+7)=0x0018;    

    while (1)
    {
        p=0xbfaff000;
        q=0xbfaff004;
        *p=0xff000000;
        *q=0x00000000;
        for(c = 0; c<8;c++)
        {
            if(c==0)
            {
                *p=0x7f00;
            }
            else if(c==1)
            {
                *p=0xbf00;
            }
            else if(c==2)
            {
                *p=0xdf00;
            }
            else if(c==3)
            {
                *p=0xef00;
            }
            else if(c==4)
            {
                *p=0xf700;
            }
            else if(c==5)
            {
                *p=0xfb00;
            }
            else if(c==6)
            {
                *p=0xfd00;
            }
            else
            {
                *p=0xfe00;
            }
            for(r = 0;r<8;r++)
            {
                *q=love+r;
            }
        }
    }
}
# FPGA-Snake

在FPGA上玩贪吃蛇:smile:

## Usage 

FPGA运行的程序是`__func_test__/soft/snake.c`,在`__func_test__/soft/`目录下编译`snake.c`

```
make clean
make
```
`make clean`会删除之前编译出来的`snake.s`，`make`会把`snake.c`编译成`snake.s`，然后把汇编指令删掉一些注释，把`$sp`，`$fp`换成`sp`，和`fp`，最后将编译结果放到`soft/func/inst/my_test.S`。

编译`start.S`,把程序链接到一起。进入`__func_test__/soft/func`

```
make clean
make
```

这时候就将指令转换成机器码写入到coe文件，最后vivado生成bitstream

## 地址管理

如果在`snake.c`中使用全局变量，情况会变得比较复杂。使用带返回类型的函数类似

```c
int x ,y;
void snake_main(){
    x = 0x1234;
    y = 0x5678
}
```
这样的语句就会编译出类似于下面的汇编指令
```assembly
lui	$28,%hi(__gnu_local_gp)
addiu	$28,$28,%lo(__gnu_local_gp)
.cprestore	0
lw	$3,%got(x)($28)
li	$2,4660			# 0x1234
sw	$2,0($3)
lw	$3,%got(y)($28)
li	$2,22136			# 0x5678
sw	$2,0($3)
```
在用龙芯的`Makefile`进行make的时候可能会出问题，所以采用手动管理内存地址的方法。给每个全局变量和函数返回值分配一个地址用来存放数据，保证每个不会冲突

### 访问外设

每个外设都通过一个特殊的地址对应`confreg`中的一个寄存器
```c
#define LED_ADDR                0xbfaff000
#define LED_RG0_ADDR            0xbfaff004
#define LED_RG1_ADDR            0xbfaff008
#define NUM_ADDR                0xbfaff010
#define SWITCH_ADDR             0xbfaff020
#define LED_DOT1_ADDR           0xbfaf8044
#define LED_DOT2_ADDR           0xbfaf8048
#define BUTTON_ADDR             0xbfaf804c
```

将数据存放到这些寄存器，硬件电路更具这些寄存器的值控制外设,比如控制数码管显示的数字

```c
/*
 *  数码管显示的值就是x 
*/ 
void set_number(int x){
    int *p = NUM_ADDR;
    *p = x;
}
```

访问外设的函数
```c
void set_number(int x);           // 让数码管显示x
void set_led(int x);              // 控制LED灯的亮灭，0xffff是全灭，0x000是全亮
void flush(int rank, int data);   // LCD屏rank行显示data
void pressButton();               // 获取键盘输入
void show();                      // 将蛇和事物显示在8*8dot
```


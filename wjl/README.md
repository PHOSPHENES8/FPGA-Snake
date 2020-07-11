# READ ME

## snake main

- `set_number(int)` : 设置数码管

- `set_led(int)`：设置led

- `rand()`：随机数

- `pressButton()`

- `set_snake(int idx, int pre_x, int pre_y, int x, int y)`：更新snake node

- `get_snake(int idx)`：

- `snake_move(int dir, int dx, int dy)` : 移动，（dir 和 dx dy对应）

- `check_over`:目前只检查越界

- `show()` :显示,两个32位数存在LED_DOT1_ADDR,LED_DOT2_ADDR

- `update_snake_map`,`update_food_map`:更新，先更新snake在更新food，food_map依赖snake_map

> :warning:有些语句可能没测过，比如switch可能会出错

## 8 * 8 dot

这些文件要提供硬件支持

- xdc
- confreg
- soc_lite_top.v
- 好像没了

## make

对于make方法，让整个过程全自动

1. 保持soft中相对路径，修改tran.py，`soft/Makefile`中一些命名
2. 在soft目录中`make clean`,`make`
3. `soft/func`目录中`make clean` ,`make `

## 访问地址调用函数
```c
void store(int addr, int val)//*addr=val
```

```c
void load(int addr1, int addr2)//*addr1=*addr2
```

```c
void geTdata(int *x, int addr)//x=*addr
```



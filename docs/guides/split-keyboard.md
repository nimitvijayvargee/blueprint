| title | Split Keyboard |
| --- | --- |
| description | Make your own split keyboard |


# Wireless split

Hii! Do you not want to get carpal tunnel? Or just think that split keyboard are cool? Then you are in the right place!

In this guide you will be learning how to make a wireless split keyboard

This guide is meant to be an extension to the [hackpad guide](https://hackpad.hackclub.com/guide), so if you are a total beginner to keyboards/electronics read that first, and then come back here :)

In this tutorial we a going to use the same form factor board as in the hackpad tutorial, but with different internals, instead of a rp2040 it has a nrf52840 chip inside, which has wireless capabilities.

## Installing Libraries

After you created the kicad project, we need to install some libraries. We will be installing the same OPL libraries as in the hackpad tutorial, here is the [link](https://hackpad.hackclub.com/guide#pcb_design) for that section.

Unlike in the hackpad tutorial, where we use the official seeed footprints, this time we need to install install a custom footprint based on the official ones, because the battery charging pins are on the bottom of the board, which we will be using to charge the battery, that are not accessible if we use the official footprints.

You can download it from [github](https://github.com/mito-keyboard/mito-simplified/blob/main/modified-XIAO-nRF52840-SMD.kicad_mod), move it into you KiCad project folder, and add it like a the opl library.

We also need to download the library for the switches, we will be using [marbastlib](https://github.com/ebastler/marbastlib), you can find the installation instructions in the repo

Also instal [panelization.pretty](https://github.com/madworm/Panelization.pretty) for mousebites

## Schematic

Now we can start creating our schematic.

### Sheets

Because we are creating a split, we esantilay want to have to same circuit for both sides, but not the same layout. We can achieve this by using hierarchical sheets. This way the circuitry we make will be duplicated

To create a hierarchical sheet click on this on the right sidebar or press <kbd>S</kbd>

![image of sheets icon](https://hc-cdn.hel1.your-objectstorage.com/s/v3/efaa0a56ce293a919388c76a0a62ff41d1e1388d_screenshot_from_2025-09-18_17-05-12.png)

Now draw a rectangle and left click, a popup should appear:

![image of popup](https://hc-cdn.hel1.your-objectstorage.com/s/v3/3f98026538ad029f426aab7c6060405b8318c13b_image.png)

Change the `Sheetname` to `left`, and the `Sheetfile` to `side.kicad_sch`, and click ok

Now create another sheet, set `Sheetfile` to `side.kicad_sch`, but the `Sheetname` to `right`.

Your root sheet look something like this:

![image of root sheet](https://hc-cdn.hel1.your-objectstorage.com/s/v3/232d7595f84c8177ca4b1d17ed85b5323bd76470_image.png)

And your left side bar something like this:

![image of left side bar](https://hc-cdn.hel1.your-objectstorage.com/s/v3/9f867ffd0ee5d93b4bf2c06b2958c7e39a89a9f4_image.png)

You can now double click on one of the sheet rectangle in the root sheet, or in the left side bar. You can now place down a switch for example, and navigate to the other sub/child sheet, you will notice that the switch that you placed down in the other sub sheet, is also in this sub sheet.

![left sheet](https://hc-cdn.hel1.your-objectstorage.com/s/v3/af42ed0710e41f69f9a204e6d65187a265a18988_image.png)
![right sheet](https://hc-cdn.hel1.your-objectstorage.com/s/v3/063c21ddabb9d0133596868089eef84a38a7c34a_image.png)

## Circuitry

Now finally we can start to design our keyboard!!!

Add the `XIAO-nRF52840-SMD` symbol:

![symbol add xiao](https://hc-cdn.hel1.your-objectstorage.com/s/v3/9f32be16de764ec09f8353341732586cadcf3e31_image.png)

a switch `SW_Push`:
![symbol add switch](https://hc-cdn.hel1.your-objectstorage.com/s/v3/508824b27185819cc122c0095860bb55e2b5bc6a_image.png)

and a diode `D` (you will see later why we need this):
![symbol add diode](https://hc-cdn.hel1.your-objectstorage.com/s/v3/bfb718542115ac52a37f3bf214ca7d14b19877ea_image.png)

### Keyboard Matrix

You may be wondering, why did we need to place down a diode???? You may also notice that the xiao doesn't have enough pins for a full half of a split keyboard. In comes the humble keyboard matrix, with it we only have to connect one pin per column and row, drastically reducing the number of pins needed for a keyboard.

The matrix works by giving power to each column one at a time, and checking which keys are pressed down in that column. We need diodes to prevent *ghosting*, where by pressing down one key, the keyboard detects more then one keypress. If you want you can read into [keyboard matrixes here](https://docs.qmk.fm/how_a_matrix_works)

For now all you need to know is that every key has its own diode, this is like one unit:

![image of diode and button](https://hc-cdn.hel1.your-objectstorage.com/s/v3/33681c7410a242de5ab273f34b54981f62390f1e_image.png)

You can now make a matrix out of these *units*, you have to connect the switches to the columns, and the diodes to the rows. In this example in one row I only have one button, which is for my thumb:

![image of complete keyboard matrix](https://hc-cdn.hel1.your-objectstorage.com/s/v3/8c6b3592f3e6753ceb8ae607c27ebd0e00642e0b_image.png)

You may notice that there are *labels*, like `COL0`, `COL1`, etc. and `ROW0` and `ROW1`. You can place these using the <kbd>L</kbd> shortcut or from the right sidebar. We can use labels to clean up our schematic, instead of routing from our xiao to the column, we just place a label with the same name at the column and one at the xiao's pin:

![image of label underlined](https://hc-cdn.hel1.your-objectstorage.com/s/v3/a90b3c58bd5df7542c97ac9a3628a8a4d1532f31_screenshot_from_2025-09-19_19-02-35.png)

### Battery

Adding a battery is really easy, because the xiao already has battery management built in. We need to add two pads where the battery can be connected to the pcb. In this case I used two test points, one for negative side of the battery(aka ground), and for the live side (vbat):
![battery test points](https://hc-cdn.hel1.your-objectstorage.com/s/v3/8e1525612dd7caaf1f778b6a265cf52f8bf205cf_image.png) 

And then connected `VBAT` to the `BAT` pin of the xiao
![xiao with VBAT connected](https://hc-cdn.hel1.your-objectstorage.com/s/v3/036a2fd978cb7d53da835fcdc22340f0d6523826_image.png)

#### Sensing the battery voltage

This is an optional feature, that lets you see from you computer how much juice is left in your keyboards

We can achieve this by using a voltage divider, basically two resistors that divides the battery voltage by an amount, so we can measure it with our xiao. It looks like this, make sure to use these values for the resistors:

![voltage divider](https://hc-cdn.hel1.your-objectstorage.com/s/v3/87baf956562da1c00fbacef4ac0aca21ecf18782_image.png)

And then add the corresponding label (`BT_PIN` in our my case) to the xiao, make sure that it is an analogue pin (has A* ate the end):

![xiao with battery sense](https://hc-cdn.hel1.your-objectstorage.com/s/v3/68369d14d01bcd017b65245544f49e787819f39e_image.png)

### Mounting points

Add mounting point symbols to the left/right schematics

### Mousebites

You should add three mounting points to the root sheet, we will assign mousebite footprints to these later on

![mounting symbols](https://hc-cdn.hel1.your-objectstorage.com/s/v3/5b231b23c9059899a5ae47f747ec0d6b5d030035_image.png)

## Footprints

Your done with you schematic!!! 

Here is how mine looks:
![image of authors schematic](https://hc-cdn.hel1.your-objectstorage.com/s/v3/ee8f02e3d22dab1d87f76df884054d016a0411cf_image.png)

Now its time to assign some footprints! First, open the footprint assigner tool.

For the xiao assign the custom footprint that you downloaded earlier, its name should be `modified-XIAO-nRF52840-SMD`

For the buttons I used chalk hotswap sockets from `marbastlib`, but you can use any other keyswitch.

For the diodes I used `1N5819` which are SMD, so its a bit harder to solder, but I recommend them if you want a compact design, and don't want to place THT diodes not next to the switches,rather some other place on the PCB. The footprint for this is `Diode_SMD:D_SOD-123`

For the resistors I recommend `Resistor_SMD:R_0805_2012Metric`, but you can use any other package.

For the mousebites/breakoffs assign the `panelization:mouse-bite-5mm-slot` footprints

For the testpoints/battery pads I used `TestPoint:TestPoint_Pad_D2.0mm`, but you can use larger.

## PCB

This part is basically the same as hackpad, so layout, then routing, except for the mousebites. So in this section I will give some tips for laying out a split keyboard

Here is my final pcb:
![pcb](https://hc-cdn.hel1.your-objectstorage.com/s/v3/ac8bc9cfffae5f68557d8226a8db07c000685a9e_image.png)

### If the two half are symmetrical

then you should make the edge.cuts for one half, select all the edge.cuts, right click, and `flip horizontal`, and now you have two symmetrical edge.cuts

### Mousebites layout

You should find two flat side of you two pcbs, place the mousebites there, and edit the edge cuts so it matches the mousebites footprint template:

![flat side with mousebites](https://hc-cdn.hel1.your-objectstorage.com/s/v3/23e81cdffe61fe6fedf424bdde600486798ad084_image.png)

## Firmware

You will have to use the [ZMK](https://zmk.dev/docs) firmware, ZMK has excellent documentation and tutorials, and it explains it better then I could. It has a learning curve, but there is no getting around that

[Back to Guides](/guides)

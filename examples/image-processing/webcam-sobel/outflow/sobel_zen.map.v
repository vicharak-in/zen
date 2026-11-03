
//
// Verific Verilog Description of module sobel_zen_top
//

module sobel_zen_top (clk, btn1, uart_rx, uart_tx, led1, led2) /* verific EFX_ATTRIBUTE_NETLIST__EFINITY_VERSION=2026.1.132 */ ;
    input clk /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(10)
    input btn1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(11)
    input uart_rx /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(12)
    output uart_tx /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(13)
    output led1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(14)
    output led2 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(15)
    
    wire [7:0]n10_2;
    wire \u_sobel/start_r ;
    wire \u_sobel/core_valid ;
    wire [22:0]n42_23;
    wire [22:0]n42_18;
    wire [22:0]n42_17;
    wire [7:0]\u_sobel/rx_data ;
    wire rx_seen;
    wire [7:0]n10_5;
    wire \u_sobel/n699 ;
    wire \u_sobel/n698 ;
    wire \u_sobel/n697 ;
    wire \u_sobel/n696 ;
    wire \u_sobel/n695 ;
    wire \u_sobel/n694 ;
    wire \u_sobel/n693 ;
    wire \u_sobel/n692 ;
    wire [7:0]n10_7;
    wire [7:0]n10_6;
    wire frame_done;
    wire rst;
    wire \u_sobel/pop ;
    wire [7:0]\u_sobel/pix ;
    
    wire \btn_sync[0] ;
    wire [22:0]rx_cnt;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(31)
    wire [7:0]por;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(19)
    
    wire \add_31/n2 ;
    wire [22:0]done_cnt;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(29)
    
    wire \u_sobel/add_184/n2 ;
    wire [10:0]\u_sobel/u_core/pt ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    
    wire \u_sobel/u_core/add_14/n2 ;
    wire [5:0]\u_sobel/cnt ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(63)
    wire [23:0]\u_sobel/n71 ;
    
    wire \u_sobel/add_182/n2 ;
    wire [7:0]\u_sobel/u_core/n75 ;
    
    wire \u_sobel/u_core/add_13/n2 ;
    wire [10:0]\u_sobel/u_core/pb ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    
    wire \u_sobel/u_core/add_12/n2 ;
    wire [7:0]\u_sobel/u_core/n53 ;
    
    wire \u_sobel/u_core/add_11/n2 ;
    wire [10:0]\u_sobel/u_core/pl ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    
    wire \u_sobel/u_core/add_10/n2 ;
    wire [7:0]\u_sobel/u_core/n31 ;
    
    wire \u_sobel/u_core/add_9/n2 ;
    wire [15:0]\u_sobel/flush_left ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(53)
    wire [4:0]\u_sobel/wp ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(59)
    wire [23:0]\u_sobel/tmo ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(55)
    wire [10:0]\u_sobel/u_core/pr ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    
    wire \u_sobel/u_core/add_8/n2 ;
    wire [7:0]\u_sobel/u_core/n9 ;
    
    wire \u_sobel/u_core/add_7/n2 ;
    wire [5:0]\u_sobel/n590 ;
    
    wire \u_sobel/add_106/n2 , \u_sobel/in_frame , \u_sobel/flushing ;
    wire [15:0]\u_sobel/wreg ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(43)
    wire [15:0]\u_sobel/hreg ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(45)
    wire [4:0]\u_sobel/rp ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(61)
    
    wire \sub_14/add_2/n2 , \u_sobel/u_core/add_23/n2 ;
    wire [2:0]\u_sobel/hst ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(41)
    wire [9:0]\u_sobel/u_core/col ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(34)
    
    wire \u_sobel/u_core/add_248/n2 , \u_sobel/sub_72/add_2/n2 ;
    wire [1:0]\u_sobel/u_core/st ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(32)
    wire [15:0]\u_sobel/u_core/row ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(36)
    wire [15:0]\u_sobel/u_core/skip ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(38)
    wire [15:0]\u_sobel/u_core/rd ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(42)
    wire [7:0]\u_sobel/u_core/a0 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(44)
    wire [7:0]\u_sobel/u_core/a1 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(44)
    wire [7:0]\u_sobel/u_core/a2 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(44)
    wire [7:0]\u_sobel/u_core/b0 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(46)
    wire [7:0]\u_sobel/u_core/b1 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(46)
    wire [7:0]\u_sobel/u_core/b2 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(46)
    wire [7:0]\u_sobel/u_core/c0 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(48)
    wire [7:0]\u_sobel/u_core/c1 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(48)
    wire [7:0]\u_sobel/u_core/c2 ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(48)
    wire [7:0]\u_sobel/u_core/pix ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(40)
    
    wire \u_sobel/u_core/sub_41/add_2/n2 , \u_sobel/u_core/sub_16/add_2/n2 , 
        \u_sobel/u_core/sub_17/add_2/n2 , \u_sobel/u_core/sub_20/add_2/n2 , 
        \u_sobel/u_core/sub_21/add_2/n2 ;
    wire [10:0]\u_sobel/u_core/n97_q ;
    
    wire n1241_q, n1253_q;
    wire [22:0]n115;
    
    wire \sub_18/add_2/n44 , \sub_18/add_2/n42 , \sub_18/add_2/n40 , \sub_18/add_2/n38 , 
        \sub_18/add_2/n36 , \sub_18/add_2/n34 , \sub_18/add_2/n32 , \sub_18/add_2/n30 , 
        \sub_18/add_2/n28 , \sub_18/add_2/n26 , \sub_18/add_2/n24 , \sub_18/add_2/n22 , 
        \sub_18/add_2/n20 , \sub_18/add_2/n18 , \sub_18/add_2/n16 , \sub_18/add_2/n14 , 
        \sub_18/add_2/n12 , \sub_18/add_2/n10 , \sub_18/add_2/n8 , \sub_18/add_2/n6 , 
        \sub_18/add_2/n4 ;
    wire [22:0]n42_22;
    
    wire \sub_14/add_2/n44 ;
    wire [22:0]n42_21;
    
    wire \sub_14/add_2/n42 ;
    wire [22:0]n42_20;
    
    wire \sub_14/add_2/n40 ;
    wire [22:0]n42_19;
    
    wire \sub_14/add_2/n38 , \sub_14/add_2/n36 , \sub_14/add_2/n34 ;
    wire [22:0]n42_16;
    
    wire \sub_14/add_2/n32 ;
    wire [22:0]n42_15;
    
    wire \sub_14/add_2/n30 ;
    wire [22:0]n42_14;
    
    wire \sub_14/add_2/n28 ;
    wire [22:0]n42_13;
    
    wire \sub_14/add_2/n26 ;
    wire [22:0]n42_12;
    
    wire \sub_14/add_2/n24 ;
    wire [22:0]n42_11;
    
    wire \sub_14/add_2/n22 ;
    wire [22:0]n42_10;
    
    wire \sub_14/add_2/n20 ;
    wire [22:0]n42_9;
    
    wire \sub_14/add_2/n18 ;
    wire [22:0]n42_8;
    
    wire \sub_14/add_2/n16 ;
    wire [22:0]n42_7;
    
    wire \sub_14/add_2/n14 ;
    wire [22:0]n42_6;
    
    wire \sub_14/add_2/n12 ;
    wire [22:0]n42_5;
    
    wire \sub_14/add_2/n10 ;
    wire [22:0]n42_4;
    
    wire \sub_14/add_2/n8 ;
    wire [22:0]n42_3;
    
    wire \sub_14/add_2/n6 ;
    wire [5:0]\u_sobel/n597 ;
    
    wire \u_sobel/sub_107/add_2/n10 , \u_sobel/sub_107/add_2/n8 , \u_sobel/sub_107/add_2/n6 , 
        \u_sobel/sub_107/add_2/n4 ;
    wire [15:0]\u_sobel/n276 ;
    
    wire \u_sobel/sub_72/add_2/n30 , \u_sobel/sub_72/add_2/n28 , \u_sobel/sub_72/add_2/n26 , 
        \u_sobel/sub_72/add_2/n24 , \u_sobel/sub_72/add_2/n22 , \u_sobel/sub_72/add_2/n20 , 
        \u_sobel/sub_72/add_2/n18 , \u_sobel/sub_72/add_2/n16 , \u_sobel/sub_72/add_2/n14 , 
        \u_sobel/sub_72/add_2/n12 , \u_sobel/sub_72/add_2/n10 , \u_sobel/sub_72/add_2/n8 , 
        \u_sobel/sub_72/add_2/n6 ;
    wire [10:0]\u_sobel/u_core/n146 ;
    
    wire \u_sobel/u_core/sub_21/add_2/n20 , \u_sobel/u_core/sub_21/add_2/n18 , 
        \u_sobel/u_core/sub_21/add_2/n16 , \u_sobel/u_core/sub_21/add_2/n14 , 
        \u_sobel/u_core/sub_21/add_2/n12 , \u_sobel/u_core/sub_21/add_2/n10 , 
        \u_sobel/u_core/sub_21/add_2/n8 , \u_sobel/u_core/sub_21/add_2/n6 , 
        \u_sobel/u_core/sub_21/add_2/n4 ;
    wire [10:0]\u_sobel/u_core/n134 ;
    
    wire \u_sobel/u_core/sub_20/add_2/n18 , \u_sobel/u_core/sub_20/add_2/n16 , 
        \u_sobel/u_core/sub_20/add_2/n14 , \u_sobel/u_core/sub_20/add_2/n12 , 
        \u_sobel/u_core/sub_20/add_2/n10 , \u_sobel/u_core/sub_20/add_2/n8 , 
        \u_sobel/u_core/sub_20/add_2/n6 , \u_sobel/u_core/sub_20/add_2/n4 ;
    wire [10:0]\u_sobel/u_core/n109 ;
    
    wire \u_sobel/u_core/sub_17/add_2/n20 , \u_sobel/u_core/sub_17/add_2/n18 , 
        \u_sobel/u_core/sub_17/add_2/n16 , \u_sobel/u_core/sub_17/add_2/n14 , 
        \u_sobel/u_core/sub_17/add_2/n12 , \u_sobel/u_core/sub_17/add_2/n10 , 
        \u_sobel/u_core/sub_17/add_2/n8 , \u_sobel/u_core/sub_17/add_2/n6 , 
        \u_sobel/u_core/sub_17/add_2/n4 ;
    wire [10:0]\u_sobel/u_core/n97 ;
    
    wire \u_sobel/u_core/sub_16/add_2/n18 , \u_sobel/u_core/sub_16/add_2/n16 , 
        \u_sobel/u_core/sub_16/add_2/n14 , \u_sobel/u_core/sub_16/add_2/n12 , 
        \u_sobel/u_core/sub_16/add_2/n10 , \u_sobel/u_core/sub_16/add_2/n8 , 
        \u_sobel/u_core/sub_16/add_2/n6 , \u_sobel/u_core/sub_16/add_2/n4 ;
    wire [15:0]\u_sobel/u_core/n252 ;
    
    wire \u_sobel/u_core/sub_41/add_2/n20 , \u_sobel/u_core/sub_41/add_2/n18 , 
        \u_sobel/u_core/sub_41/add_2/n16 , \u_sobel/u_core/sub_41/add_2/n14 , 
        \u_sobel/u_core/sub_41/add_2/n12 , \u_sobel/u_core/sub_41/add_2/n10 , 
        \u_sobel/u_core/sub_41/add_2/n8 , \u_sobel/u_core/sub_41/add_2/n6 , 
        \u_sobel/u_core/sub_41/add_2/n4 ;
    wire [8:0]\u_sobel/u_core/n201 ;
    
    wire \u_sobel/u_core/n200 , \u_sobel/u_core/add_248/n14 , \u_sobel/u_core/add_248/n12 , 
        \u_sobel/u_core/add_248/n10 , \u_sobel/u_core/add_248/n8 , \u_sobel/u_core/add_248/n6 , 
        \u_sobel/u_core/add_248/n4 ;
    wire [11:0]\u_sobel/u_core/sum ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    
    wire \u_sobel/u_core/add_23/n20 , \u_sobel/u_core/add_23/n18 , \u_sobel/u_core/add_23/n16 , 
        \u_sobel/u_core/add_23/n14 , \u_sobel/u_core/add_23/n12 , \u_sobel/u_core/add_23/n10 , 
        \u_sobel/u_core/add_23/n8 , \u_sobel/u_core/add_23/n6 , \u_sobel/u_core/add_23/n4 , 
        \u_sobel/add_106/n10 , \u_sobel/add_106/n8 , \u_sobel/add_106/n6 , 
        \u_sobel/add_106/n4 , \u_sobel/u_core/n8 , \u_sobel/u_core/add_7/n14 , 
        \u_sobel/u_core/add_7/n12 , \u_sobel/u_core/add_7/n10 , \u_sobel/u_core/add_7/n8 , 
        \u_sobel/u_core/add_7/n6 , \u_sobel/u_core/add_7/n4 , \u_sobel/u_core/add_8/n18 , 
        \u_sobel/u_core/add_8/n16 , \u_sobel/u_core/add_8/n14 , \u_sobel/u_core/add_8/n12 , 
        \u_sobel/u_core/add_8/n10 , \u_sobel/u_core/add_8/n8 , \u_sobel/sub_72/add_2/n4 , 
        \u_sobel/u_core/add_8/n6 , \u_sobel/u_core/add_8/n4 ;
    wire [7:0]n10_3;
    
    wire \add_31/n4 , \u_sobel/u_core/n30 , \u_sobel/u_core/add_9/n14 , 
        \u_sobel/u_core/add_9/n12 , \u_sobel/u_core/add_9/n10 , \u_sobel/u_core/add_9/n8 , 
        \u_sobel/u_core/add_9/n6 ;
    wire [7:0]n10_4;
    
    wire \add_31/n6 , \u_sobel/u_core/add_9/n4 , \u_sobel/u_core/add_10/n18 ;
    wire [1:0]\u_sobel/u_rx/st ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(25)
    
    wire \u_sobel/u_core/add_10/n16 , \u_sobel/u_core/add_10/n14 , \u_sobel/u_core/add_10/n12 ;
    wire [2:0]\u_sobel/u_rx/bi ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(29)
    wire [4:0]\u_sobel/u_rx/cnt ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(27)
    
    wire \u_sobel/u_core/add_10/n10 , \u_sobel/u_rx/sy[0] ;
    wire [7:0]\u_sobel/u_rx/sh ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(31)
    
    wire \u_sobel/u_core/add_10/n8 , \u_sobel/u_core/add_10/n6 , \u_sobel/u_core/add_10/n4 , 
        \u_sobel/u_core/n52 , \u_sobel/u_core/add_11/n14 , \u_sobel/u_core/add_11/n12 , 
        \u_sobel/u_core/add_11/n10 , \u_sobel/u_core/add_11/n8 , \u_sobel/u_core/add_11/n6 , 
        \u_sobel/u_core/add_11/n4 , \u_sobel/u_core/add_12/n18 , \u_sobel/u_core/add_12/n16 , 
        \u_sobel/u_core/add_12/n14 , \u_sobel/u_core/add_12/n12 , \u_sobel/u_core/add_12/n10 , 
        \u_sobel/u_core/add_12/n8 , \u_sobel/u_core/add_12/n6 , \u_sobel/u_core/add_12/n4 , 
        \u_sobel/u_core/n74 , \u_sobel/u_core/add_13/n14 , \u_sobel/u_core/add_13/n12 , 
        \u_sobel/u_core/add_13/n10 , \u_sobel/u_core/add_13/n8 , \u_sobel/u_core/add_13/n6 , 
        \u_sobel/u_core/add_13/n4 , \u_sobel/add_182/n44 , \u_sobel/add_182/n42 , 
        \u_sobel/add_182/n40 , \u_sobel/add_182/n38 , \u_sobel/add_182/n36 , 
        \u_sobel/add_182/n34 , \u_sobel/add_182/n32 , \u_sobel/add_182/n30 , 
        \u_sobel/u_rx/sy[1] , \u_sobel/add_182/n28 , \u_sobel/add_182/n26 , 
        \u_sobel/add_182/n24 , \u_sobel/add_182/n22 , \u_sobel/add_182/n20 , 
        \u_sobel/add_182/n18 , \u_sobel/add_182/n16 , \u_sobel/add_182/n14 , 
        \add_31/n8 , \u_sobel/add_182/n12 , \u_sobel/add_182/n10 , \u_sobel/add_182/n8 , 
        \u_sobel/add_182/n6 , \u_sobel/add_182/n4 , \u_sobel/u_core/add_14/n18 , 
        \u_sobel/u_core/add_14/n16 , \u_sobel/u_core/add_14/n14 , \u_sobel/u_core/add_14/n12 , 
        \u_sobel/u_core/add_14/n10 , \u_sobel/u_core/add_14/n8 , \u_sobel/u_core/add_14/n6 ;
    wire [9:0]\u_sobel/u_tx/sh ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(20)
    wire [3:0]\u_sobel/u_tx/left ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(22)
    
    wire \u_sobel/u_core/add_14/n4 ;
    wire [4:0]\u_sobel/u_tx/cnt ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(24)
    
    wire n1277;
    wire [15:0]\u_sobel/n240 ;
    
    wire \u_sobel/add_184/n28 , \u_sobel/add_184/n26 , \u_sobel/add_184/n24 , 
        \u_sobel/add_184/n22 , \u_sobel/sub_107/add_2/n2 , \u_sobel/add_184/n20 ;
    wire [22:0]n42_2;
    
    wire \sub_14/add_2/n4 , \u_sobel/add_184/n18 , \u_sobel/add_184/n16 , 
        \sub_18/add_2/n2 , \u_sobel/add_184/n14 , \u_sobel/add_184/n12 , 
        \u_sobel/add_184/n10 , \u_sobel/add_184/n8 , \u_sobel/add_184/n6 , 
        \u_sobel/add_184/n4 ;
    wire [7:0]n10_8;
    
    wire \add_31/n12 , \add_31/n10 , \btn_sync[1] , n1276, n1275, 
        \not_equal_3/n15 , \u_sobel/n560 ;
    wire [15:0]\u_sobel/n293 ;
    
    wire ceg_net25, \u_sobel/n69 , \u_sobel/n818 , \u_sobel/n805 , \u_sobel/n816 , 
        \u_sobel/n238 , \u_sobel/n815 , \u_sobel/n865 , \u_sobel/n866 ;
    wire [10:0]\u_sobel/u_core/ay ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    
    wire n1274, \u_sobel/select_57/Select_0/n8 , \u_sobel/hdr_step , \u_sobel/dims_ok , 
        \u_sobel/n905 ;
    wire [9:0]\u_sobel/u_core/n317 ;
    
    wire \u_sobel/u_core/n1144 , \u_sobel/u_core/n199 ;
    wire [7:0]\u_sobel/u_core/n241 ;
    
    wire \u_sobel/u_core/n1637 , \u_sobel/n1141 , \u_sobel/n1136 , ceg_net27, 
        \u_sobel/u_core/n1543 ;
    wire [15:0]\u_sobel/u_core/n542 ;
    
    wire ceg_net10, n461, \u_sobel/u_core/n1655 , \u_sobel/u_core/n1827 , 
        \u_sobel/u_core/n1633 , \u_sobel/u_core/not_equal_40/n31 , \u_sobel/u_core/n1014 , 
        \u_sobel/u_core/n1019 , \u_sobel/u_core/n1024 , \u_sobel/u_core/n1029 , 
        \u_sobel/u_core/n1034 , \u_sobel/u_core/n1039 , \u_sobel/u_core/n1044 , 
        \u_sobel/u_core/n1049 , \u_sobel/u_core/n1054 , \u_sobel/u_core/n1059 , 
        \u_sobel/u_core/n1064 , \u_sobel/u_core/n1069 , \u_sobel/u_core/n1074 , 
        \u_sobel/u_core/n1079 , \u_sobel/u_core/n1084 ;
    wire [1:0]\u_sobel/u_core/n400 ;
    
    wire \u_sobel/n1176 , \u_sobel/n1171 , \u_sobel/n1166 , \u_sobel/n1161 , 
        \u_sobel/n1156 , \u_sobel/n1151 , \u_sobel/n1146 ;
    wire [10:0]\u_sobel/u_core/ax ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    
    wire ceg_net69, \u_sobel/u_rx/n393 ;
    wire [2:0]\u_sobel/u_rx/n134 ;
    
    wire ceg_net53;
    wire [4:0]\u_sobel/u_rx/n119 ;
    
    wire ceg_net51, n1273, \u_sobel/u_rx/n445 ;
    wire [1:0]\u_sobel/u_rx/n116 ;
    wire [9:0]\u_sobel/u_tx/n65 ;
    wire [3:0]\u_sobel/u_tx/n76 ;
    
    wire ceg_net57;
    wire [4:0]\u_sobel/u_tx/n81 ;
    
    wire ceg_net35, \u_sobel/u_tx/n156 , \~ceg_net54 , \u_sobel/u_tx/n186 , 
        \u_sobel/u_tx/n196 , \u_sobel/n890 , \u_sobel/n615 , \u_sobel/n614 , 
        \u_sobel/n613 , \u_sobel/n612 , \u_sobel/n611 , \u_sobel/n933 , 
        \u_sobel/n940 , \u_sobel/n945 , \u_sobel/n950 , \u_sobel/n913 , 
        \u_sobel/n920 , \u_sobel/n925 , \u_sobel/n930 , \u_sobel/select_57/Select_1/n8 , 
        \~u_sobel/equal_55/n5 , n1080, n1081, n1082, n1083, n1084, 
        n1085, n1086, n1087, n1088, n1089, n1090, n1091, n1092, 
        n1093, n1094, n1095, n1096, n1097, n1098, n1099, n1100, 
        n1101, n1102, n1103, n1104, n1105, n1106, n1107, n1108, 
        n1109, n1110, n1111, n1112, n1113, n1114, n1115, n1116, 
        n1117, n1118, n1119, n1120, n1121, n1122, n1123, n1124, 
        n1125, n1126, n1127, n1128, n1129, n1130, n1131, n1132, 
        n1133, n1134, n1135, n1136, n1137, n1138, n1139, n1140, 
        n1141, n1142, n1143, n1144, n1145, n1146, n1147, n1148, 
        n1149, n1150, n1151, n1152, n1153, n1154, n1155, n1156, 
        n1157, n1158, n1159, n1160, n1161, n1162, n1163, n1164, 
        n1165, n1166, n1167, n1168, n1169, n1170, n1171, n1172, 
        n1173, n1174, n1175, n1176, n1177, n1178, n1179, n1180, 
        n1181, n1182, n1183, n1184, n1185, n1186, n1187, n1188, 
        n1189, n1190, n1191, n1192, n1193, n1194, n1195, n1196, 
        n1197, n1198, n1199, n1200, n1201, n1202, n1203, n1204, 
        n1205, n1206, n1207, n1208, n1209, n1210, n1211, n1212, 
        n1213, n1214, n1215, n1216, n1217, n1218, n1219, n1220, 
        n1221, n1222, n1223, n1224, n1225, n1226, n1227, n1228, 
        n1229, n1230, n1231, n1232, n1233, n1234, n1235, n1236, 
        n1237, n1238, n1239, n1240, n1241, n1242, n1243, n1244, 
        n1245, n1246, n1247, n1248, n1249, n1250, n1251, n1252, 
        n1253, n1254, n1255, n1256, n1257, n1258, n1259, n1260, 
        n1261, n1262, n1263, n1264, n1265, n1266, n1267, n1268, 
        n1269, n1270, n1271, n1272, n1278, n1279, n1280, n1281, 
        n1282, n1283, n1284, n1285, n1286, n1287, n1288, n1289;
    wire [10:0]\u_sobel/u_core/ay_q ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    
    wire n1187_q, n1214_q;
    wire [10:0]\u_sobel/u_core/n109_q ;
    
    wire \clk~O ;
    wire [10:0]\u_sobel/u_core/n134_q ;
    wire [10:0]\u_sobel/u_core/n146_q ;
    
    wire \u_sobel/u_core/sub_17/add_2/n20_q , \u_sobel/u_core/sub_21/add_2/n20_q ;
    
    EFX_FF \btn_sync[0]~FF  (.D(btn1), .CE(1'b1), .CLK(\clk~O ), .SR(1'b0), 
           .Q(\btn_sync[0] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \btn_sync[0]~FF .CLK_POLARITY = 1'b1;
    defparam \btn_sync[0]~FF .CE_POLARITY = 1'b1;
    defparam \btn_sync[0]~FF .SR_POLARITY = 1'b1;
    defparam \btn_sync[0]~FF .D_POLARITY = 1'b0;
    defparam \btn_sync[0]~FF .SR_SYNC = 1'b1;
    defparam \btn_sync[0]~FF .SR_VALUE = 1'b0;
    defparam \btn_sync[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[0]~FF  (.D(rx_cnt[0]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[0]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[0]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[0]~FF .D_POLARITY = 1'b0;
    defparam \rx_cnt[0]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[0]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[0]~FF  (.D(por[0]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[0]~FF .CLK_POLARITY = 1'b1;
    defparam \por[0]~FF .CE_POLARITY = 1'b1;
    defparam \por[0]~FF .SR_POLARITY = 1'b1;
    defparam \por[0]~FF .D_POLARITY = 1'b0;
    defparam \por[0]~FF .SR_SYNC = 1'b1;
    defparam \por[0]~FF .SR_VALUE = 1'b0;
    defparam \por[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[0]~FF  (.D(done_cnt[0]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[0]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[0]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[0]~FF .D_POLARITY = 1'b0;
    defparam \done_cnt[0]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[0]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/cnt[0]~FF  (.D(\u_sobel/n597 [0]), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/cnt [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/cnt[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/cnt[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/cnt[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/cnt[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/cnt[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[0]~FF  (.D(\u_sobel/n293 [0]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wp[0]~FF  (.D(\u_sobel/wp [0]), .CE(\u_sobel/core_valid ), 
           .CLK(\clk~O ), .SR(\u_sobel/n560 ), .Q(\u_sobel/wp [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/wp[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wp[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wp[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wp[0]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/wp[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wp[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wp[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[0]~FF  (.D(\u_sobel/tmo [0]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[0]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/tmo[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/in_frame~FF  (.D(1'b1), .CE(\u_sobel/n805 ), .CLK(\clk~O ), 
           .SR(\u_sobel/n816 ), .Q(\u_sobel/in_frame )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/in_frame~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/in_frame~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/in_frame~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/in_frame~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/in_frame~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/in_frame~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/in_frame~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flushing~FF  (.D(1'b1), .CE(\u_sobel/n238 ), .CLK(\clk~O ), 
           .SR(\u_sobel/n815 ), .Q(\u_sobel/flushing )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flushing~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flushing~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/flushing~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flushing~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flushing~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flushing~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flushing~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[0]~FF  (.D(\u_sobel/rx_data [0]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[0]~FF  (.D(\u_sobel/rx_data [0]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rp[0]~FF  (.D(\u_sobel/rp [0]), .CE(\u_sobel/pop ), 
           .CLK(\clk~O ), .SR(\u_sobel/n560 ), .Q(\u_sobel/rp [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/rp[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rp[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rp[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rp[0]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/rp[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rp[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rp[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hst[0]~FF  (.D(\u_sobel/select_57/Select_0/n8 ), .CE(\u_sobel/hdr_step ), 
           .CLK(\clk~O ), .SR(\u_sobel/n815 ), .Q(\u_sobel/hst [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hst[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hst[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hst[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hst[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hst[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hst[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hst[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/start_r~FF  (.D(\u_sobel/dims_ok ), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/n905 ), .Q(\u_sobel/start_r )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/start_r~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/start_r~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/start_r~FF .SR_POLARITY = 1'b0;
    defparam \u_sobel/start_r~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/start_r~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/start_r~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/start_r~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[0]~FF  (.D(\u_sobel/u_core/n317 [0]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/st[0]~FF  (.D(\u_sobel/u_core/st [0]), .CE(ceg_net27), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/st [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/st[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/st[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/st[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/st[0]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/u_core/st[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/st[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/st[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[0]~FF  (.D(\u_sobel/u_core/row [0]), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[0]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/u_core/row[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[0]~FF  (.D(\u_sobel/u_core/n542 [0]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[0]~FF  (.D(\u_sobel/u_core/a1 [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[0]~FF  (.D(\u_sobel/u_core/a2 [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[0]~FF  (.D(\u_sobel/u_core/rd [8]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[0]~FF  (.D(\u_sobel/u_core/b1 [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[0]~FF  (.D(\u_sobel/u_core/b2 [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[0]~FF  (.D(\u_sobel/u_core/rd [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[0]~FF  (.D(\u_sobel/u_core/c1 [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[0]~FF  (.D(\u_sobel/u_core/c2 [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[0]~FF  (.D(\u_sobel/u_core/pix [0]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[0]~FF  (.D(\u_sobel/pix [0]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_valid~FF  (.D(\u_sobel/u_core/not_equal_40/n31 ), 
           .CE(1'b1), .CLK(\clk~O ), .SR(\u_sobel/u_core/n1637 ), .Q(\u_sobel/core_valid )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_valid~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_valid~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_valid~FF .SR_POLARITY = 1'b0;
    defparam \u_sobel/core_valid~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/core_valid~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/core_valid~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/core_valid~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[1]~FF  (.D(\u_sobel/u_core/n1014 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[2]~FF  (.D(\u_sobel/u_core/n1019 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[3]~FF  (.D(\u_sobel/u_core/n1024 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[4]~FF  (.D(\u_sobel/u_core/n1029 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[5]~FF  (.D(\u_sobel/u_core/n1034 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[6]~FF  (.D(\u_sobel/u_core/n1039 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[7]~FF  (.D(\u_sobel/u_core/n1044 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[8]~FF  (.D(\u_sobel/u_core/n1049 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[8]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[9]~FF  (.D(\u_sobel/u_core/n1054 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[9]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[10]~FF  (.D(\u_sobel/u_core/n1059 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[10]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[10]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[10]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[10]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[10]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[10]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[11]~FF  (.D(\u_sobel/u_core/n1064 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[11]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[11]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[11]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[11]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[11]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[11]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[12]~FF  (.D(\u_sobel/u_core/n1069 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[12]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[12]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[12]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[12]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[12]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[12]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[13]~FF  (.D(\u_sobel/u_core/n1074 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[13]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[13]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[13]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[13]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[13]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[13]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[14]~FF  (.D(\u_sobel/u_core/n1079 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[14]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[14]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[14]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[14]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[14]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[14]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/row[15]~FF  (.D(\u_sobel/u_core/n1084 ), .CE(\u_sobel/u_core/n1543 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/row [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/row[15]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[15]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[15]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[15]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/row[15]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/row[15]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/row[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[1]~FF  (.D(\u_sobel/u_core/n542 [1]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[2]~FF  (.D(\u_sobel/u_core/n542 [2]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[3]~FF  (.D(\u_sobel/u_core/n542 [3]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[4]~FF  (.D(\u_sobel/u_core/n542 [4]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[5]~FF  (.D(\u_sobel/u_core/n542 [5]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[6]~FF  (.D(\u_sobel/u_core/n542 [6]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[7]~FF  (.D(\u_sobel/u_core/n542 [7]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[8]~FF  (.D(\u_sobel/u_core/n542 [8]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[8]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[9]~FF  (.D(\u_sobel/u_core/n542 [9]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[9]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/skip[10]~FF  (.D(\u_sobel/u_core/n542 [10]), .CE(ceg_net10), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/skip [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/skip[10]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[10]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/skip[10]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[10]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/skip[10]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/skip[10]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/skip[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[1]~FF  (.D(\u_sobel/u_core/n317 [1]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[2]~FF  (.D(\u_sobel/u_core/n317 [2]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[3]~FF  (.D(\u_sobel/u_core/n317 [3]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[4]~FF  (.D(\u_sobel/u_core/n317 [4]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[5]~FF  (.D(\u_sobel/u_core/n317 [5]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[6]~FF  (.D(\u_sobel/u_core/n317 [6]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[7]~FF  (.D(\u_sobel/u_core/n317 [7]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[8]~FF  (.D(\u_sobel/u_core/n317 [8]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[8]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/col[9]~FF  (.D(\u_sobel/u_core/n317 [9]), .CE(\u_sobel/u_core/n1144 ), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/col [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/col[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[9]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/col[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/col[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/col[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_37  (.D(\u_sobel/u_core/n97 [8]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_37 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_37 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_37 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_37 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_37 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_37 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_37 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_38  (.D(\u_sobel/u_core/n97 [7]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_38 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_38 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_38 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_38 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_38 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_38 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_38 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_35  (.D(n1241), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(n1241_q)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_35 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_35 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_35 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_35 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_35 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_35 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_35 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_36  (.D(n1253), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(n1253_q)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_36 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_36 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_36 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_36 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_36 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_36 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_36 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[1]~FF  (.D(\u_sobel/u_core/a1 [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[2]~FF  (.D(\u_sobel/u_core/a1 [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[3]~FF  (.D(\u_sobel/u_core/a1 [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[4]~FF  (.D(\u_sobel/u_core/a1 [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[5]~FF  (.D(\u_sobel/u_core/a1 [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[6]~FF  (.D(\u_sobel/u_core/a1 [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a0[7]~FF  (.D(\u_sobel/u_core/a1 [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a0 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a0[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a0[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a0[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a0[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a0[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[1]~FF  (.D(\u_sobel/u_core/a2 [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[2]~FF  (.D(\u_sobel/u_core/a2 [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[3]~FF  (.D(\u_sobel/u_core/a2 [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[4]~FF  (.D(\u_sobel/u_core/a2 [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[5]~FF  (.D(\u_sobel/u_core/a2 [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[6]~FF  (.D(\u_sobel/u_core/a2 [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a1[7]~FF  (.D(\u_sobel/u_core/a2 [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a1[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a1[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a1[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[1]~FF  (.D(\u_sobel/u_core/rd [9]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[2]~FF  (.D(\u_sobel/u_core/rd [10]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[3]~FF  (.D(\u_sobel/u_core/rd [11]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[4]~FF  (.D(\u_sobel/u_core/rd [12]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[5]~FF  (.D(\u_sobel/u_core/rd [13]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[6]~FF  (.D(\u_sobel/u_core/rd [14]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/a2[7]~FF  (.D(\u_sobel/u_core/rd [15]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/a2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/a2[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/a2[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/a2[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/a2[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/a2[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[1]~FF  (.D(\u_sobel/u_core/b1 [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[2]~FF  (.D(\u_sobel/u_core/b1 [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[3]~FF  (.D(\u_sobel/u_core/b1 [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[4]~FF  (.D(\u_sobel/u_core/b1 [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[5]~FF  (.D(\u_sobel/u_core/b1 [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[6]~FF  (.D(\u_sobel/u_core/b1 [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b0[7]~FF  (.D(\u_sobel/u_core/b1 [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b0 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b0[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b0[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b0[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b0[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b0[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[1]~FF  (.D(\u_sobel/u_core/b2 [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[2]~FF  (.D(\u_sobel/u_core/b2 [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[3]~FF  (.D(\u_sobel/u_core/b2 [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[4]~FF  (.D(\u_sobel/u_core/b2 [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[5]~FF  (.D(\u_sobel/u_core/b2 [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[6]~FF  (.D(\u_sobel/u_core/b2 [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b1[7]~FF  (.D(\u_sobel/u_core/b2 [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b1[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b1[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b1[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[1]~FF  (.D(\u_sobel/u_core/rd [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[2]~FF  (.D(\u_sobel/u_core/rd [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[3]~FF  (.D(\u_sobel/u_core/rd [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[4]~FF  (.D(\u_sobel/u_core/rd [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[5]~FF  (.D(\u_sobel/u_core/rd [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[6]~FF  (.D(\u_sobel/u_core/rd [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/b2[7]~FF  (.D(\u_sobel/u_core/rd [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/b2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/b2[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/b2[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/b2[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/b2[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/b2[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[1]~FF  (.D(\u_sobel/u_core/c1 [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[2]~FF  (.D(\u_sobel/u_core/c1 [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[3]~FF  (.D(\u_sobel/u_core/c1 [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[4]~FF  (.D(\u_sobel/u_core/c1 [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[5]~FF  (.D(\u_sobel/u_core/c1 [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[6]~FF  (.D(\u_sobel/u_core/c1 [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c0[7]~FF  (.D(\u_sobel/u_core/c1 [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c0 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c0[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c0[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c0[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c0[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c0[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[1]~FF  (.D(\u_sobel/u_core/c2 [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[2]~FF  (.D(\u_sobel/u_core/c2 [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[3]~FF  (.D(\u_sobel/u_core/c2 [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[4]~FF  (.D(\u_sobel/u_core/c2 [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[5]~FF  (.D(\u_sobel/u_core/c2 [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[6]~FF  (.D(\u_sobel/u_core/c2 [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c1[7]~FF  (.D(\u_sobel/u_core/c2 [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c1[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c1[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c1[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[1]~FF  (.D(\u_sobel/u_core/pix [1]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[2]~FF  (.D(\u_sobel/u_core/pix [2]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[3]~FF  (.D(\u_sobel/u_core/pix [3]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[4]~FF  (.D(\u_sobel/u_core/pix [4]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[5]~FF  (.D(\u_sobel/u_core/pix [5]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[6]~FF  (.D(\u_sobel/u_core/pix [6]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/c2[7]~FF  (.D(\u_sobel/u_core/pix [7]), .CE(\u_sobel/u_core/n1827 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/c2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/c2[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/c2[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/c2[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/c2[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/c2[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[1]~FF  (.D(\u_sobel/pix [1]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[2]~FF  (.D(\u_sobel/pix [2]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[3]~FF  (.D(\u_sobel/pix [3]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[4]~FF  (.D(\u_sobel/pix [4]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[5]~FF  (.D(\u_sobel/pix [5]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[6]~FF  (.D(\u_sobel/pix [6]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/pix[7]~FF  (.D(\u_sobel/pix [7]), .CE(\u_sobel/u_core/n1633 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/pix [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/pix[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/pix[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/pix[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/pix[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_core/st[1]~FF  (.D(\u_sobel/u_core/n400 [1]), .CE(ceg_net27), 
           .CLK(\clk~O ), .SR(\u_sobel/u_core/n199 ), .Q(\u_sobel/u_core/st [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/u_core/st[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/st[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/st[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_core/st[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_core/st[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_core/st[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_core/st[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/st[0]~FF  (.D(\u_sobel/u_rx/st [0]), .CE(ceg_net69), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/u_rx/st [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/st[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/st[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/st[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/st[0]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/st[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/st[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/st[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[0]~FF  (.D(\u_sobel/u_rx/sh [0]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/bi[0]~FF  (.D(\u_sobel/u_rx/n134 [0]), .CE(ceg_net53), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/bi [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/bi[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/bi[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/bi[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/bi[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/cnt[0]~FF  (.D(\u_sobel/u_rx/n119 [0]), .CE(ceg_net51), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/cnt [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/cnt[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/cnt[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_seen~FF  (.D(\u_sobel/u_rx/sy[1] ), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/u_rx/n393 ), .Q(rx_seen)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \rx_seen~FF .CLK_POLARITY = 1'b1;
    defparam \rx_seen~FF .CE_POLARITY = 1'b1;
    defparam \rx_seen~FF .SR_POLARITY = 1'b0;
    defparam \rx_seen~FF .D_POLARITY = 1'b0;
    defparam \rx_seen~FF .SR_SYNC = 1'b1;
    defparam \rx_seen~FF .SR_VALUE = 1'b0;
    defparam \rx_seen~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sy[0]~FF  (.D(uart_rx), .CE(1'b1), .CLK(\clk~O ), 
           .SR(1'b0), .Q(\u_sobel/u_rx/sy[0] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sy[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sy[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sy[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sy[0]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/sy[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sy[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sy[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[0]~FF  (.D(\u_sobel/u_rx/sh [1]), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[1]~FF  (.D(\u_sobel/u_rx/sh [1]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[2]~FF  (.D(\u_sobel/u_rx/sh [2]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[3]~FF  (.D(\u_sobel/u_rx/sh [3]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[4]~FF  (.D(\u_sobel/u_rx/sh [4]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[5]~FF  (.D(\u_sobel/u_rx/sh [5]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[6]~FF  (.D(\u_sobel/u_rx/sh [6]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rx_data[7]~FF  (.D(\u_sobel/u_rx/sh [7]), .CE(\u_sobel/u_rx/n393 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/rx_data [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/rx_data[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rx_data[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rx_data[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rx_data[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[1]~FF  (.D(\u_sobel/u_rx/sh [2]), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[2]~FF  (.D(\u_sobel/u_rx/sh [3]), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[3]~FF  (.D(\u_sobel/u_rx/sh [4]), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[4]~FF  (.D(\u_sobel/u_rx/sh [5]), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[5]~FF  (.D(\u_sobel/u_rx/sh [6]), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[6]~FF  (.D(\u_sobel/u_rx/sh [7]), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sh[7]~FF  (.D(\u_sobel/u_rx/sy[1] ), .CE(\u_sobel/u_rx/n445 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sh [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sh[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sh[7]~FF .D_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/sh[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sh[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sh[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/cnt[1]~FF  (.D(\u_sobel/u_rx/n119 [1]), .CE(ceg_net51), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/cnt [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/cnt[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/cnt[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/cnt[2]~FF  (.D(\u_sobel/u_rx/n119 [2]), .CE(ceg_net51), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/cnt [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/cnt[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/cnt[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/cnt[3]~FF  (.D(\u_sobel/u_rx/n119 [3]), .CE(ceg_net51), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/cnt [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/cnt[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/cnt[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/cnt[4]~FF  (.D(\u_sobel/u_rx/n119 [4]), .CE(ceg_net51), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/cnt [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/cnt[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/cnt[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/cnt[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/bi[1]~FF  (.D(\u_sobel/u_rx/n134 [1]), .CE(ceg_net53), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/bi [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/bi[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/bi[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/bi[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/bi[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/bi[2]~FF  (.D(\u_sobel/u_rx/n134 [2]), .CE(ceg_net53), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/bi [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/bi[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_rx/bi[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/bi[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/bi[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/bi[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/st[1]~FF  (.D(\u_sobel/u_rx/n116 [1]), .CE(ceg_net69), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/u_rx/st [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/st[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/st[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/st[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/st[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/st[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/st[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/st[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_rx/sy[1]~FF  (.D(\u_sobel/u_rx/sy[0] ), .CE(1'b1), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_rx/sy[1] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(86)
    defparam \u_sobel/u_rx/sy[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sy[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sy[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sy[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_rx/sy[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_rx/sy[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_rx/sy[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[2]~FF  (.D(\u_sobel/u_tx/n65 [2]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[1]~FF  (.D(\u_sobel/u_tx/n65 [1]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/left[0]~FF  (.D(\u_sobel/u_tx/n76 [0]), .CE(ceg_net57), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/u_tx/left [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/left[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/left[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/left[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[0]~FF  (.D(\u_sobel/u_tx/n65 [0]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[0]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/cnt[0]~FF  (.D(\u_sobel/u_tx/n81 [0]), .CE(ceg_net35), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/cnt [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[0]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_tx/cnt[0]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[0]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[0]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/cnt[0]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[3]~FF  (.D(\u_sobel/u_tx/n65 [3]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \uart_tx~FF  (.D(\u_sobel/u_tx/sh [0]), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/u_tx/n156 ), .Q(uart_tx)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \uart_tx~FF .CLK_POLARITY = 1'b1;
    defparam \uart_tx~FF .CE_POLARITY = 1'b1;
    defparam \uart_tx~FF .SR_POLARITY = 1'b1;
    defparam \uart_tx~FF .D_POLARITY = 1'b1;
    defparam \uart_tx~FF .SR_SYNC = 1'b1;
    defparam \uart_tx~FF .SR_VALUE = 1'b1;
    defparam \uart_tx~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[4]~FF  (.D(\u_sobel/u_tx/n65 [4]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[5]~FF  (.D(\u_sobel/u_tx/n65 [5]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[6]~FF  (.D(\u_sobel/u_tx/n65 [6]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[7]~FF  (.D(\u_sobel/u_tx/n65 [7]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[8]~FF  (.D(\u_sobel/u_tx/n65 [8]), .CE(\~ceg_net54 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/sh [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[8]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/sh[9]~FF  (.D(1'b1), .CE(\~ceg_net54 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(\u_sobel/u_tx/sh [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/sh[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[9]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/sh[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/sh[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/sh[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/cnt[1]~FF  (.D(\u_sobel/u_tx/n81 [1]), .CE(ceg_net35), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/cnt [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_tx/cnt[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/cnt[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/cnt[2]~FF  (.D(\u_sobel/u_tx/n81 [2]), .CE(ceg_net35), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/cnt [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_tx/cnt[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/cnt[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/cnt[3]~FF  (.D(\u_sobel/u_tx/n81 [3]), .CE(ceg_net35), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/cnt [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_tx/cnt[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/cnt[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/cnt[4]~FF  (.D(\u_sobel/u_tx/n81 [4]), .CE(ceg_net35), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_tx/cnt [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/u_tx/cnt[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/cnt[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/cnt[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/left[1]~FF  (.D(\u_sobel/u_tx/n186 ), .CE(ceg_net57), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/u_tx/left [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/left[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/left[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/left[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/left[2]~FF  (.D(\u_sobel/u_tx/n76 [2]), .CE(ceg_net57), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/u_tx/left [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/left[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/left[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/left[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/u_tx/left[3]~FF  (.D(\u_sobel/u_tx/n196 ), .CE(ceg_net57), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/u_tx/left [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(62)
    defparam \u_sobel/u_tx/left[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/u_tx/left[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/u_tx/left[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/u_tx/left[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[1]~FF  (.D(\u_sobel/n71 [1]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[2]~FF  (.D(\u_sobel/n71 [2]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[3]~FF  (.D(\u_sobel/n71 [3]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[4]~FF  (.D(\u_sobel/n71 [4]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[5]~FF  (.D(\u_sobel/n71 [5]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[6]~FF  (.D(\u_sobel/n71 [6]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[7]~FF  (.D(\u_sobel/n71 [7]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[8]~FF  (.D(\u_sobel/n71 [8]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[8]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[9]~FF  (.D(\u_sobel/n71 [9]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[9]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[10]~FF  (.D(\u_sobel/n71 [10]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[10]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[10]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[10]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[10]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[10]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[10]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[11]~FF  (.D(\u_sobel/n71 [11]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[11]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[11]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[11]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[11]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[11]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[11]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[12]~FF  (.D(\u_sobel/n71 [12]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[12]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[12]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[12]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[12]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[12]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[12]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[13]~FF  (.D(\u_sobel/n71 [13]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[13]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[13]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[13]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[13]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[13]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[13]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[14]~FF  (.D(\u_sobel/n71 [14]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[14]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[14]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[14]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[14]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[14]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[14]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[15]~FF  (.D(\u_sobel/n71 [15]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[15]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[15]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[15]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[15]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[15]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[15]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[16]~FF  (.D(\u_sobel/n71 [16]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[16]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[16]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[16]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[16]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[16]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[16]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[17]~FF  (.D(\u_sobel/n71 [17]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[17]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[17]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[17]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[17]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[17]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[17]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[18]~FF  (.D(\u_sobel/n71 [18]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[18]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[18]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[18]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[18]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[18]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[18]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[19]~FF  (.D(\u_sobel/n71 [19]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[19]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[19]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[19]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[19]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[19]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[19]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[20]~FF  (.D(\u_sobel/n71 [20]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[20]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[20]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[20]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[20]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[20]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[20]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[21]~FF  (.D(\u_sobel/n71 [21]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[21]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[21]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[21]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[21]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[21]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[21]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[22]~FF  (.D(\u_sobel/n71 [22]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[22]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[22]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[22]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[22]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[22]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[22]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/tmo[23]~FF  (.D(\u_sobel/n71 [23]), .CE(\u_sobel/n69 ), 
           .CLK(\clk~O ), .SR(\u_sobel/n818 ), .Q(\u_sobel/tmo [23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/tmo[23]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/tmo[23]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/tmo[23]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/tmo[23]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/tmo[23]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/tmo[23]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/tmo[23]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[1]~FF  (.D(\u_sobel/n293 [1]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[1]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[2]~FF  (.D(\u_sobel/n293 [2]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[2]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[3]~FF  (.D(\u_sobel/n293 [3]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[3]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[4]~FF  (.D(\u_sobel/n293 [4]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[4]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[5]~FF  (.D(\u_sobel/n293 [5]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[5]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[6]~FF  (.D(\u_sobel/n293 [6]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[6]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[7]~FF  (.D(\u_sobel/n293 [7]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[7]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[8]~FF  (.D(\u_sobel/n293 [8]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[8]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[9]~FF  (.D(\u_sobel/n293 [9]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[9]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[10]~FF  (.D(\u_sobel/n293 [10]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[10]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[10]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[10]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[10]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[10]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[10]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[11]~FF  (.D(\u_sobel/n293 [11]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[11]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[11]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[11]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[11]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[11]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[11]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[12]~FF  (.D(\u_sobel/n293 [12]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[12]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[12]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[12]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[12]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[12]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[12]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[13]~FF  (.D(\u_sobel/n293 [13]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[13]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[13]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[13]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[13]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[13]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[13]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[14]~FF  (.D(\u_sobel/n293 [14]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[14]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[14]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[14]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[14]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[14]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[14]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/flush_left[15]~FF  (.D(\u_sobel/n293 [15]), .CE(ceg_net25), 
           .CLK(\clk~O ), .SR(rst), .Q(\u_sobel/flush_left [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/flush_left[15]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[15]~FF .CE_POLARITY = 1'b0;
    defparam \u_sobel/flush_left[15]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[15]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/flush_left[15]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/flush_left[15]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/flush_left[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[1]~FF  (.D(\u_sobel/rx_data [1]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[2]~FF  (.D(\u_sobel/rx_data [2]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[3]~FF  (.D(\u_sobel/rx_data [3]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[4]~FF  (.D(\u_sobel/rx_data [4]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[5]~FF  (.D(\u_sobel/rx_data [5]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[6]~FF  (.D(\u_sobel/rx_data [6]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[7]~FF  (.D(\u_sobel/rx_data [7]), .CE(\u_sobel/n865 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[8]~FF  (.D(\u_sobel/rx_data [0]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[8]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[9]~FF  (.D(\u_sobel/rx_data [1]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[9]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[10]~FF  (.D(\u_sobel/rx_data [2]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[10]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[10]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[10]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[10]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[10]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[10]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[11]~FF  (.D(\u_sobel/rx_data [3]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[11]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[11]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[11]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[11]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[11]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[11]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[12]~FF  (.D(\u_sobel/rx_data [4]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[12]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[12]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[12]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[12]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[12]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[12]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[13]~FF  (.D(\u_sobel/rx_data [5]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[13]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[13]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[13]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[13]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[13]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[13]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[14]~FF  (.D(\u_sobel/rx_data [6]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[14]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[14]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[14]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[14]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[14]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[14]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wreg[15]~FF  (.D(\u_sobel/rx_data [7]), .CE(\u_sobel/n890 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/wreg [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/wreg[15]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wreg[15]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wreg[15]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wreg[15]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wreg[15]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wreg[15]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wreg[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[1]~FF  (.D(\u_sobel/rx_data [1]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[2]~FF  (.D(\u_sobel/rx_data [2]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[3]~FF  (.D(\u_sobel/rx_data [3]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[4]~FF  (.D(\u_sobel/rx_data [4]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[5]~FF  (.D(\u_sobel/rx_data [5]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[6]~FF  (.D(\u_sobel/rx_data [6]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[6]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[6]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[6]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[6]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[6]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[6]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[7]~FF  (.D(\u_sobel/rx_data [7]), .CE(\u_sobel/n866 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[7]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[7]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[7]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[7]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[7]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[7]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[8]~FF  (.D(\u_sobel/rx_data [0]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[8]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[8]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[8]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[8]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[8]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[8]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[9]~FF  (.D(\u_sobel/rx_data [1]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[9]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[9]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[9]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[9]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[9]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[9]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[10]~FF  (.D(\u_sobel/rx_data [2]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[10]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[10]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[10]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[10]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[10]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[10]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[11]~FF  (.D(\u_sobel/rx_data [3]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[11]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[11]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[11]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[11]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[11]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[11]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[12]~FF  (.D(\u_sobel/rx_data [4]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[12]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[12]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[12]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[12]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[12]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[12]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[13]~FF  (.D(\u_sobel/rx_data [5]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[13]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[13]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[13]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[13]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[13]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[13]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[14]~FF  (.D(\u_sobel/rx_data [6]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[14]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[14]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[14]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[14]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[14]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[14]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hreg[15]~FF  (.D(\u_sobel/rx_data [7]), .CE(\u_sobel/n905 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/hreg [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hreg[15]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hreg[15]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hreg[15]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hreg[15]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hreg[15]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hreg[15]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hreg[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/cnt[1]~FF  (.D(\u_sobel/n597 [1]), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/cnt [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/cnt[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/cnt[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/cnt[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/cnt[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/cnt[2]~FF  (.D(\u_sobel/n597 [2]), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/cnt [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/cnt[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/cnt[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/cnt[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/cnt[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/cnt[3]~FF  (.D(\u_sobel/n597 [3]), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/cnt [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/cnt[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/cnt[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/cnt[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/cnt[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/cnt[4]~FF  (.D(\u_sobel/n597 [4]), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/cnt [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/cnt[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/cnt[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/cnt[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/cnt[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/cnt[5]~FF  (.D(\u_sobel/n597 [5]), .CE(1'b1), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/cnt [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/cnt[5]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/cnt[5]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/cnt[5]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/cnt[5]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/cnt[5]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/cnt[5]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/cnt[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wp[1]~FF  (.D(\u_sobel/n933 ), .CE(\u_sobel/core_valid ), 
           .CLK(\clk~O ), .SR(\u_sobel/n560 ), .Q(\u_sobel/wp [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/wp[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wp[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wp[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wp[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wp[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wp[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wp[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wp[2]~FF  (.D(\u_sobel/n940 ), .CE(\u_sobel/core_valid ), 
           .CLK(\clk~O ), .SR(\u_sobel/n560 ), .Q(\u_sobel/wp [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/wp[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wp[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wp[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wp[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wp[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wp[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wp[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wp[3]~FF  (.D(\u_sobel/n945 ), .CE(\u_sobel/core_valid ), 
           .CLK(\clk~O ), .SR(\u_sobel/n560 ), .Q(\u_sobel/wp [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/wp[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wp[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wp[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wp[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wp[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wp[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wp[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/wp[4]~FF  (.D(\u_sobel/n950 ), .CE(\u_sobel/core_valid ), 
           .CLK(\clk~O ), .SR(\u_sobel/n560 ), .Q(\u_sobel/wp [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/wp[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/wp[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/wp[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/wp[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/wp[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/wp[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/wp[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rp[1]~FF  (.D(\u_sobel/n913 ), .CE(\u_sobel/pop ), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/rp [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/rp[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rp[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rp[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rp[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rp[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rp[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rp[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rp[2]~FF  (.D(\u_sobel/n920 ), .CE(\u_sobel/pop ), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/rp [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/rp[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rp[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rp[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rp[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rp[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rp[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rp[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rp[3]~FF  (.D(\u_sobel/n925 ), .CE(\u_sobel/pop ), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/rp [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/rp[3]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rp[3]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rp[3]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rp[3]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rp[3]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rp[3]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rp[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/rp[4]~FF  (.D(\u_sobel/n930 ), .CE(\u_sobel/pop ), .CLK(\clk~O ), 
           .SR(\u_sobel/n560 ), .Q(\u_sobel/rp [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(186)
    defparam \u_sobel/rp[4]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/rp[4]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/rp[4]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/rp[4]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/rp[4]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/rp[4]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/rp[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hst[1]~FF  (.D(\u_sobel/select_57/Select_1/n8 ), .CE(\u_sobel/hdr_step ), 
           .CLK(\clk~O ), .SR(\u_sobel/n815 ), .Q(\u_sobel/hst [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hst[1]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hst[1]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hst[1]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hst[1]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hst[1]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hst[1]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hst[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/hst[2]~FF  (.D(\~u_sobel/equal_55/n5 ), .CE(\u_sobel/hdr_step ), 
           .CLK(\clk~O ), .SR(\u_sobel/n815 ), .Q(\u_sobel/hst [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(163)
    defparam \u_sobel/hst[2]~FF .CLK_POLARITY = 1'b1;
    defparam \u_sobel/hst[2]~FF .CE_POLARITY = 1'b1;
    defparam \u_sobel/hst[2]~FF .SR_POLARITY = 1'b1;
    defparam \u_sobel/hst[2]~FF .D_POLARITY = 1'b1;
    defparam \u_sobel/hst[2]~FF .SR_SYNC = 1'b1;
    defparam \u_sobel/hst[2]~FF .SR_VALUE = 1'b0;
    defparam \u_sobel/hst[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[1]~FF  (.D(n42_2[1]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[1]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[1]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[1]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[1]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[2]~FF  (.D(n42_3[2]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[2]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[2]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[2]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[2]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[3]~FF  (.D(n42_4[3]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[3]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[3]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[3]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[3]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[4]~FF  (.D(n42_5[4]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[4]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[4]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[4]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[4]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[5]~FF  (.D(n42_6[5]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[5]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[5]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[5]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[5]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[5]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[5]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[6]~FF  (.D(n42_7[6]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[6]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[6]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[6]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[6]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[6]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[6]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[7]~FF  (.D(n42_8[7]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[7]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[7]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[7]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[7]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[7]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[7]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[8]~FF  (.D(n42_9[8]), .CE(led1), .CLK(\clk~O ), .SR(frame_done), 
           .Q(done_cnt[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[8]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[8]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[8]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[8]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[8]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[8]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[9]~FF  (.D(n42_10[9]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[9]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[9]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[9]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[9]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[9]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[9]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[10]~FF  (.D(n42_11[10]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[10]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[10]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[10]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[10]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[10]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[10]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[11]~FF  (.D(n42_12[11]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[11]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[11]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[11]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[11]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[11]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[11]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[12]~FF  (.D(n42_13[12]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[12]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[12]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[12]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[12]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[12]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[12]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[13]~FF  (.D(n42_14[13]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[13]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[13]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[13]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[13]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[13]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[13]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[14]~FF  (.D(n42_15[14]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[14]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[14]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[14]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[14]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[14]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[14]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[15]~FF  (.D(n42_16[15]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[15]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[15]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[15]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[15]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[15]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[15]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[16]~FF  (.D(n42_17[16]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[16]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[16]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[16]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[16]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[16]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[16]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[17]~FF  (.D(n42_18[17]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[17]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[17]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[17]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[17]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[17]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[17]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[18]~FF  (.D(n42_19[18]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[18]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[18]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[18]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[18]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[18]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[18]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[19]~FF  (.D(n42_20[19]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[19]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[19]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[19]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[19]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[19]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[19]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[20]~FF  (.D(n42_21[20]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[20]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[20]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[20]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[20]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[20]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[20]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[21]~FF  (.D(n42_22[21]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[21]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[21]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[21]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[21]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[21]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[21]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \done_cnt[22]~FF  (.D(n42_23[22]), .CE(led1), .CLK(\clk~O ), 
           .SR(frame_done), .Q(done_cnt[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \done_cnt[22]~FF .CLK_POLARITY = 1'b1;
    defparam \done_cnt[22]~FF .CE_POLARITY = 1'b0;
    defparam \done_cnt[22]~FF .SR_POLARITY = 1'b1;
    defparam \done_cnt[22]~FF .D_POLARITY = 1'b1;
    defparam \done_cnt[22]~FF .SR_SYNC = 1'b1;
    defparam \done_cnt[22]~FF .SR_VALUE = 1'b1;
    defparam \done_cnt[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[1]~FF  (.D(n115[1]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[1]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[1]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[1]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[1]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[2]~FF  (.D(n115[2]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[2]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[2]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[2]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[2]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[3]~FF  (.D(n115[3]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[3]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[3]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[3]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[3]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[4]~FF  (.D(n115[4]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[4]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[4]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[4]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[4]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[5]~FF  (.D(n115[5]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[5]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[5]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[5]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[5]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[5]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[5]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[6]~FF  (.D(n115[6]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[6]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[6]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[6]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[6]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[6]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[6]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[7]~FF  (.D(n115[7]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[7]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[7]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[7]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[7]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[7]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[7]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[8]~FF  (.D(n115[8]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[8]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[8]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[8]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[8]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[8]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[8]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[9]~FF  (.D(n115[9]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[9]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[9]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[9]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[9]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[9]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[9]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[10]~FF  (.D(n115[10]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[10]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[10]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[10]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[10]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[10]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[10]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[11]~FF  (.D(n115[11]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[11]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[11]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[11]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[11]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[11]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[11]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[12]~FF  (.D(n115[12]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[12]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[12]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[12]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[12]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[12]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[12]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[13]~FF  (.D(n115[13]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[13]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[13]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[13]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[13]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[13]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[13]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[14]~FF  (.D(n115[14]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[14]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[14]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[14]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[14]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[14]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[14]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[15]~FF  (.D(n115[15]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[15]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[15]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[15]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[15]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[15]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[15]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[16]~FF  (.D(n115[16]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[16]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[16]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[16]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[16]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[16]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[16]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[17]~FF  (.D(n115[17]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[17]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[17]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[17]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[17]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[17]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[17]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[18]~FF  (.D(n115[18]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[18]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[18]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[18]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[18]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[18]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[18]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[19]~FF  (.D(n115[19]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[19]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[19]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[19]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[19]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[19]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[19]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[20]~FF  (.D(n115[20]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[20]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[20]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[20]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[20]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[20]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[20]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[21]~FF  (.D(n115[21]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[21]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[21]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[21]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[21]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[21]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[21]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \rx_cnt[22]~FF  (.D(n115[22]), .CE(led2), .CLK(\clk~O ), .SR(rx_seen), 
           .Q(rx_cnt[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(45)
    defparam \rx_cnt[22]~FF .CLK_POLARITY = 1'b1;
    defparam \rx_cnt[22]~FF .CE_POLARITY = 1'b0;
    defparam \rx_cnt[22]~FF .SR_POLARITY = 1'b1;
    defparam \rx_cnt[22]~FF .D_POLARITY = 1'b1;
    defparam \rx_cnt[22]~FF .SR_SYNC = 1'b1;
    defparam \rx_cnt[22]~FF .SR_VALUE = 1'b1;
    defparam \rx_cnt[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[1]~FF  (.D(n10_2[1]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[1]~FF .CLK_POLARITY = 1'b1;
    defparam \por[1]~FF .CE_POLARITY = 1'b1;
    defparam \por[1]~FF .SR_POLARITY = 1'b1;
    defparam \por[1]~FF .D_POLARITY = 1'b1;
    defparam \por[1]~FF .SR_SYNC = 1'b1;
    defparam \por[1]~FF .SR_VALUE = 1'b0;
    defparam \por[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[2]~FF  (.D(n10_3[2]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[2]~FF .CLK_POLARITY = 1'b1;
    defparam \por[2]~FF .CE_POLARITY = 1'b1;
    defparam \por[2]~FF .SR_POLARITY = 1'b1;
    defparam \por[2]~FF .D_POLARITY = 1'b1;
    defparam \por[2]~FF .SR_SYNC = 1'b1;
    defparam \por[2]~FF .SR_VALUE = 1'b0;
    defparam \por[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[3]~FF  (.D(n10_4[3]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[3]~FF .CLK_POLARITY = 1'b1;
    defparam \por[3]~FF .CE_POLARITY = 1'b1;
    defparam \por[3]~FF .SR_POLARITY = 1'b1;
    defparam \por[3]~FF .D_POLARITY = 1'b1;
    defparam \por[3]~FF .SR_SYNC = 1'b1;
    defparam \por[3]~FF .SR_VALUE = 1'b0;
    defparam \por[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[4]~FF  (.D(n10_5[4]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[4]~FF .CLK_POLARITY = 1'b1;
    defparam \por[4]~FF .CE_POLARITY = 1'b1;
    defparam \por[4]~FF .SR_POLARITY = 1'b1;
    defparam \por[4]~FF .D_POLARITY = 1'b1;
    defparam \por[4]~FF .SR_SYNC = 1'b1;
    defparam \por[4]~FF .SR_VALUE = 1'b0;
    defparam \por[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[5]~FF  (.D(n10_6[5]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[5]~FF .CLK_POLARITY = 1'b1;
    defparam \por[5]~FF .CE_POLARITY = 1'b1;
    defparam \por[5]~FF .SR_POLARITY = 1'b1;
    defparam \por[5]~FF .D_POLARITY = 1'b1;
    defparam \por[5]~FF .SR_SYNC = 1'b1;
    defparam \por[5]~FF .SR_VALUE = 1'b0;
    defparam \por[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[6]~FF  (.D(n10_7[6]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[6]~FF .CLK_POLARITY = 1'b1;
    defparam \por[6]~FF .CE_POLARITY = 1'b1;
    defparam \por[6]~FF .SR_POLARITY = 1'b1;
    defparam \por[6]~FF .D_POLARITY = 1'b1;
    defparam \por[6]~FF .SR_SYNC = 1'b1;
    defparam \por[6]~FF .SR_VALUE = 1'b0;
    defparam \por[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \por[7]~FF  (.D(n10_8[7]), .CE(\not_equal_3/n15 ), .CLK(\clk~O ), 
           .SR(1'b0), .Q(por[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \por[7]~FF .CLK_POLARITY = 1'b1;
    defparam \por[7]~FF .CE_POLARITY = 1'b1;
    defparam \por[7]~FF .SR_POLARITY = 1'b1;
    defparam \por[7]~FF .D_POLARITY = 1'b1;
    defparam \por[7]~FF .SR_SYNC = 1'b1;
    defparam \por[7]~FF .SR_VALUE = 1'b0;
    defparam \por[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \btn_sync[1]~FF  (.D(\btn_sync[0] ), .CE(1'b1), .CLK(\clk~O ), 
           .SR(1'b0), .Q(\btn_sync[1] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(37)
    defparam \btn_sync[1]~FF .CLK_POLARITY = 1'b1;
    defparam \btn_sync[1]~FF .CE_POLARITY = 1'b1;
    defparam \btn_sync[1]~FF .SR_POLARITY = 1'b1;
    defparam \btn_sync[1]~FF .D_POLARITY = 1'b1;
    defparam \btn_sync[1]~FF .SR_SYNC = 1'b1;
    defparam \btn_sync[1]~FF .SR_VALUE = 1'b0;
    defparam \btn_sync[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_ADD \add_31/i1  (.I0(por[1]), .I1(por[0]), .CI(1'b0), .O(n10_2[1]), 
            .CO(\add_31/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(35)
    defparam \add_31/i1 .I0_POLARITY = 1'b1;
    defparam \add_31/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i1  (.I0(\u_sobel/wreg [1]), .I1(\u_sobel/wreg [0]), 
            .CI(1'b0), .CO(\u_sobel/add_184/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i1  (.I0(\u_sobel/u_core/a0 [0]), .I1(\u_sobel/u_core/a2 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/pt [0]), .CO(\u_sobel/u_core/add_14/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i1  (.I0(\u_sobel/tmo [1]), .I1(\u_sobel/tmo [0]), 
            .CI(1'b0), .O(\u_sobel/n71 [1]), .CO(\u_sobel/add_182/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i1  (.I0(\u_sobel/u_core/a0 [1]), .I1(\u_sobel/u_core/a1 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/n75 [0]), .CO(\u_sobel/u_core/add_13/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i1  (.I0(\u_sobel/u_core/c0 [0]), .I1(\u_sobel/u_core/c2 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/pb [0]), .CO(\u_sobel/u_core/add_12/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i1  (.I0(\u_sobel/u_core/c0 [1]), .I1(\u_sobel/u_core/c1 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/n53 [0]), .CO(\u_sobel/u_core/add_11/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i1  (.I0(\u_sobel/u_core/a0 [0]), .I1(\u_sobel/u_core/c0 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/pl [0]), .CO(\u_sobel/u_core/add_10/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i1  (.I0(\u_sobel/u_core/a0 [1]), .I1(\u_sobel/u_core/b0 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/n31 [0]), .CO(\u_sobel/u_core/add_9/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i1  (.I0(\u_sobel/u_core/a2 [0]), .I1(\u_sobel/u_core/c2 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/pr [0]), .CO(\u_sobel/u_core/add_8/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i1  (.I0(\u_sobel/u_core/a2 [1]), .I1(\u_sobel/u_core/b2 [0]), 
            .CI(1'b0), .O(\u_sobel/u_core/n9 [0]), .CO(\u_sobel/u_core/add_7/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_106/i1  (.I0(\u_sobel/cnt [0]), .I1(\u_sobel/core_valid ), 
            .CI(1'b0), .O(\u_sobel/n590 [0]), .CO(\u_sobel/add_106/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/add_106/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_106/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i1  (.I0(done_cnt[0]), .I1(1'b0), .CI(n1273), 
            .CO(\sub_14/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i1  (.I0(\u_sobel/u_core/ay_q [0]), .I1(\u_sobel/u_core/ay_q [0]), 
            .CI(1'b0), .CO(\u_sobel/u_core/add_23/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i1  (.I0(\u_sobel/n1141 ), .I1(\u_sobel/n1136 ), 
            .CI(1'b0), .CO(\u_sobel/u_core/add_248/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i1  (.I0(\u_sobel/flush_left [0]), .I1(1'b0), 
            .CI(n1274), .CO(\u_sobel/sub_72/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i1  (.I0(\u_sobel/u_core/skip [0]), 
            .I1(1'b0), .CI(n1275), .CO(\u_sobel/u_core/sub_41/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i1  (.I0(\u_sobel/u_core/pr [0]), 
            .I1(\u_sobel/u_core/pl [0]), .CI(n1276), .CO(\u_sobel/u_core/sub_16/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i1  (.I0(\u_sobel/u_core/pl [0]), 
            .I1(\u_sobel/u_core/pr [0]), .CI(n1277), .CO(\u_sobel/u_core/sub_17/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i1  (.I0(\u_sobel/u_core/pb [0]), 
            .I1(\u_sobel/u_core/pt [0]), .CI(n1278), .CO(\u_sobel/u_core/sub_20/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i1  (.I0(\u_sobel/u_core/pt [0]), 
            .I1(\u_sobel/u_core/pb [0]), .CI(n1279), .CO(\u_sobel/u_core/sub_21/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \sub_18/add_2/i23  (.I0(rx_cnt[22]), .I1(1'b1), .CI(\sub_18/add_2/n44 ), 
            .O(n115[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i23 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i23 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i22  (.I0(rx_cnt[21]), .I1(1'b1), .CI(\sub_18/add_2/n42 ), 
            .O(n115[21]), .CO(\sub_18/add_2/n44 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i22 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i22 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i21  (.I0(rx_cnt[20]), .I1(1'b1), .CI(\sub_18/add_2/n40 ), 
            .O(n115[20]), .CO(\sub_18/add_2/n42 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i21 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i21 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i20  (.I0(rx_cnt[19]), .I1(1'b1), .CI(\sub_18/add_2/n38 ), 
            .O(n115[19]), .CO(\sub_18/add_2/n40 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i20 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i20 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i19  (.I0(rx_cnt[18]), .I1(1'b1), .CI(\sub_18/add_2/n36 ), 
            .O(n115[18]), .CO(\sub_18/add_2/n38 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i19 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i19 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i18  (.I0(rx_cnt[17]), .I1(1'b1), .CI(\sub_18/add_2/n34 ), 
            .O(n115[17]), .CO(\sub_18/add_2/n36 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i18 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i18 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i17  (.I0(rx_cnt[16]), .I1(1'b1), .CI(\sub_18/add_2/n32 ), 
            .O(n115[16]), .CO(\sub_18/add_2/n34 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i17 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i17 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i16  (.I0(rx_cnt[15]), .I1(1'b1), .CI(\sub_18/add_2/n30 ), 
            .O(n115[15]), .CO(\sub_18/add_2/n32 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i16 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i16 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i15  (.I0(rx_cnt[14]), .I1(1'b1), .CI(\sub_18/add_2/n28 ), 
            .O(n115[14]), .CO(\sub_18/add_2/n30 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i15 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i15 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i14  (.I0(rx_cnt[13]), .I1(1'b1), .CI(\sub_18/add_2/n26 ), 
            .O(n115[13]), .CO(\sub_18/add_2/n28 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i14 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i14 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i13  (.I0(rx_cnt[12]), .I1(1'b1), .CI(\sub_18/add_2/n24 ), 
            .O(n115[12]), .CO(\sub_18/add_2/n26 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i13 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i13 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i12  (.I0(rx_cnt[11]), .I1(1'b1), .CI(\sub_18/add_2/n22 ), 
            .O(n115[11]), .CO(\sub_18/add_2/n24 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i12 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i12 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i11  (.I0(rx_cnt[10]), .I1(1'b1), .CI(\sub_18/add_2/n20 ), 
            .O(n115[10]), .CO(\sub_18/add_2/n22 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i11 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i10  (.I0(rx_cnt[9]), .I1(1'b1), .CI(\sub_18/add_2/n18 ), 
            .O(n115[9]), .CO(\sub_18/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i9  (.I0(rx_cnt[8]), .I1(1'b1), .CI(\sub_18/add_2/n16 ), 
            .O(n115[8]), .CO(\sub_18/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i8  (.I0(rx_cnt[7]), .I1(1'b1), .CI(\sub_18/add_2/n14 ), 
            .O(n115[7]), .CO(\sub_18/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i7  (.I0(rx_cnt[6]), .I1(1'b1), .CI(\sub_18/add_2/n12 ), 
            .O(n115[6]), .CO(\sub_18/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i6  (.I0(rx_cnt[5]), .I1(1'b1), .CI(\sub_18/add_2/n10 ), 
            .O(n115[5]), .CO(\sub_18/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i5  (.I0(rx_cnt[4]), .I1(1'b1), .CI(\sub_18/add_2/n8 ), 
            .O(n115[4]), .CO(\sub_18/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i4  (.I0(rx_cnt[3]), .I1(1'b1), .CI(\sub_18/add_2/n6 ), 
            .O(n115[3]), .CO(\sub_18/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i3  (.I0(rx_cnt[2]), .I1(1'b1), .CI(\sub_18/add_2/n4 ), 
            .O(n115[2]), .CO(\sub_18/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i2  (.I0(rx_cnt[1]), .I1(1'b1), .CI(\sub_18/add_2/n2 ), 
            .O(n115[1]), .CO(\sub_18/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i23  (.I0(done_cnt[22]), .I1(1'b1), .CI(\sub_14/add_2/n44 ), 
            .O(n42_23[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i23 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i23 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i22  (.I0(done_cnt[21]), .I1(1'b1), .CI(\sub_14/add_2/n42 ), 
            .O(n42_22[21]), .CO(\sub_14/add_2/n44 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i22 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i22 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i21  (.I0(done_cnt[20]), .I1(1'b1), .CI(\sub_14/add_2/n40 ), 
            .O(n42_21[20]), .CO(\sub_14/add_2/n42 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i21 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i21 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i20  (.I0(done_cnt[19]), .I1(1'b1), .CI(\sub_14/add_2/n38 ), 
            .O(n42_20[19]), .CO(\sub_14/add_2/n40 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i20 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i20 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i19  (.I0(done_cnt[18]), .I1(1'b1), .CI(\sub_14/add_2/n36 ), 
            .O(n42_19[18]), .CO(\sub_14/add_2/n38 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i19 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i19 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i18  (.I0(done_cnt[17]), .I1(1'b1), .CI(\sub_14/add_2/n34 ), 
            .O(n42_18[17]), .CO(\sub_14/add_2/n36 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i18 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i18 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i17  (.I0(done_cnt[16]), .I1(1'b1), .CI(\sub_14/add_2/n32 ), 
            .O(n42_17[16]), .CO(\sub_14/add_2/n34 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i17 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i17 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i16  (.I0(done_cnt[15]), .I1(1'b1), .CI(\sub_14/add_2/n30 ), 
            .O(n42_16[15]), .CO(\sub_14/add_2/n32 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i16 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i16 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i15  (.I0(done_cnt[14]), .I1(1'b1), .CI(\sub_14/add_2/n28 ), 
            .O(n42_15[14]), .CO(\sub_14/add_2/n30 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i15 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i15 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i14  (.I0(done_cnt[13]), .I1(1'b1), .CI(\sub_14/add_2/n26 ), 
            .O(n42_14[13]), .CO(\sub_14/add_2/n28 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i14 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i14 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i13  (.I0(done_cnt[12]), .I1(1'b1), .CI(\sub_14/add_2/n24 ), 
            .O(n42_13[12]), .CO(\sub_14/add_2/n26 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i13 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i13 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i12  (.I0(done_cnt[11]), .I1(1'b1), .CI(\sub_14/add_2/n22 ), 
            .O(n42_12[11]), .CO(\sub_14/add_2/n24 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i12 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i12 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i11  (.I0(done_cnt[10]), .I1(1'b1), .CI(\sub_14/add_2/n20 ), 
            .O(n42_11[10]), .CO(\sub_14/add_2/n22 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i11 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i10  (.I0(done_cnt[9]), .I1(1'b1), .CI(\sub_14/add_2/n18 ), 
            .O(n42_10[9]), .CO(\sub_14/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i9  (.I0(done_cnt[8]), .I1(1'b1), .CI(\sub_14/add_2/n16 ), 
            .O(n42_9[8]), .CO(\sub_14/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i8  (.I0(done_cnt[7]), .I1(1'b1), .CI(\sub_14/add_2/n14 ), 
            .O(n42_8[7]), .CO(\sub_14/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i7  (.I0(done_cnt[6]), .I1(1'b1), .CI(\sub_14/add_2/n12 ), 
            .O(n42_7[6]), .CO(\sub_14/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i6  (.I0(done_cnt[5]), .I1(1'b1), .CI(\sub_14/add_2/n10 ), 
            .O(n42_6[5]), .CO(\sub_14/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i5  (.I0(done_cnt[4]), .I1(1'b1), .CI(\sub_14/add_2/n8 ), 
            .O(n42_5[4]), .CO(\sub_14/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i4  (.I0(done_cnt[3]), .I1(1'b1), .CI(\sub_14/add_2/n6 ), 
            .O(n42_4[3]), .CO(\sub_14/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i3  (.I0(done_cnt[2]), .I1(1'b1), .CI(\sub_14/add_2/n4 ), 
            .O(n42_3[2]), .CO(\sub_14/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_107/add_2/i6  (.I0(\u_sobel/n590 [5]), .I1(1'b1), 
            .CI(\u_sobel/sub_107/add_2/n10 ), .O(\u_sobel/n597 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/sub_107/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_107/add_2/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_107/add_2/i5  (.I0(\u_sobel/n590 [4]), .I1(1'b1), 
            .CI(\u_sobel/sub_107/add_2/n8 ), .O(\u_sobel/n597 [4]), .CO(\u_sobel/sub_107/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/sub_107/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_107/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_107/add_2/i4  (.I0(\u_sobel/n590 [3]), .I1(1'b1), 
            .CI(\u_sobel/sub_107/add_2/n6 ), .O(\u_sobel/n597 [3]), .CO(\u_sobel/sub_107/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/sub_107/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_107/add_2/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_107/add_2/i3  (.I0(\u_sobel/n590 [2]), .I1(1'b1), 
            .CI(\u_sobel/sub_107/add_2/n4 ), .O(\u_sobel/n597 [2]), .CO(\u_sobel/sub_107/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/sub_107/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_107/add_2/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_107/add_2/i2  (.I0(\u_sobel/n590 [1]), .I1(1'b1), 
            .CI(\u_sobel/sub_107/add_2/n2 ), .O(\u_sobel/n597 [1]), .CO(\u_sobel/sub_107/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/sub_107/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_107/add_2/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i16  (.I0(\u_sobel/flush_left [15]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n30 ), .O(\u_sobel/n276 [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i16 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i16 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i15  (.I0(\u_sobel/flush_left [14]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n28 ), .O(\u_sobel/n276 [14]), .CO(\u_sobel/sub_72/add_2/n30 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i15 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i15 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i14  (.I0(\u_sobel/flush_left [13]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n26 ), .O(\u_sobel/n276 [13]), .CO(\u_sobel/sub_72/add_2/n28 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i14 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i14 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i13  (.I0(\u_sobel/flush_left [12]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n24 ), .O(\u_sobel/n276 [12]), .CO(\u_sobel/sub_72/add_2/n26 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i13 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i13 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i12  (.I0(\u_sobel/flush_left [11]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n22 ), .O(\u_sobel/n276 [11]), .CO(\u_sobel/sub_72/add_2/n24 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i12 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i12 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i11  (.I0(\u_sobel/flush_left [10]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n20 ), .O(\u_sobel/n276 [10]), .CO(\u_sobel/sub_72/add_2/n22 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i11 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i10  (.I0(\u_sobel/flush_left [9]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n18 ), .O(\u_sobel/n276 [9]), .CO(\u_sobel/sub_72/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i9  (.I0(\u_sobel/flush_left [8]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n16 ), .O(\u_sobel/n276 [8]), .CO(\u_sobel/sub_72/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i8  (.I0(\u_sobel/flush_left [7]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n14 ), .O(\u_sobel/n276 [7]), .CO(\u_sobel/sub_72/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i7  (.I0(\u_sobel/flush_left [6]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n12 ), .O(\u_sobel/n276 [6]), .CO(\u_sobel/sub_72/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i6  (.I0(\u_sobel/flush_left [5]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n10 ), .O(\u_sobel/n276 [5]), .CO(\u_sobel/sub_72/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i5  (.I0(\u_sobel/flush_left [4]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n8 ), .O(\u_sobel/n276 [4]), .CO(\u_sobel/sub_72/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i4  (.I0(\u_sobel/flush_left [3]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n6 ), .O(\u_sobel/n276 [3]), .CO(\u_sobel/sub_72/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i3  (.I0(\u_sobel/flush_left [2]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n4 ), .O(\u_sobel/n276 [2]), .CO(\u_sobel/sub_72/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i10  (.I0(\u_sobel/u_core/pt [9]), 
            .I1(\u_sobel/u_core/pb [9]), .CI(\u_sobel/u_core/sub_21/add_2/n18 ), 
            .O(\u_sobel/u_core/n146 [9]), .CO(n1280)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i10 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i9  (.I0(\u_sobel/u_core/pt [8]), 
            .I1(\u_sobel/u_core/pb [8]), .CI(\u_sobel/u_core/sub_21/add_2/n16 ), 
            .O(\u_sobel/u_core/n146 [8]), .CO(\u_sobel/u_core/sub_21/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i9 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i8  (.I0(\u_sobel/u_core/pt [7]), 
            .I1(\u_sobel/u_core/pb [7]), .CI(\u_sobel/u_core/sub_21/add_2/n14 ), 
            .O(\u_sobel/u_core/n146 [7]), .CO(\u_sobel/u_core/sub_21/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i7  (.I0(\u_sobel/u_core/pt [6]), 
            .I1(\u_sobel/u_core/pb [6]), .CI(\u_sobel/u_core/sub_21/add_2/n12 ), 
            .O(\u_sobel/u_core/n146 [6]), .CO(\u_sobel/u_core/sub_21/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i6  (.I0(\u_sobel/u_core/pt [5]), 
            .I1(\u_sobel/u_core/pb [5]), .CI(\u_sobel/u_core/sub_21/add_2/n10 ), 
            .O(\u_sobel/u_core/n146 [5]), .CO(\u_sobel/u_core/sub_21/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i5  (.I0(\u_sobel/u_core/pt [4]), 
            .I1(\u_sobel/u_core/pb [4]), .CI(\u_sobel/u_core/sub_21/add_2/n8 ), 
            .O(\u_sobel/u_core/n146 [4]), .CO(\u_sobel/u_core/sub_21/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i4  (.I0(\u_sobel/u_core/pt [3]), 
            .I1(\u_sobel/u_core/pb [3]), .CI(\u_sobel/u_core/sub_21/add_2/n6 ), 
            .O(\u_sobel/u_core/n146 [3]), .CO(\u_sobel/u_core/sub_21/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i3  (.I0(\u_sobel/u_core/pt [2]), 
            .I1(\u_sobel/u_core/pb [2]), .CI(\u_sobel/u_core/sub_21/add_2/n4 ), 
            .O(\u_sobel/u_core/n146 [2]), .CO(\u_sobel/u_core/sub_21/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i2  (.I0(\u_sobel/u_core/pt [1]), 
            .I1(\u_sobel/u_core/pb [1]), .CI(\u_sobel/u_core/sub_21/add_2/n2 ), 
            .O(\u_sobel/u_core/n146 [1]), .CO(\u_sobel/u_core/sub_21/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i10  (.I0(\u_sobel/u_core/pb [9]), 
            .I1(\u_sobel/u_core/pt [9]), .CI(\u_sobel/u_core/sub_20/add_2/n18 ), 
            .O(\u_sobel/u_core/n134 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i10 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i9  (.I0(\u_sobel/u_core/pb [8]), 
            .I1(\u_sobel/u_core/pt [8]), .CI(\u_sobel/u_core/sub_20/add_2/n16 ), 
            .O(\u_sobel/u_core/n134 [8]), .CO(\u_sobel/u_core/sub_20/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i9 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i8  (.I0(\u_sobel/u_core/pb [7]), 
            .I1(\u_sobel/u_core/pt [7]), .CI(\u_sobel/u_core/sub_20/add_2/n14 ), 
            .O(\u_sobel/u_core/n134 [7]), .CO(\u_sobel/u_core/sub_20/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i7  (.I0(\u_sobel/u_core/pb [6]), 
            .I1(\u_sobel/u_core/pt [6]), .CI(\u_sobel/u_core/sub_20/add_2/n12 ), 
            .O(\u_sobel/u_core/n134 [6]), .CO(\u_sobel/u_core/sub_20/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i6  (.I0(\u_sobel/u_core/pb [5]), 
            .I1(\u_sobel/u_core/pt [5]), .CI(\u_sobel/u_core/sub_20/add_2/n10 ), 
            .O(\u_sobel/u_core/n134 [5]), .CO(\u_sobel/u_core/sub_20/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i5  (.I0(\u_sobel/u_core/pb [4]), 
            .I1(\u_sobel/u_core/pt [4]), .CI(\u_sobel/u_core/sub_20/add_2/n8 ), 
            .O(\u_sobel/u_core/n134 [4]), .CO(\u_sobel/u_core/sub_20/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i4  (.I0(\u_sobel/u_core/pb [3]), 
            .I1(\u_sobel/u_core/pt [3]), .CI(\u_sobel/u_core/sub_20/add_2/n6 ), 
            .O(\u_sobel/u_core/n134 [3]), .CO(\u_sobel/u_core/sub_20/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i3  (.I0(\u_sobel/u_core/pb [2]), 
            .I1(\u_sobel/u_core/pt [2]), .CI(\u_sobel/u_core/sub_20/add_2/n4 ), 
            .O(\u_sobel/u_core/n134 [2]), .CO(\u_sobel/u_core/sub_20/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i2  (.I0(\u_sobel/u_core/pb [1]), 
            .I1(\u_sobel/u_core/pt [1]), .CI(\u_sobel/u_core/sub_20/add_2/n2 ), 
            .O(\u_sobel/u_core/n134 [1]), .CO(\u_sobel/u_core/sub_20/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i10  (.I0(\u_sobel/u_core/pl [9]), 
            .I1(\u_sobel/u_core/pr [9]), .CI(\u_sobel/u_core/sub_17/add_2/n18 ), 
            .O(\u_sobel/u_core/n109 [9]), .CO(n1281)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i10 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i9  (.I0(\u_sobel/u_core/pl [8]), 
            .I1(\u_sobel/u_core/pr [8]), .CI(\u_sobel/u_core/sub_17/add_2/n16 ), 
            .O(\u_sobel/u_core/n109 [8]), .CO(\u_sobel/u_core/sub_17/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i9 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i8  (.I0(\u_sobel/u_core/pl [7]), 
            .I1(\u_sobel/u_core/pr [7]), .CI(\u_sobel/u_core/sub_17/add_2/n14 ), 
            .O(\u_sobel/u_core/n109 [7]), .CO(\u_sobel/u_core/sub_17/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i7  (.I0(\u_sobel/u_core/pl [6]), 
            .I1(\u_sobel/u_core/pr [6]), .CI(\u_sobel/u_core/sub_17/add_2/n12 ), 
            .O(\u_sobel/u_core/n109 [6]), .CO(\u_sobel/u_core/sub_17/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i6  (.I0(\u_sobel/u_core/pl [5]), 
            .I1(\u_sobel/u_core/pr [5]), .CI(\u_sobel/u_core/sub_17/add_2/n10 ), 
            .O(\u_sobel/u_core/n109 [5]), .CO(\u_sobel/u_core/sub_17/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i5  (.I0(\u_sobel/u_core/pl [4]), 
            .I1(\u_sobel/u_core/pr [4]), .CI(\u_sobel/u_core/sub_17/add_2/n8 ), 
            .O(\u_sobel/u_core/n109 [4]), .CO(\u_sobel/u_core/sub_17/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i4  (.I0(\u_sobel/u_core/pl [3]), 
            .I1(\u_sobel/u_core/pr [3]), .CI(\u_sobel/u_core/sub_17/add_2/n6 ), 
            .O(\u_sobel/u_core/n109 [3]), .CO(\u_sobel/u_core/sub_17/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i3  (.I0(\u_sobel/u_core/pl [2]), 
            .I1(\u_sobel/u_core/pr [2]), .CI(\u_sobel/u_core/sub_17/add_2/n4 ), 
            .O(\u_sobel/u_core/n109 [2]), .CO(\u_sobel/u_core/sub_17/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i2  (.I0(\u_sobel/u_core/pl [1]), 
            .I1(\u_sobel/u_core/pr [1]), .CI(\u_sobel/u_core/sub_17/add_2/n2 ), 
            .O(\u_sobel/u_core/n109 [1]), .CO(\u_sobel/u_core/sub_17/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i10  (.I0(\u_sobel/u_core/pr [9]), 
            .I1(\u_sobel/u_core/pl [9]), .CI(\u_sobel/u_core/sub_16/add_2/n18 ), 
            .O(\u_sobel/u_core/n97 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i10 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i9  (.I0(\u_sobel/u_core/pr [8]), 
            .I1(\u_sobel/u_core/pl [8]), .CI(\u_sobel/u_core/sub_16/add_2/n16 ), 
            .O(\u_sobel/u_core/n97 [8]), .CO(\u_sobel/u_core/sub_16/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i9 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i8  (.I0(\u_sobel/u_core/pr [7]), 
            .I1(\u_sobel/u_core/pl [7]), .CI(\u_sobel/u_core/sub_16/add_2/n14 ), 
            .O(\u_sobel/u_core/n97 [7]), .CO(\u_sobel/u_core/sub_16/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i7  (.I0(\u_sobel/u_core/pr [6]), 
            .I1(\u_sobel/u_core/pl [6]), .CI(\u_sobel/u_core/sub_16/add_2/n12 ), 
            .O(\u_sobel/u_core/n97 [6]), .CO(\u_sobel/u_core/sub_16/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i6  (.I0(\u_sobel/u_core/pr [5]), 
            .I1(\u_sobel/u_core/pl [5]), .CI(\u_sobel/u_core/sub_16/add_2/n10 ), 
            .O(\u_sobel/u_core/n97 [5]), .CO(\u_sobel/u_core/sub_16/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i5  (.I0(\u_sobel/u_core/pr [4]), 
            .I1(\u_sobel/u_core/pl [4]), .CI(\u_sobel/u_core/sub_16/add_2/n8 ), 
            .O(\u_sobel/u_core/n97 [4]), .CO(\u_sobel/u_core/sub_16/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i4  (.I0(\u_sobel/u_core/pr [3]), 
            .I1(\u_sobel/u_core/pl [3]), .CI(\u_sobel/u_core/sub_16/add_2/n6 ), 
            .O(\u_sobel/u_core/n97 [3]), .CO(\u_sobel/u_core/sub_16/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i3  (.I0(\u_sobel/u_core/pr [2]), 
            .I1(\u_sobel/u_core/pl [2]), .CI(\u_sobel/u_core/sub_16/add_2/n4 ), 
            .O(\u_sobel/u_core/n97 [2]), .CO(\u_sobel/u_core/sub_16/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i2  (.I0(\u_sobel/u_core/pr [1]), 
            .I1(\u_sobel/u_core/pl [1]), .CI(\u_sobel/u_core/sub_16/add_2/n2 ), 
            .O(\u_sobel/u_core/n97 [1]), .CO(\u_sobel/u_core/sub_16/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i11  (.I0(\u_sobel/u_core/skip [10]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n20 ), .O(\u_sobel/u_core/n252 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i11 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i10  (.I0(\u_sobel/u_core/skip [9]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n18 ), .O(\u_sobel/u_core/n252 [9]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i9  (.I0(\u_sobel/u_core/skip [8]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n16 ), .O(\u_sobel/u_core/n252 [8]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i8  (.I0(\u_sobel/u_core/skip [7]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n14 ), .O(\u_sobel/u_core/n252 [7]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i7  (.I0(\u_sobel/u_core/skip [6]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n12 ), .O(\u_sobel/u_core/n252 [6]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i6  (.I0(\u_sobel/u_core/skip [5]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n10 ), .O(\u_sobel/u_core/n252 [5]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i5  (.I0(\u_sobel/u_core/skip [4]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n8 ), .O(\u_sobel/u_core/n252 [4]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i4  (.I0(\u_sobel/u_core/skip [3]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n6 ), .O(\u_sobel/u_core/n252 [3]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i3  (.I0(\u_sobel/u_core/skip [2]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n4 ), .O(\u_sobel/u_core/n252 [2]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i2  (.I0(\u_sobel/u_core/skip [1]), 
            .I1(1'b1), .CI(\u_sobel/u_core/sub_41/add_2/n2 ), .O(\u_sobel/u_core/n252 [1]), 
            .CO(\u_sobel/u_core/sub_41/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i8  (.I0(\u_sobel/n1176 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_248/n14 ), .O(\u_sobel/u_core/n201 [8]), 
            .CO(n1282)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i7  (.I0(\u_sobel/n1171 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_248/n12 ), .CO(\u_sobel/u_core/add_248/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i6  (.I0(\u_sobel/n1166 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_248/n10 ), .CO(\u_sobel/u_core/add_248/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i5  (.I0(\u_sobel/n1161 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_248/n8 ), .CO(\u_sobel/u_core/add_248/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i4  (.I0(\u_sobel/n1156 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_248/n6 ), .CO(\u_sobel/u_core/add_248/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i3  (.I0(\u_sobel/n1151 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_248/n4 ), .CO(\u_sobel/u_core/add_248/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i2  (.I0(\u_sobel/n1146 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_248/n2 ), .CO(\u_sobel/u_core/add_248/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i11  (.I0(\u_sobel/u_core/ax [10]), .I1(\u_sobel/u_core/ay [10]), 
            .CI(\u_sobel/u_core/add_23/n20 ), .O(\u_sobel/u_core/sum [10]), 
            .CO(n1283)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i11 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i10  (.I0(\u_sobel/u_core/ax [9]), .I1(\u_sobel/u_core/ay [9]), 
            .CI(\u_sobel/u_core/add_23/n18 ), .O(\u_sobel/u_core/sum [9]), 
            .CO(\u_sobel/u_core/add_23/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i9  (.I0(\u_sobel/u_core/ax [8]), .I1(\u_sobel/u_core/ay [8]), 
            .CI(\u_sobel/u_core/add_23/n16 ), .O(\u_sobel/u_core/sum [8]), 
            .CO(\u_sobel/u_core/add_23/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i8  (.I0(\u_sobel/u_core/ax [7]), .I1(\u_sobel/u_core/ay [7]), 
            .CI(\u_sobel/u_core/add_23/n14 ), .O(\u_sobel/u_core/sum [7]), 
            .CO(\u_sobel/u_core/add_23/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i7  (.I0(\u_sobel/u_core/ax [6]), .I1(\u_sobel/u_core/ay [6]), 
            .CI(\u_sobel/u_core/add_23/n12 ), .O(\u_sobel/u_core/sum [6]), 
            .CO(\u_sobel/u_core/add_23/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i6  (.I0(\u_sobel/u_core/ax [5]), .I1(\u_sobel/u_core/ay [5]), 
            .CI(\u_sobel/u_core/add_23/n10 ), .O(\u_sobel/u_core/sum [5]), 
            .CO(\u_sobel/u_core/add_23/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i5  (.I0(\u_sobel/u_core/ax [4]), .I1(\u_sobel/u_core/ay [4]), 
            .CI(\u_sobel/u_core/add_23/n8 ), .O(\u_sobel/u_core/sum [4]), 
            .CO(\u_sobel/u_core/add_23/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i4  (.I0(\u_sobel/u_core/ax [3]), .I1(\u_sobel/u_core/ay [3]), 
            .CI(\u_sobel/u_core/add_23/n6 ), .O(\u_sobel/u_core/sum [3]), 
            .CO(\u_sobel/u_core/add_23/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i3  (.I0(\u_sobel/u_core/ax [2]), .I1(\u_sobel/u_core/ay [2]), 
            .CI(\u_sobel/u_core/add_23/n4 ), .O(\u_sobel/u_core/sum [2]), 
            .CO(\u_sobel/u_core/add_23/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i2  (.I0(\u_sobel/u_core/ax [1]), .I1(\u_sobel/u_core/ay [1]), 
            .CI(\u_sobel/u_core/add_23/n2 ), .O(\u_sobel/u_core/sum [1]), 
            .CO(\u_sobel/u_core/add_23/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_106/i6  (.I0(\u_sobel/cnt [5]), .I1(1'b0), .CI(\u_sobel/add_106/n10 ), 
            .O(\u_sobel/n590 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/add_106/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_106/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_106/i5  (.I0(\u_sobel/cnt [4]), .I1(1'b0), .CI(\u_sobel/add_106/n8 ), 
            .O(\u_sobel/n590 [4]), .CO(\u_sobel/add_106/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/add_106/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_106/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_106/i4  (.I0(\u_sobel/cnt [3]), .I1(1'b0), .CI(\u_sobel/add_106/n6 ), 
            .O(\u_sobel/n590 [3]), .CO(\u_sobel/add_106/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/add_106/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_106/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_106/i3  (.I0(\u_sobel/cnt [2]), .I1(1'b0), .CI(\u_sobel/add_106/n4 ), 
            .O(\u_sobel/n590 [2]), .CO(\u_sobel/add_106/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/add_106/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_106/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_106/i2  (.I0(\u_sobel/cnt [1]), .I1(1'b0), .CI(\u_sobel/add_106/n2 ), 
            .O(\u_sobel/n590 [1]), .CO(\u_sobel/add_106/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/add_106/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_106/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i8  (.I0(1'b0), .I1(\u_sobel/u_core/b2 [7]), 
            .CI(\u_sobel/u_core/add_7/n14 ), .O(\u_sobel/u_core/n9 [7]), 
            .CO(n1284)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i7  (.I0(\u_sobel/u_core/a2 [7]), .I1(\u_sobel/u_core/b2 [6]), 
            .CI(\u_sobel/u_core/add_7/n12 ), .O(\u_sobel/u_core/n9 [6]), 
            .CO(\u_sobel/u_core/add_7/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i6  (.I0(\u_sobel/u_core/a2 [6]), .I1(\u_sobel/u_core/b2 [5]), 
            .CI(\u_sobel/u_core/add_7/n10 ), .O(\u_sobel/u_core/n9 [5]), 
            .CO(\u_sobel/u_core/add_7/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i5  (.I0(\u_sobel/u_core/a2 [5]), .I1(\u_sobel/u_core/b2 [4]), 
            .CI(\u_sobel/u_core/add_7/n8 ), .O(\u_sobel/u_core/n9 [4]), 
            .CO(\u_sobel/u_core/add_7/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i4  (.I0(\u_sobel/u_core/a2 [4]), .I1(\u_sobel/u_core/b2 [3]), 
            .CI(\u_sobel/u_core/add_7/n6 ), .O(\u_sobel/u_core/n9 [3]), 
            .CO(\u_sobel/u_core/add_7/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i3  (.I0(\u_sobel/u_core/a2 [3]), .I1(\u_sobel/u_core/b2 [2]), 
            .CI(\u_sobel/u_core/add_7/n4 ), .O(\u_sobel/u_core/n9 [2]), 
            .CO(\u_sobel/u_core/add_7/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i2  (.I0(\u_sobel/u_core/a2 [2]), .I1(\u_sobel/u_core/b2 [1]), 
            .CI(\u_sobel/u_core/add_7/n2 ), .O(\u_sobel/u_core/n9 [1]), 
            .CO(\u_sobel/u_core/add_7/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i10  (.I0(\u_sobel/u_core/n8 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_8/n18 ), .O(\u_sobel/u_core/pr [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i9  (.I0(\u_sobel/u_core/n9 [7]), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_8/n16 ), .O(\u_sobel/u_core/pr [8]), 
            .CO(\u_sobel/u_core/add_8/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i8  (.I0(\u_sobel/u_core/n9 [6]), .I1(\u_sobel/u_core/c2 [7]), 
            .CI(\u_sobel/u_core/add_8/n14 ), .O(\u_sobel/u_core/pr [7]), 
            .CO(\u_sobel/u_core/add_8/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i7  (.I0(\u_sobel/u_core/n9 [5]), .I1(\u_sobel/u_core/c2 [6]), 
            .CI(\u_sobel/u_core/add_8/n12 ), .O(\u_sobel/u_core/pr [6]), 
            .CO(\u_sobel/u_core/add_8/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i6  (.I0(\u_sobel/u_core/n9 [4]), .I1(\u_sobel/u_core/c2 [5]), 
            .CI(\u_sobel/u_core/add_8/n10 ), .O(\u_sobel/u_core/pr [5]), 
            .CO(\u_sobel/u_core/add_8/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i5  (.I0(\u_sobel/u_core/n9 [3]), .I1(\u_sobel/u_core/c2 [4]), 
            .CI(\u_sobel/u_core/add_8/n8 ), .O(\u_sobel/u_core/pr [4]), 
            .CO(\u_sobel/u_core/add_8/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i4  (.I0(\u_sobel/u_core/n9 [2]), .I1(\u_sobel/u_core/c2 [3]), 
            .CI(\u_sobel/u_core/add_8/n6 ), .O(\u_sobel/u_core/pr [3]), 
            .CO(\u_sobel/u_core/add_8/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i2  (.I0(\u_sobel/flush_left [1]), .I1(1'b1), 
            .CI(\u_sobel/sub_72/add_2/n2 ), .O(\u_sobel/n276 [1]), .CO(\u_sobel/sub_72/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i3  (.I0(\u_sobel/u_core/n9 [1]), .I1(\u_sobel/u_core/c2 [2]), 
            .CI(\u_sobel/u_core/add_8/n4 ), .O(\u_sobel/u_core/pr [2]), 
            .CO(\u_sobel/u_core/add_8/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_8/i2  (.I0(\u_sobel/u_core/n9 [0]), .I1(\u_sobel/u_core/c2 [1]), 
            .CI(\u_sobel/u_core/add_8/n2 ), .O(\u_sobel/u_core/pr [1]), 
            .CO(\u_sobel/u_core/add_8/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_8/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_8/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \add_31/i2  (.I0(por[2]), .I1(1'b0), .CI(\add_31/n2 ), .O(n10_3[2]), 
            .CO(\add_31/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(35)
    defparam \add_31/i2 .I0_POLARITY = 1'b1;
    defparam \add_31/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i8  (.I0(1'b0), .I1(\u_sobel/u_core/b0 [7]), 
            .CI(\u_sobel/u_core/add_9/n14 ), .O(\u_sobel/u_core/n31 [7]), 
            .CO(n1285)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i7  (.I0(\u_sobel/u_core/a0 [7]), .I1(\u_sobel/u_core/b0 [6]), 
            .CI(\u_sobel/u_core/add_9/n12 ), .O(\u_sobel/u_core/n31 [6]), 
            .CO(\u_sobel/u_core/add_9/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i6  (.I0(\u_sobel/u_core/a0 [6]), .I1(\u_sobel/u_core/b0 [5]), 
            .CI(\u_sobel/u_core/add_9/n10 ), .O(\u_sobel/u_core/n31 [5]), 
            .CO(\u_sobel/u_core/add_9/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i5  (.I0(\u_sobel/u_core/a0 [5]), .I1(\u_sobel/u_core/b0 [4]), 
            .CI(\u_sobel/u_core/add_9/n8 ), .O(\u_sobel/u_core/n31 [4]), 
            .CO(\u_sobel/u_core/add_9/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i4  (.I0(\u_sobel/u_core/a0 [4]), .I1(\u_sobel/u_core/b0 [3]), 
            .CI(\u_sobel/u_core/add_9/n6 ), .O(\u_sobel/u_core/n31 [3]), 
            .CO(\u_sobel/u_core/add_9/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i3  (.I0(\u_sobel/u_core/a0 [3]), .I1(\u_sobel/u_core/b0 [2]), 
            .CI(\u_sobel/u_core/add_9/n4 ), .O(\u_sobel/u_core/n31 [2]), 
            .CO(\u_sobel/u_core/add_9/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \add_31/i3  (.I0(por[3]), .I1(1'b0), .CI(\add_31/n4 ), .O(n10_4[3]), 
            .CO(\add_31/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(35)
    defparam \add_31/i3 .I0_POLARITY = 1'b1;
    defparam \add_31/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i2  (.I0(\u_sobel/u_core/a0 [2]), .I1(\u_sobel/u_core/b0 [1]), 
            .CI(\u_sobel/u_core/add_9/n2 ), .O(\u_sobel/u_core/n31 [1]), 
            .CO(\u_sobel/u_core/add_9/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i10  (.I0(\u_sobel/u_core/n30 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_10/n18 ), .O(\u_sobel/u_core/pl [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i9  (.I0(\u_sobel/u_core/n31 [7]), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_10/n16 ), .O(\u_sobel/u_core/pl [8]), 
            .CO(\u_sobel/u_core/add_10/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i8  (.I0(\u_sobel/u_core/n31 [6]), .I1(\u_sobel/u_core/c0 [7]), 
            .CI(\u_sobel/u_core/add_10/n14 ), .O(\u_sobel/u_core/pl [7]), 
            .CO(\u_sobel/u_core/add_10/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i7  (.I0(\u_sobel/u_core/n31 [5]), .I1(\u_sobel/u_core/c0 [6]), 
            .CI(\u_sobel/u_core/add_10/n12 ), .O(\u_sobel/u_core/pl [6]), 
            .CO(\u_sobel/u_core/add_10/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i6  (.I0(\u_sobel/u_core/n31 [4]), .I1(\u_sobel/u_core/c0 [5]), 
            .CI(\u_sobel/u_core/add_10/n10 ), .O(\u_sobel/u_core/pl [5]), 
            .CO(\u_sobel/u_core/add_10/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i5  (.I0(\u_sobel/u_core/n31 [3]), .I1(\u_sobel/u_core/c0 [4]), 
            .CI(\u_sobel/u_core/add_10/n8 ), .O(\u_sobel/u_core/pl [4]), 
            .CO(\u_sobel/u_core/add_10/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i4  (.I0(\u_sobel/u_core/n31 [2]), .I1(\u_sobel/u_core/c0 [3]), 
            .CI(\u_sobel/u_core/add_10/n6 ), .O(\u_sobel/u_core/pl [3]), 
            .CO(\u_sobel/u_core/add_10/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i3  (.I0(\u_sobel/u_core/n31 [1]), .I1(\u_sobel/u_core/c0 [2]), 
            .CI(\u_sobel/u_core/add_10/n4 ), .O(\u_sobel/u_core/pl [2]), 
            .CO(\u_sobel/u_core/add_10/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_10/i2  (.I0(\u_sobel/u_core/n31 [0]), .I1(\u_sobel/u_core/c0 [1]), 
            .CI(\u_sobel/u_core/add_10/n2 ), .O(\u_sobel/u_core/pl [1]), 
            .CO(\u_sobel/u_core/add_10/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_10/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_10/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i8  (.I0(1'b0), .I1(\u_sobel/u_core/c1 [7]), 
            .CI(\u_sobel/u_core/add_11/n14 ), .O(\u_sobel/u_core/n53 [7]), 
            .CO(n1286)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i7  (.I0(\u_sobel/u_core/c0 [7]), .I1(\u_sobel/u_core/c1 [6]), 
            .CI(\u_sobel/u_core/add_11/n12 ), .O(\u_sobel/u_core/n53 [6]), 
            .CO(\u_sobel/u_core/add_11/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i6  (.I0(\u_sobel/u_core/c0 [6]), .I1(\u_sobel/u_core/c1 [5]), 
            .CI(\u_sobel/u_core/add_11/n10 ), .O(\u_sobel/u_core/n53 [5]), 
            .CO(\u_sobel/u_core/add_11/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i5  (.I0(\u_sobel/u_core/c0 [5]), .I1(\u_sobel/u_core/c1 [4]), 
            .CI(\u_sobel/u_core/add_11/n8 ), .O(\u_sobel/u_core/n53 [4]), 
            .CO(\u_sobel/u_core/add_11/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i4  (.I0(\u_sobel/u_core/c0 [4]), .I1(\u_sobel/u_core/c1 [3]), 
            .CI(\u_sobel/u_core/add_11/n6 ), .O(\u_sobel/u_core/n53 [3]), 
            .CO(\u_sobel/u_core/add_11/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i3  (.I0(\u_sobel/u_core/c0 [3]), .I1(\u_sobel/u_core/c1 [2]), 
            .CI(\u_sobel/u_core/add_11/n4 ), .O(\u_sobel/u_core/n53 [2]), 
            .CO(\u_sobel/u_core/add_11/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i2  (.I0(\u_sobel/u_core/c0 [2]), .I1(\u_sobel/u_core/c1 [1]), 
            .CI(\u_sobel/u_core/add_11/n2 ), .O(\u_sobel/u_core/n53 [1]), 
            .CO(\u_sobel/u_core/add_11/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i10  (.I0(\u_sobel/u_core/n52 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_12/n18 ), .O(\u_sobel/u_core/pb [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i9  (.I0(\u_sobel/u_core/n53 [7]), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_12/n16 ), .O(\u_sobel/u_core/pb [8]), 
            .CO(\u_sobel/u_core/add_12/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i8  (.I0(\u_sobel/u_core/n53 [6]), .I1(\u_sobel/u_core/c2 [7]), 
            .CI(\u_sobel/u_core/add_12/n14 ), .O(\u_sobel/u_core/pb [7]), 
            .CO(\u_sobel/u_core/add_12/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i7  (.I0(\u_sobel/u_core/n53 [5]), .I1(\u_sobel/u_core/c2 [6]), 
            .CI(\u_sobel/u_core/add_12/n12 ), .O(\u_sobel/u_core/pb [6]), 
            .CO(\u_sobel/u_core/add_12/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i6  (.I0(\u_sobel/u_core/n53 [4]), .I1(\u_sobel/u_core/c2 [5]), 
            .CI(\u_sobel/u_core/add_12/n10 ), .O(\u_sobel/u_core/pb [5]), 
            .CO(\u_sobel/u_core/add_12/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i5  (.I0(\u_sobel/u_core/n53 [3]), .I1(\u_sobel/u_core/c2 [4]), 
            .CI(\u_sobel/u_core/add_12/n8 ), .O(\u_sobel/u_core/pb [4]), 
            .CO(\u_sobel/u_core/add_12/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i4  (.I0(\u_sobel/u_core/n53 [2]), .I1(\u_sobel/u_core/c2 [3]), 
            .CI(\u_sobel/u_core/add_12/n6 ), .O(\u_sobel/u_core/pb [3]), 
            .CO(\u_sobel/u_core/add_12/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i3  (.I0(\u_sobel/u_core/n53 [1]), .I1(\u_sobel/u_core/c2 [2]), 
            .CI(\u_sobel/u_core/add_12/n4 ), .O(\u_sobel/u_core/pb [2]), 
            .CO(\u_sobel/u_core/add_12/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_12/i2  (.I0(\u_sobel/u_core/n53 [0]), .I1(\u_sobel/u_core/c2 [1]), 
            .CI(\u_sobel/u_core/add_12/n2 ), .O(\u_sobel/u_core/pb [1]), 
            .CO(\u_sobel/u_core/add_12/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_12/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_12/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i8  (.I0(1'b0), .I1(\u_sobel/u_core/a1 [7]), 
            .CI(\u_sobel/u_core/add_13/n14 ), .O(\u_sobel/u_core/n75 [7]), 
            .CO(n1287)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i7  (.I0(\u_sobel/u_core/a0 [7]), .I1(\u_sobel/u_core/a1 [6]), 
            .CI(\u_sobel/u_core/add_13/n12 ), .O(\u_sobel/u_core/n75 [6]), 
            .CO(\u_sobel/u_core/add_13/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i6  (.I0(\u_sobel/u_core/a0 [6]), .I1(\u_sobel/u_core/a1 [5]), 
            .CI(\u_sobel/u_core/add_13/n10 ), .O(\u_sobel/u_core/n75 [5]), 
            .CO(\u_sobel/u_core/add_13/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i5  (.I0(\u_sobel/u_core/a0 [5]), .I1(\u_sobel/u_core/a1 [4]), 
            .CI(\u_sobel/u_core/add_13/n8 ), .O(\u_sobel/u_core/n75 [4]), 
            .CO(\u_sobel/u_core/add_13/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i4  (.I0(\u_sobel/u_core/a0 [4]), .I1(\u_sobel/u_core/a1 [3]), 
            .CI(\u_sobel/u_core/add_13/n6 ), .O(\u_sobel/u_core/n75 [3]), 
            .CO(\u_sobel/u_core/add_13/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i3  (.I0(\u_sobel/u_core/a0 [3]), .I1(\u_sobel/u_core/a1 [2]), 
            .CI(\u_sobel/u_core/add_13/n4 ), .O(\u_sobel/u_core/n75 [2]), 
            .CO(\u_sobel/u_core/add_13/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i2  (.I0(\u_sobel/u_core/a0 [2]), .I1(\u_sobel/u_core/a1 [1]), 
            .CI(\u_sobel/u_core/add_13/n2 ), .O(\u_sobel/u_core/n75 [1]), 
            .CO(\u_sobel/u_core/add_13/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i23  (.I0(\u_sobel/tmo [23]), .I1(1'b0), .CI(\u_sobel/add_182/n44 ), 
            .O(\u_sobel/n71 [23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i23 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i23 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i22  (.I0(\u_sobel/tmo [22]), .I1(1'b0), .CI(\u_sobel/add_182/n42 ), 
            .O(\u_sobel/n71 [22]), .CO(\u_sobel/add_182/n44 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i22 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i22 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i21  (.I0(\u_sobel/tmo [21]), .I1(1'b0), .CI(\u_sobel/add_182/n40 ), 
            .O(\u_sobel/n71 [21]), .CO(\u_sobel/add_182/n42 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i21 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i21 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i20  (.I0(\u_sobel/tmo [20]), .I1(1'b0), .CI(\u_sobel/add_182/n38 ), 
            .O(\u_sobel/n71 [20]), .CO(\u_sobel/add_182/n40 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i20 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i20 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i19  (.I0(\u_sobel/tmo [19]), .I1(1'b0), .CI(\u_sobel/add_182/n36 ), 
            .O(\u_sobel/n71 [19]), .CO(\u_sobel/add_182/n38 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i19 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i19 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i18  (.I0(\u_sobel/tmo [18]), .I1(1'b0), .CI(\u_sobel/add_182/n34 ), 
            .O(\u_sobel/n71 [18]), .CO(\u_sobel/add_182/n36 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i18 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i18 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i17  (.I0(\u_sobel/tmo [17]), .I1(1'b0), .CI(\u_sobel/add_182/n32 ), 
            .O(\u_sobel/n71 [17]), .CO(\u_sobel/add_182/n34 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i17 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i17 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i16  (.I0(\u_sobel/tmo [16]), .I1(1'b0), .CI(\u_sobel/add_182/n30 ), 
            .O(\u_sobel/n71 [16]), .CO(\u_sobel/add_182/n32 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i16 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i16 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i15  (.I0(\u_sobel/tmo [15]), .I1(1'b0), .CI(\u_sobel/add_182/n28 ), 
            .O(\u_sobel/n71 [15]), .CO(\u_sobel/add_182/n30 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i15 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i15 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i14  (.I0(\u_sobel/tmo [14]), .I1(1'b0), .CI(\u_sobel/add_182/n26 ), 
            .O(\u_sobel/n71 [14]), .CO(\u_sobel/add_182/n28 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i14 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i14 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i13  (.I0(\u_sobel/tmo [13]), .I1(1'b0), .CI(\u_sobel/add_182/n24 ), 
            .O(\u_sobel/n71 [13]), .CO(\u_sobel/add_182/n26 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i13 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i13 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i12  (.I0(\u_sobel/tmo [12]), .I1(1'b0), .CI(\u_sobel/add_182/n22 ), 
            .O(\u_sobel/n71 [12]), .CO(\u_sobel/add_182/n24 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i12 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i12 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i11  (.I0(\u_sobel/tmo [11]), .I1(1'b0), .CI(\u_sobel/add_182/n20 ), 
            .O(\u_sobel/n71 [11]), .CO(\u_sobel/add_182/n22 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i11 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i10  (.I0(\u_sobel/tmo [10]), .I1(1'b0), .CI(\u_sobel/add_182/n18 ), 
            .O(\u_sobel/n71 [10]), .CO(\u_sobel/add_182/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i9  (.I0(\u_sobel/tmo [9]), .I1(1'b0), .CI(\u_sobel/add_182/n16 ), 
            .O(\u_sobel/n71 [9]), .CO(\u_sobel/add_182/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i8  (.I0(\u_sobel/tmo [8]), .I1(1'b0), .CI(\u_sobel/add_182/n14 ), 
            .O(\u_sobel/n71 [8]), .CO(\u_sobel/add_182/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i7  (.I0(\u_sobel/tmo [7]), .I1(1'b0), .CI(\u_sobel/add_182/n12 ), 
            .O(\u_sobel/n71 [7]), .CO(\u_sobel/add_182/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \add_31/i4  (.I0(por[4]), .I1(1'b0), .CI(\add_31/n6 ), .O(n10_5[4]), 
            .CO(\add_31/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(35)
    defparam \add_31/i4 .I0_POLARITY = 1'b1;
    defparam \add_31/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i6  (.I0(\u_sobel/tmo [6]), .I1(1'b0), .CI(\u_sobel/add_182/n10 ), 
            .O(\u_sobel/n71 [6]), .CO(\u_sobel/add_182/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i5  (.I0(\u_sobel/tmo [5]), .I1(1'b0), .CI(\u_sobel/add_182/n8 ), 
            .O(\u_sobel/n71 [5]), .CO(\u_sobel/add_182/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i4  (.I0(\u_sobel/tmo [4]), .I1(1'b0), .CI(\u_sobel/add_182/n6 ), 
            .O(\u_sobel/n71 [4]), .CO(\u_sobel/add_182/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i3  (.I0(\u_sobel/tmo [3]), .I1(1'b0), .CI(\u_sobel/add_182/n4 ), 
            .O(\u_sobel/n71 [3]), .CO(\u_sobel/add_182/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_182/i2  (.I0(\u_sobel/tmo [2]), .I1(1'b0), .CI(\u_sobel/add_182/n2 ), 
            .O(\u_sobel/n71 [2]), .CO(\u_sobel/add_182/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam \u_sobel/add_182/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_182/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i10  (.I0(\u_sobel/u_core/n74 ), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_14/n18 ), .O(\u_sobel/u_core/pt [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i9  (.I0(\u_sobel/u_core/n75 [7]), .I1(1'b0), 
            .CI(\u_sobel/u_core/add_14/n16 ), .O(\u_sobel/u_core/pt [8]), 
            .CO(\u_sobel/u_core/add_14/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i8  (.I0(\u_sobel/u_core/n75 [6]), .I1(\u_sobel/u_core/a2 [7]), 
            .CI(\u_sobel/u_core/add_14/n14 ), .O(\u_sobel/u_core/pt [7]), 
            .CO(\u_sobel/u_core/add_14/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i7  (.I0(\u_sobel/u_core/n75 [5]), .I1(\u_sobel/u_core/a2 [6]), 
            .CI(\u_sobel/u_core/add_14/n12 ), .O(\u_sobel/u_core/pt [6]), 
            .CO(\u_sobel/u_core/add_14/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i6  (.I0(\u_sobel/u_core/n75 [4]), .I1(\u_sobel/u_core/a2 [5]), 
            .CI(\u_sobel/u_core/add_14/n10 ), .O(\u_sobel/u_core/pt [5]), 
            .CO(\u_sobel/u_core/add_14/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i5  (.I0(\u_sobel/u_core/n75 [3]), .I1(\u_sobel/u_core/a2 [4]), 
            .CI(\u_sobel/u_core/add_14/n8 ), .O(\u_sobel/u_core/pt [4]), 
            .CO(\u_sobel/u_core/add_14/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i4  (.I0(\u_sobel/u_core/n75 [2]), .I1(\u_sobel/u_core/a2 [3]), 
            .CI(\u_sobel/u_core/add_14/n6 ), .O(\u_sobel/u_core/pt [3]), 
            .CO(\u_sobel/u_core/add_14/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i3  (.I0(\u_sobel/u_core/n75 [1]), .I1(\u_sobel/u_core/a2 [2]), 
            .CI(\u_sobel/u_core/add_14/n4 ), .O(\u_sobel/u_core/pt [2]), 
            .CO(\u_sobel/u_core/add_14/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_14/i2  (.I0(\u_sobel/u_core/n75 [0]), .I1(\u_sobel/u_core/a2 [1]), 
            .CI(\u_sobel/u_core/add_14/n2 ), .O(\u_sobel/u_core/pt [1]), 
            .CO(\u_sobel/u_core/add_14/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_14/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_14/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i15  (.I0(\u_sobel/wreg [15]), .I1(1'b0), .CI(\u_sobel/add_184/n28 ), 
            .O(\u_sobel/n240 [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i15 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i15 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i14  (.I0(\u_sobel/wreg [14]), .I1(1'b0), .CI(\u_sobel/add_184/n26 ), 
            .O(\u_sobel/n240 [14]), .CO(\u_sobel/add_184/n28 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i14 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i14 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i13  (.I0(\u_sobel/wreg [13]), .I1(1'b0), .CI(\u_sobel/add_184/n24 ), 
            .O(\u_sobel/n240 [13]), .CO(\u_sobel/add_184/n26 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i13 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i13 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i12  (.I0(\u_sobel/wreg [12]), .I1(1'b0), .CI(\u_sobel/add_184/n22 ), 
            .O(\u_sobel/n240 [12]), .CO(\u_sobel/add_184/n24 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i12 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i12 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i11  (.I0(\u_sobel/wreg [11]), .I1(1'b0), .CI(\u_sobel/add_184/n20 ), 
            .O(\u_sobel/n240 [11]), .CO(\u_sobel/add_184/n22 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i11 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_107/add_2/i1  (.I0(\u_sobel/n590 [0]), .I1(\u_sobel/pop ), 
            .CI(n1288), .O(\u_sobel/n597 [0]), .CO(\u_sobel/sub_107/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/sub_107/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_107/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \u_sobel/add_184/i10  (.I0(\u_sobel/wreg [10]), .I1(1'b0), .CI(\u_sobel/add_184/n18 ), 
            .O(\u_sobel/n240 [10]), .CO(\u_sobel/add_184/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i10 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i2  (.I0(done_cnt[1]), .I1(1'b1), .CI(\sub_14/add_2/n2 ), 
            .O(n42_2[1]), .CO(\sub_14/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i9  (.I0(\u_sobel/wreg [9]), .I1(1'b0), .CI(\u_sobel/add_184/n16 ), 
            .O(\u_sobel/n240 [9]), .CO(\u_sobel/add_184/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i9 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i8  (.I0(\u_sobel/wreg [8]), .I1(1'b0), .CI(\u_sobel/add_184/n14 ), 
            .O(\u_sobel/n240 [8]), .CO(\u_sobel/add_184/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i8 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i1  (.I0(rx_cnt[0]), .I1(1'b0), .CI(n1289), 
            .CO(\sub_18/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i7  (.I0(\u_sobel/wreg [7]), .I1(1'b0), .CI(\u_sobel/add_184/n12 ), 
            .O(\u_sobel/n240 [7]), .CO(\u_sobel/add_184/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i7 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i6  (.I0(\u_sobel/wreg [6]), .I1(1'b0), .CI(\u_sobel/add_184/n10 ), 
            .O(\u_sobel/n240 [6]), .CO(\u_sobel/add_184/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i6 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i5  (.I0(\u_sobel/wreg [5]), .I1(1'b0), .CI(\u_sobel/add_184/n8 ), 
            .O(\u_sobel/n240 [5]), .CO(\u_sobel/add_184/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i5 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i4  (.I0(\u_sobel/wreg [4]), .I1(1'b0), .CI(\u_sobel/add_184/n6 ), 
            .O(\u_sobel/n240 [4]), .CO(\u_sobel/add_184/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i4 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i3  (.I0(\u_sobel/wreg [3]), .I1(1'b0), .CI(\u_sobel/add_184/n4 ), 
            .O(\u_sobel/n240 [3]), .CO(\u_sobel/add_184/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i3 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/add_184/i2  (.I0(\u_sobel/wreg [2]), .I1(1'b0), .CI(\u_sobel/add_184/n2 ), 
            .O(\u_sobel/n240 [2]), .CO(\u_sobel/add_184/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(158)
    defparam \u_sobel/add_184/i2 .I0_POLARITY = 1'b1;
    defparam \u_sobel/add_184/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \add_31/i7  (.I0(por[7]), .I1(1'b0), .CI(\add_31/n12 ), .O(n10_8[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(35)
    defparam \add_31/i7 .I0_POLARITY = 1'b1;
    defparam \add_31/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \add_31/i6  (.I0(por[6]), .I1(1'b0), .CI(\add_31/n10 ), .O(n10_7[6]), 
            .CO(\add_31/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(35)
    defparam \add_31/i6 .I0_POLARITY = 1'b1;
    defparam \add_31/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \add_31/i5  (.I0(por[5]), .I1(1'b0), .CI(\add_31/n8 ), .O(n10_6[5]), 
            .CO(\add_31/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(35)
    defparam \add_31/i5 .I0_POLARITY = 1'b1;
    defparam \add_31/i5 .I1_POLARITY = 1'b1;
    EFX_RAM_5K \u_sobel/u_core/lbuf__D$b12  (.WCLK(\clk~O ), .RCLK(\clk~O ), 
            .WCLKE(\u_sobel/u_core/n1655 ), .WE(\u_sobel/u_core/st [0]), 
            .RE(n461), .WDATA({\u_sobel/u_core/rd [3:0]}), .WADDR({\u_sobel/u_core/col }), 
            .RADDR({\u_sobel/u_core/col }), .RDATA({\u_sobel/u_core/rd [11:8]})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_RAM_5K, READ_WIDTH=4, WRITE_WIDTH=4, WCLK_POLARITY=1'b1, WCLKE_POLARITY=1'b1, WE_POLARITY=1'b0, RCLK_POLARITY=1'b1, RE_POLARITY=1'b1, OUTPUT_REG=1'b0, WRITE_MODE="READ_FIRST", INIT_0=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_1=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_2=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_3=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_4=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_5=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_6=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_7=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_8=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_9=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_A=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_B=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_C=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_D=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_E=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_F=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_10=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_11=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_12=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_13=256'h0000000000000000000000000000000000000000000000000000000000000000, PRESERVE_USER_INIT=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(30)
    defparam \u_sobel/u_core/lbuf__D$b12 .READ_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$b12 .WRITE_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$b12 .WCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$b12 .WCLKE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$b12 .WE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$b12 .RCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$b12 .RE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$b12 .OUTPUT_REG = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$b12 .WRITE_MODE = "READ_FIRST";
    EFX_RAM_5K \u_sobel/u_core/lbuf__D$c1  (.WCLK(\clk~O ), .RCLK(\clk~O ), 
            .WCLKE(\u_sobel/u_core/n1655 ), .WE(\u_sobel/u_core/st [0]), 
            .RE(n461), .WDATA({\u_sobel/u_core/rd [7:4]}), .WADDR({\u_sobel/u_core/col }), 
            .RADDR({\u_sobel/u_core/col }), .RDATA({\u_sobel/u_core/rd [15:12]})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_RAM_5K, READ_WIDTH=4, WRITE_WIDTH=4, WCLK_POLARITY=1'b1, WCLKE_POLARITY=1'b1, WE_POLARITY=1'b0, RCLK_POLARITY=1'b1, RE_POLARITY=1'b1, OUTPUT_REG=1'b0, WRITE_MODE="READ_FIRST", INIT_0=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_1=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_2=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_3=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_4=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_5=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_6=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_7=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_8=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_9=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_A=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_B=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_C=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_D=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_E=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_F=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_10=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_11=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_12=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_13=256'h0000000000000000000000000000000000000000000000000000000000000000, PRESERVE_USER_INIT=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(30)
    defparam \u_sobel/u_core/lbuf__D$c1 .READ_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$c1 .WRITE_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$c1 .WCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$c1 .WCLKE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$c1 .WE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$c1 .RCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$c1 .RE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$c1 .OUTPUT_REG = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$c1 .WRITE_MODE = "READ_FIRST";
    EFX_RAM_5K \u_sobel/u_core/lbuf__D$12  (.WCLK(\clk~O ), .RCLK(\clk~O ), 
            .WCLKE(\u_sobel/u_core/n1655 ), .WE(\u_sobel/u_core/st [0]), 
            .RE(n461), .WDATA({\u_sobel/u_core/pix [7:4]}), .WADDR({\u_sobel/u_core/col }), 
            .RADDR({\u_sobel/u_core/col }), .RDATA({\u_sobel/u_core/rd [7:4]})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_RAM_5K, READ_WIDTH=4, WRITE_WIDTH=4, WCLK_POLARITY=1'b1, WCLKE_POLARITY=1'b1, WE_POLARITY=1'b0, RCLK_POLARITY=1'b1, RE_POLARITY=1'b1, OUTPUT_REG=1'b0, WRITE_MODE="READ_FIRST", INIT_0=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_1=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_2=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_3=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_4=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_5=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_6=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_7=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_8=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_9=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_A=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_B=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_C=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_D=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_E=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_F=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_10=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_11=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_12=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_13=256'h0000000000000000000000000000000000000000000000000000000000000000, PRESERVE_USER_INIT=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(30)
    defparam \u_sobel/u_core/lbuf__D$12 .READ_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$12 .WRITE_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$12 .WCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$12 .WCLKE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$12 .WE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$12 .RCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$12 .RE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$12 .OUTPUT_REG = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$12 .WRITE_MODE = "READ_FIRST";
    EFX_RAM_5K \u_sobel/u_core/lbuf__D$2  (.WCLK(\clk~O ), .RCLK(\clk~O ), 
            .WCLKE(\u_sobel/u_core/n1655 ), .WE(\u_sobel/u_core/st [0]), 
            .RE(n461), .WDATA({\u_sobel/u_core/pix [3:0]}), .WADDR({\u_sobel/u_core/col }), 
            .RADDR({\u_sobel/u_core/col }), .RDATA({\u_sobel/u_core/rd [3:0]})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_RAM_5K, READ_WIDTH=4, WRITE_WIDTH=4, WCLK_POLARITY=1'b1, WCLKE_POLARITY=1'b1, WE_POLARITY=1'b0, RCLK_POLARITY=1'b1, RE_POLARITY=1'b1, OUTPUT_REG=1'b0, WRITE_MODE="READ_FIRST", INIT_0=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_1=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_2=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_3=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_4=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_5=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_6=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_7=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_8=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_9=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_A=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_B=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_C=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_D=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_E=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_F=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_10=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_11=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_12=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_13=256'h0000000000000000000000000000000000000000000000000000000000000000, PRESERVE_USER_INIT=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(30)
    defparam \u_sobel/u_core/lbuf__D$2 .READ_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$2 .WRITE_WIDTH = 4;
    defparam \u_sobel/u_core/lbuf__D$2 .WCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$2 .WCLKE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$2 .WE_POLARITY = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$2 .RCLK_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$2 .RE_POLARITY = 1'b1;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/u_core/lbuf__D$2 .OUTPUT_REG = 1'b0;
    defparam \u_sobel/u_core/lbuf__D$2 .WRITE_MODE = "READ_FIRST";
    EFX_RAM_5K \u_sobel/fifo  (.WCLK(\clk~O ), .RCLK(\clk~O ), .WCLKE(\u_sobel/n560 ), 
            .WE(\u_sobel/core_valid ), .RE(1'b1), .WDATA({\u_sobel/u_core/n241 }), 
            .WADDR({4'b0000, \u_sobel/wp }), .RADDR({4'b0000, \u_sobel/n611 , 
            \u_sobel/n612 , \u_sobel/n613 , \u_sobel/n614 , \u_sobel/n615 }), 
            .RDATA({\u_sobel/n692 , \u_sobel/n693 , \u_sobel/n694 , \u_sobel/n695 , 
            \u_sobel/n696 , \u_sobel/n697 , \u_sobel/n698 , \u_sobel/n699 })) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_RAM_5K, READ_WIDTH=8, WRITE_WIDTH=8, WCLK_POLARITY=1'b1, WCLKE_POLARITY=1'b0, WE_POLARITY=1'b1, RCLK_POLARITY=1'b1, RE_POLARITY=1'b1, OUTPUT_REG=1'b0, WRITE_MODE="WRITE_FIRST", INIT_0=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_1=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_2=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_3=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_4=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_5=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_6=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_7=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_8=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_9=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_A=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_B=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_C=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_D=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_E=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_F=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_10=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_11=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_12=256'h0000000000000000000000000000000000000000000000000000000000000000, INIT_13=256'h0000000000000000000000000000000000000000000000000000000000000000, PRESERVE_USER_INIT=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(57)
    defparam \u_sobel/fifo .READ_WIDTH = 8;
    defparam \u_sobel/fifo .WRITE_WIDTH = 8;
    defparam \u_sobel/fifo .WCLK_POLARITY = 1'b1;
    defparam \u_sobel/fifo .WCLKE_POLARITY = 1'b0;
    defparam \u_sobel/fifo .WE_POLARITY = 1'b1;
    defparam \u_sobel/fifo .RCLK_POLARITY = 1'b1;
    defparam \u_sobel/fifo .RE_POLARITY = 1'b1;
    defparam \u_sobel/fifo .INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    defparam \u_sobel/fifo .OUTPUT_REG = 1'b0;
    defparam \u_sobel/fifo .WRITE_MODE = "WRITE_FIRST";
    EFX_LUT4 LUT__2598 (.I0(n1080), .I1(n1081), .O(n1082)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2598.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2599 (.I0(done_cnt[11]), .I1(done_cnt[15]), .I2(done_cnt[16]), 
            .I3(done_cnt[18]), .O(n1083)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2599.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2600 (.I0(done_cnt[12]), .I1(done_cnt[13]), .I2(done_cnt[14]), 
            .I3(n1083), .O(n1084)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2600.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2601 (.I0(done_cnt[0]), .I1(done_cnt[1]), .I2(done_cnt[2]), 
            .I3(done_cnt[22]), .O(n1085)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2601.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2602 (.I0(done_cnt[17]), .I1(done_cnt[19]), .I2(done_cnt[20]), 
            .I3(done_cnt[21]), .O(n1086)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2602.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2603 (.I0(n1082), .I1(n1084), .I2(n1085), .I3(n1086), 
            .O(led1)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam LUT__2603.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2604 (.I0(rx_cnt[16]), .I1(rx_cnt[17]), .I2(rx_cnt[18]), 
            .I3(rx_cnt[19]), .O(n1087)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2604.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2605 (.I0(rx_cnt[20]), .I1(rx_cnt[21]), .I2(rx_cnt[22]), 
            .I3(n1087), .O(n1088)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2605.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2606 (.I0(rx_cnt[4]), .I1(rx_cnt[5]), .I2(rx_cnt[6]), 
            .I3(rx_cnt[7]), .O(n1089)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2606.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2607 (.I0(rx_cnt[0]), .I1(rx_cnt[1]), .I2(rx_cnt[2]), 
            .I3(n1089), .O(n1090)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2607.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2608 (.I0(rx_cnt[3]), .I1(rx_cnt[8]), .I2(rx_cnt[9]), 
            .I3(rx_cnt[10]), .O(n1091)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2608.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2609 (.I0(rx_cnt[12]), .I1(rx_cnt[13]), .I2(rx_cnt[14]), 
            .I3(rx_cnt[15]), .O(n1092)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2609.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2610 (.I0(rx_cnt[11]), .I1(n1091), .I2(n1092), .O(n1093)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;
    defparam LUT__2610.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2611 (.I0(n1088), .I1(n1090), .I2(n1093), .O(led2)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam LUT__2611.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2612 (.I0(por[4]), .I1(por[5]), .I2(por[6]), .I3(por[7]), 
            .O(n1094)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2612.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2613 (.I0(por[0]), .I1(por[1]), .I2(por[2]), .I3(por[3]), 
            .O(n1095)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2613.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2614 (.I0(n1094), .I1(n1095), .O(\not_equal_3/n15 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7777 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(23)
    defparam LUT__2614.LUTMASK = 16'h7777;
    EFX_LUT4 LUT__2615 (.I0(\u_sobel/flush_left [12]), .I1(\u_sobel/flush_left [13]), 
            .I2(\u_sobel/flush_left [14]), .I3(\u_sobel/flush_left [15]), 
            .O(n1096)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2615.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2616 (.I0(\u_sobel/flush_left [8]), .I1(\u_sobel/flush_left [9]), 
            .I2(\u_sobel/flush_left [10]), .I3(\u_sobel/flush_left [11]), 
            .O(n1097)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2616.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2617 (.I0(\u_sobel/flush_left [4]), .I1(\u_sobel/flush_left [5]), 
            .I2(\u_sobel/flush_left [6]), .I3(\u_sobel/flush_left [7]), 
            .O(n1098)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2617.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2618 (.I0(\u_sobel/flush_left [0]), .I1(\u_sobel/flush_left [1]), 
            .I2(\u_sobel/flush_left [2]), .I3(\u_sobel/flush_left [3]), 
            .O(n1099)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2618.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2619 (.I0(n1096), .I1(n1097), .I2(n1098), .I3(n1099), 
            .O(n1100)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2619.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2620 (.I0(\u_sobel/u_core/st [0]), .I1(\u_sobel/u_core/st [1]), 
            .I2(\u_sobel/flushing ), .O(n1101)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2620.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2621 (.I0(n1100), .I1(n1101), .O(frame_done)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(82)
    defparam LUT__2621.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2622 (.I0(\btn_sync[1] ), .I1(\not_equal_3/n15 ), .O(rst)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(23)
    defparam LUT__2622.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2623 (.I0(\u_sobel/tmo [12]), .I1(\u_sobel/tmo [19]), 
            .I2(\u_sobel/tmo [20]), .I3(\u_sobel/tmo [17]), .O(n1102)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2623.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2624 (.I0(\u_sobel/tmo [14]), .I1(\u_sobel/tmo [15]), 
            .I2(\u_sobel/tmo [16]), .I3(\u_sobel/tmo [13]), .O(n1103)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2624.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2625 (.I0(\u_sobel/tmo [0]), .I1(\u_sobel/tmo [1]), .I2(\u_sobel/tmo [2]), 
            .I3(\u_sobel/tmo [3]), .O(n1104)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2625.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2626 (.I0(\u_sobel/tmo [22]), .I1(\u_sobel/tmo [23]), 
            .I2(\u_sobel/tmo [18]), .I3(\u_sobel/tmo [21]), .O(n1105)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2626.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2627 (.I0(n1102), .I1(n1103), .I2(n1104), .I3(n1105), 
            .O(n1106)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2627.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2628 (.I0(\u_sobel/tmo [9]), .I1(\u_sobel/tmo [8]), .I2(\u_sobel/tmo [5]), 
            .I3(\u_sobel/tmo [10]), .O(n1107)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2628.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2629 (.I0(\u_sobel/tmo [4]), .I1(\u_sobel/tmo [6]), .I2(\u_sobel/tmo [11]), 
            .I3(\u_sobel/tmo [7]), .O(n1108)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2629.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2630 (.I0(n1106), .I1(n1107), .I2(n1108), .O(n1109)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2630.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2631 (.I0(rst), .I1(n1109), .O(\u_sobel/n560 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(168)
    defparam LUT__2631.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2632 (.I0(\u_sobel/cnt [4]), .I1(\u_sobel/cnt [5]), .I2(n1100), 
            .I3(n1101), .O(n1110)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2632.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2633 (.I0(\u_sobel/wreg [0]), .I1(\u_sobel/flush_left [0]), 
            .I2(n1110), .O(\u_sobel/n293 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2633.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2634 (.I0(rst), .I1(n1110), .O(n1111)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2634.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2635 (.I0(\u_sobel/u_core/row [15]), .I1(\u_sobel/hreg [15]), 
            .O(n1112)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2635.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2636 (.I0(\u_sobel/hreg [0]), .I1(\u_sobel/hreg [1]), 
            .I2(\u_sobel/hreg [2]), .I3(\u_sobel/hreg [3]), .O(n1113)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2636.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2637 (.I0(\u_sobel/hreg [4]), .I1(\u_sobel/hreg [5]), 
            .I2(\u_sobel/hreg [6]), .I3(\u_sobel/hreg [7]), .O(n1114)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2637.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2638 (.I0(\u_sobel/hreg [8]), .I1(\u_sobel/hreg [9]), 
            .I2(\u_sobel/hreg [10]), .O(n1115)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__2638.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2639 (.I0(\u_sobel/hreg [11]), .I1(\u_sobel/hreg [12]), 
            .I2(\u_sobel/hreg [13]), .O(n1116)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__2639.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2640 (.I0(n1113), .I1(n1114), .I2(n1115), .I3(n1116), 
            .O(n1117)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2640.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2641 (.I0(\u_sobel/hreg [14]), .I1(n1112), .I2(\u_sobel/u_core/row [14]), 
            .I3(n1117), .O(n1118)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he77b */ ;
    defparam LUT__2641.LUTMASK = 16'he77b;
    EFX_LUT4 LUT__2642 (.I0(\u_sobel/hreg [4]), .I1(\u_sobel/hreg [5]), 
            .I2(n1113), .O(n1119)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2642.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2643 (.I0(\u_sobel/u_core/row [6]), .I1(\u_sobel/hreg [6]), 
            .I2(n1119), .O(n1120)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6969 */ ;
    defparam LUT__2643.LUTMASK = 16'h6969;
    EFX_LUT4 LUT__2644 (.I0(\u_sobel/u_core/row [4]), .I1(\u_sobel/hreg [4]), 
            .O(n1121)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2644.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2645 (.I0(\u_sobel/hreg [0]), .I1(\u_sobel/hreg [1]), 
            .I2(\u_sobel/hreg [2]), .O(n1122)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__2645.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2646 (.I0(\u_sobel/hreg [3]), .I1(n1121), .I2(\u_sobel/u_core/row [3]), 
            .I3(n1122), .O(n1123)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he77b */ ;
    defparam LUT__2646.LUTMASK = 16'he77b;
    EFX_LUT4 LUT__2647 (.I0(\u_sobel/hreg [8]), .I1(\u_sobel/hreg [9]), 
            .I2(\u_sobel/hreg [10]), .I3(\u_sobel/hreg [11]), .O(n1124)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2647.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2648 (.I0(\u_sobel/hreg [12]), .I1(n1113), .I2(n1114), 
            .I3(n1124), .O(n1125)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2648.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2649 (.I0(n1123), .I1(\u_sobel/u_core/row [13]), .I2(\u_sobel/hreg [13]), 
            .I3(n1125), .O(n1126)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1441 */ ;
    defparam LUT__2649.LUTMASK = 16'h1441;
    EFX_LUT4 LUT__2650 (.I0(\u_sobel/u_core/row [2]), .I1(\u_sobel/hreg [2]), 
            .O(n1127)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2650.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2651 (.I0(\u_sobel/hreg [0]), .I1(\u_sobel/hreg [1]), 
            .I2(n1127), .I3(\u_sobel/u_core/row [1]), .O(n1128)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7e9f */ ;
    defparam LUT__2651.LUTMASK = 16'h7e9f;
    EFX_LUT4 LUT__2652 (.I0(\u_sobel/hreg [4]), .I1(\u_sobel/hreg [5]), 
            .I2(\u_sobel/hreg [6]), .I3(n1113), .O(n1129)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2652.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2653 (.I0(\u_sobel/u_core/row [7]), .I1(\u_sobel/hreg [7]), 
            .O(n1130)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2653.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2654 (.I0(\u_sobel/hreg [0]), .I1(\u_sobel/u_core/row [0]), 
            .I2(\u_sobel/in_frame ), .I3(rx_seen), .O(n1131)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6000 */ ;
    defparam LUT__2654.LUTMASK = 16'h6000;
    EFX_LUT4 LUT__2655 (.I0(n1128), .I1(n1129), .I2(n1130), .I3(n1131), 
            .O(n1132)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1400 */ ;
    defparam LUT__2655.LUTMASK = 16'h1400;
    EFX_LUT4 LUT__2656 (.I0(\u_sobel/hreg [4]), .I1(n1113), .I2(\u_sobel/u_core/row [5]), 
            .I3(\u_sobel/hreg [5]), .O(n1133)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb44b */ ;
    defparam LUT__2656.LUTMASK = 16'hb44b;
    EFX_LUT4 LUT__2657 (.I0(\u_sobel/u_core/row [8]), .I1(\u_sobel/hreg [8]), 
            .O(n1134)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2657.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2658 (.I0(n1113), .I1(n1114), .O(n1135)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2658.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2659 (.I0(n1134), .I1(n1135), .I2(n1133), .O(n1136)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6060 */ ;
    defparam LUT__2659.LUTMASK = 16'h6060;
    EFX_LUT4 LUT__2660 (.I0(n1120), .I1(n1126), .I2(n1132), .I3(n1136), 
            .O(n1137)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2660.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2661 (.I0(\u_sobel/u_core/row [10]), .I1(\u_sobel/hreg [10]), 
            .O(n1138)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2661.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2662 (.I0(\u_sobel/hreg [8]), .I1(n1113), .I2(n1114), 
            .O(n1139)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;
    defparam LUT__2662.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2663 (.I0(\u_sobel/hreg [9]), .I1(n1138), .I2(\u_sobel/u_core/row [9]), 
            .I3(n1139), .O(n1140)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he77b */ ;
    defparam LUT__2663.LUTMASK = 16'he77b;
    EFX_LUT4 LUT__2664 (.I0(\u_sobel/u_core/row [12]), .I1(\u_sobel/hreg [12]), 
            .O(n1141)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2664.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2665 (.I0(n1113), .I1(n1114), .I2(n1115), .O(n1142)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2665.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2666 (.I0(\u_sobel/hreg [11]), .I1(n1141), .I2(\u_sobel/u_core/row [11]), 
            .I3(n1142), .O(n1143)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he77b */ ;
    defparam LUT__2666.LUTMASK = 16'he77b;
    EFX_LUT4 LUT__2667 (.I0(n1140), .I1(n1143), .O(n1144)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2667.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2668 (.I0(\u_sobel/u_core/col [7]), .I1(\u_sobel/wreg [7]), 
            .O(n1145)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2668.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2669 (.I0(\u_sobel/wreg [0]), .I1(\u_sobel/wreg [1]), 
            .I2(\u_sobel/wreg [2]), .I3(\u_sobel/wreg [3]), .O(n1146)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2669.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2670 (.I0(\u_sobel/wreg [4]), .I1(\u_sobel/wreg [5]), 
            .I2(n1146), .O(n1147)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2670.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2671 (.I0(\u_sobel/wreg [6]), .I1(n1145), .I2(\u_sobel/u_core/col [6]), 
            .I3(n1147), .O(n1148)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he77b */ ;
    defparam LUT__2671.LUTMASK = 16'he77b;
    EFX_LUT4 LUT__2672 (.I0(\u_sobel/u_core/col [9]), .I1(\u_sobel/wreg [9]), 
            .O(n1149)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2672.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2673 (.I0(\u_sobel/wreg [4]), .I1(\u_sobel/wreg [5]), 
            .I2(\u_sobel/wreg [6]), .I3(\u_sobel/wreg [7]), .O(n1150)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2673.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2674 (.I0(n1146), .I1(n1150), .O(n1151)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2674.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2675 (.I0(\u_sobel/wreg [8]), .I1(n1149), .I2(\u_sobel/u_core/col [8]), 
            .I3(n1151), .O(n1152)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he77b */ ;
    defparam LUT__2675.LUTMASK = 16'he77b;
    EFX_LUT4 LUT__2676 (.I0(\u_sobel/wreg [4]), .I1(n1146), .O(\u_sobel/n1151 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2676.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2677 (.I0(\u_sobel/wreg [0]), .I1(\u_sobel/u_core/col [1]), 
            .I2(\u_sobel/wreg [1]), .I3(\u_sobel/u_core/col [0]), .O(n1153)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heb7d */ ;
    defparam LUT__2677.LUTMASK = 16'heb7d;
    EFX_LUT4 LUT__2678 (.I0(\u_sobel/u_core/col [2]), .I1(\u_sobel/wreg [2]), 
            .O(n1154)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2678.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2679 (.I0(\u_sobel/wreg [0]), .I1(\u_sobel/wreg [1]), 
            .I2(n1153), .I3(n1154), .O(n1155)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0e01 */ ;
    defparam LUT__2679.LUTMASK = 16'h0e01;
    EFX_LUT4 LUT__2680 (.I0(\u_sobel/u_core/col [4]), .I1(\u_sobel/n1151 ), 
            .I2(n1155), .O(n1156)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9090 */ ;
    defparam LUT__2680.LUTMASK = 16'h9090;
    EFX_LUT4 LUT__2681 (.I0(\u_sobel/wreg [0]), .I1(\u_sobel/wreg [1]), 
            .I2(\u_sobel/wreg [2]), .I3(\u_sobel/wreg [3]), .O(\u_sobel/n1146 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hfe01 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2681.LUTMASK = 16'hfe01;
    EFX_LUT4 LUT__2682 (.I0(\u_sobel/wreg [4]), .I1(n1146), .I2(\u_sobel/wreg [5]), 
            .O(\u_sobel/n1156 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2682.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__2683 (.I0(\u_sobel/u_core/col [3]), .I1(\u_sobel/n1146 ), 
            .I2(\u_sobel/n1156 ), .I3(\u_sobel/u_core/col [5]), .O(n1157)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9009 */ ;
    defparam LUT__2683.LUTMASK = 16'h9009;
    EFX_LUT4 LUT__2684 (.I0(n1148), .I1(n1152), .I2(n1156), .I3(n1157), 
            .O(n1158)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2684.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2685 (.I0(n1118), .I1(n1137), .I2(n1144), .I3(n1158), 
            .O(\u_sobel/n238 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(152)
    defparam LUT__2685.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2686 (.I0(\u_sobel/n238 ), .I1(n1111), .I2(frame_done), 
            .I3(n1109), .O(ceg_net25)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hfff4 */ ;
    defparam LUT__2686.LUTMASK = 16'hfff4;
    EFX_LUT4 LUT__2687 (.I0(\u_sobel/in_frame ), .I1(\u_sobel/hst [0]), 
            .I2(\u_sobel/hst [1]), .I3(\u_sobel/hst [2]), .O(n1159)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2687.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2688 (.I0(\u_sobel/flushing ), .I1(rx_seen), .I2(n1159), 
            .O(\u_sobel/n69 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(120)
    defparam LUT__2688.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2689 (.I0(frame_done), .I1(\u_sobel/n560 ), .O(\u_sobel/n815 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(162)
    defparam LUT__2689.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2690 (.I0(rx_seen), .I1(\u_sobel/n815 ), .O(\u_sobel/n818 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(122)
    defparam LUT__2690.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2691 (.I0(n1147), .I1(\u_sobel/wreg [6]), .I2(\u_sobel/wreg [7]), 
            .O(n1160)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hd0d0 */ ;
    defparam LUT__2691.LUTMASK = 16'hd0d0;
    EFX_LUT4 LUT__2692 (.I0(\u_sobel/hreg [1]), .I1(\u_sobel/hreg [0]), 
            .I2(\u_sobel/rx_data [1]), .I3(\u_sobel/rx_data [0]), .O(n1161)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0007 */ ;
    defparam LUT__2692.LUTMASK = 16'h0007;
    EFX_LUT4 LUT__2693 (.I0(\u_sobel/hreg [2]), .I1(\u_sobel/hreg [3]), 
            .I2(n1114), .I3(n1161), .O(n1162)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2693.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2694 (.I0(\u_sobel/wreg [2]), .I1(\u_sobel/wreg [3]), 
            .I2(\u_sobel/wreg [8]), .I3(\u_sobel/wreg [9]), .O(n1163)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2694.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2695 (.I0(\u_sobel/wreg [1]), .I1(\u_sobel/wreg [0]), 
            .I2(n1150), .I3(n1163), .O(n1164)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7000 */ ;
    defparam LUT__2695.LUTMASK = 16'h7000;
    EFX_LUT4 LUT__2696 (.I0(\u_sobel/wreg [10]), .I1(\u_sobel/wreg [11]), 
            .I2(\u_sobel/wreg [12]), .I3(\u_sobel/wreg [13]), .O(n1165)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2696.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2697 (.I0(\u_sobel/rx_data [3]), .I1(\u_sobel/rx_data [4]), 
            .I2(\u_sobel/rx_data [6]), .O(n1166)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__2697.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2698 (.I0(\u_sobel/rx_data [2]), .I1(\u_sobel/wreg [14]), 
            .I2(\u_sobel/wreg [15]), .I3(n1166), .O(n1167)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2698.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2699 (.I0(\u_sobel/rx_data [5]), .I1(\u_sobel/rx_data [7]), 
            .I2(n1165), .I3(n1167), .O(n1168)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2699.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2700 (.I0(n1162), .I1(n1164), .I2(n1168), .O(n1169)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2700.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2701 (.I0(\u_sobel/wreg [8]), .I1(n1160), .I2(\u_sobel/wreg [9]), 
            .I3(n1169), .O(\u_sobel/dims_ok )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1f00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(68)
    defparam LUT__2701.LUTMASK = 16'h1f00;
    EFX_LUT4 LUT__2702 (.I0(\u_sobel/in_frame ), .I1(\u_sobel/flushing ), 
            .I2(rx_seen), .O(\u_sobel/hdr_step )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(72)
    defparam LUT__2702.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2703 (.I0(\u_sobel/hst [2]), .I1(\u_sobel/dims_ok ), .I2(\u_sobel/hdr_step ), 
            .O(\u_sobel/n805 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(147)
    defparam LUT__2703.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2704 (.I0(\u_sobel/n238 ), .I1(\u_sobel/n815 ), .O(\u_sobel/n816 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(159)
    defparam LUT__2704.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2705 (.I0(\u_sobel/hst [1]), .I1(\u_sobel/hst [2]), .I2(\u_sobel/hst [0]), 
            .O(n1170)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2705.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2706 (.I0(\u_sobel/n815 ), .I1(\u_sobel/hdr_step ), .I2(n1170), 
            .O(\u_sobel/n865 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2706.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2707 (.I0(\u_sobel/hst [2]), .I1(\u_sobel/hst [1]), .I2(\u_sobel/hst [0]), 
            .O(\~u_sobel/equal_55/n5 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;
    defparam LUT__2707.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2708 (.I0(\u_sobel/n815 ), .I1(\u_sobel/hdr_step ), .I2(\~u_sobel/equal_55/n5 ), 
            .O(\u_sobel/n866 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2708.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2709 (.I0(\u_sobel/cnt [0]), .I1(\u_sobel/cnt [1]), .I2(\u_sobel/cnt [2]), 
            .I3(\u_sobel/cnt [3]), .O(n1171)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2709.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2710 (.I0(\u_sobel/u_tx/left [0]), .I1(\u_sobel/u_tx/left [1]), 
            .I2(\u_sobel/u_tx/left [2]), .I3(\u_sobel/u_tx/left [3]), .O(n1172)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2710.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2711 (.I0(\u_sobel/cnt [5]), .I1(\u_sobel/cnt [4]), .I2(n1171), 
            .I3(n1172), .O(\u_sobel/pop )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hef00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(86)
    defparam LUT__2711.LUTMASK = 16'hef00;
    EFX_LUT4 LUT__2712 (.I0(\u_sobel/u_core/pl [0]), .I1(\u_sobel/u_core/pr [0]), 
            .O(\u_sobel/u_core/ay [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2712.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2713 (.I0(\u_sobel/hst [0]), .I1(\u_sobel/rx_data [1]), 
            .I2(\u_sobel/hst [2]), .I3(\u_sobel/rx_data [0]), .O(n1173)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2713.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2714 (.I0(\u_sobel/rx_data [2]), .I1(\u_sobel/rx_data [5]), 
            .I2(\u_sobel/rx_data [7]), .O(n1174)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2714.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2715 (.I0(\u_sobel/hst [0]), .I1(\u_sobel/hst [2]), .I2(\u_sobel/hst [1]), 
            .O(n1175)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2715.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2716 (.I0(n1174), .I1(n1166), .I2(n1173), .I3(n1175), 
            .O(\u_sobel/select_57/Select_0/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hff80 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(149)
    defparam LUT__2716.LUTMASK = 16'hff80;
    EFX_LUT4 LUT__2717 (.I0(\u_sobel/n815 ), .I1(\u_sobel/hst [2]), .I2(\u_sobel/hdr_step ), 
            .O(\u_sobel/n905 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2717.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2718 (.I0(\u_sobel/u_core/col [0]), .I1(n1158), .O(\u_sobel/u_core/n317 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2718.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2719 (.I0(\u_sobel/u_core/st [0]), .I1(\u_sobel/u_core/st [1]), 
            .O(\u_sobel/u_core/n1144 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2719.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2720 (.I0(\u_sobel/start_r ), .I1(rst), .O(\u_sobel/u_core/n199 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(79)
    defparam LUT__2720.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2721 (.I0(\u_sobel/u_core/sum [10]), .I1(\u_sobel/u_core/sum [11]), 
            .I2(\u_sobel/u_core/sum [9]), .I3(\u_sobel/u_core/sum [8]), 
            .O(n1176)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2721.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2722 (.I0(\u_sobel/u_core/row [9]), .I1(n1139), .I2(\u_sobel/hreg [9]), 
            .I3(n1138), .O(n1177)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7100 */ ;
    defparam LUT__2722.LUTMASK = 16'h7100;
    EFX_LUT4 LUT__2723 (.I0(\u_sobel/hreg [8]), .I1(\u_sobel/hreg [9]), 
            .I2(n1113), .I3(n1114), .O(n1178)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2723.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2724 (.I0(\u_sobel/u_core/row [11]), .I1(\u_sobel/hreg [11]), 
            .O(n1179)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2724.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2725 (.I0(\u_sobel/u_core/row [10]), .I1(\u_sobel/hreg [10]), 
            .I2(n1179), .I3(n1178), .O(n1180)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3d4f */ ;
    defparam LUT__2725.LUTMASK = 16'h3d4f;
    EFX_LUT4 LUT__2726 (.I0(n1138), .I1(n1178), .I2(n1180), .O(n1181)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0b0b */ ;
    defparam LUT__2726.LUTMASK = 16'h0b0b;
    EFX_LUT4 LUT__2727 (.I0(\u_sobel/u_core/row [11]), .I1(\u_sobel/hreg [11]), 
            .I2(n1142), .I3(n1141), .O(n1182)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb2cf */ ;
    defparam LUT__2727.LUTMASK = 16'hb2cf;
    EFX_LUT4 LUT__2728 (.I0(\u_sobel/u_core/row [14]), .I1(\u_sobel/hreg [14]), 
            .I2(n1112), .I3(n1117), .O(n1183)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3d4f */ ;
    defparam LUT__2728.LUTMASK = 16'h3d4f;
    EFX_LUT4 LUT__2729 (.I0(n1113), .I1(n1114), .I2(n1124), .I3(\u_sobel/hreg [12]), 
            .O(n1184)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h807f */ ;
    defparam LUT__2729.LUTMASK = 16'h807f;
    EFX_LUT4 LUT__2730 (.I0(\u_sobel/u_core/row [12]), .I1(n1184), .I2(\u_sobel/u_core/row [13]), 
            .I3(\u_sobel/hreg [13]), .O(n1185)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he00e */ ;
    defparam LUT__2730.LUTMASK = 16'he00e;
    EFX_LUT4 LUT__2731 (.I0(n1183), .I1(n1185), .O(n1186)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2731.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2732 (.I0(n1177), .I1(n1181), .I2(n1182), .I3(n1186), 
            .O(n1187)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf400 */ ;
    defparam LUT__2732.LUTMASK = 16'hf400;
    EFX_LUT4 LUT__2733 (.I0(\u_sobel/hreg [4]), .I1(n1113), .I2(\u_sobel/hreg [5]), 
            .I3(\u_sobel/u_core/row [5]), .O(n1188)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4b00 */ ;
    defparam LUT__2733.LUTMASK = 16'h4b00;
    EFX_LUT4 LUT__2734 (.I0(\u_sobel/u_core/row [4]), .I1(\u_sobel/hreg [4]), 
            .I2(n1113), .I3(n1188), .O(n1189)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h007d */ ;
    defparam LUT__2734.LUTMASK = 16'h007d;
    EFX_LUT4 LUT__2735 (.I0(\u_sobel/u_core/row [1]), .I1(\u_sobel/u_core/row [0]), 
            .I2(\u_sobel/hreg [1]), .I3(\u_sobel/hreg [0]), .O(n1190)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__2735.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__2736 (.I0(n1190), .I1(n1127), .I2(\u_sobel/u_core/row [2]), 
            .I3(\u_sobel/hreg [2]), .O(n1191)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__2736.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__2737 (.I0(n1113), .I1(n1121), .O(n1192)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2737.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2738 (.I0(n1191), .I1(\u_sobel/hreg [3]), .I2(\u_sobel/u_core/row [3]), 
            .I3(n1192), .O(n1193)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb200 */ ;
    defparam LUT__2738.LUTMASK = 16'hb200;
    EFX_LUT4 LUT__2739 (.I0(\u_sobel/u_core/row [5]), .I1(\u_sobel/hreg [5]), 
            .O(n1194)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2739.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2740 (.I0(\u_sobel/u_core/row [6]), .I1(\u_sobel/hreg [6]), 
            .I2(n1130), .I3(n1119), .O(n1195)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3d4f */ ;
    defparam LUT__2740.LUTMASK = 16'h3d4f;
    EFX_LUT4 LUT__2741 (.I0(n1193), .I1(n1189), .I2(n1194), .I3(n1195), 
            .O(n1196)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h000b */ ;
    defparam LUT__2741.LUTMASK = 16'h000b;
    EFX_LUT4 LUT__2742 (.I0(\u_sobel/u_core/row [7]), .I1(\u_sobel/hreg [7]), 
            .I2(n1129), .I3(n1134), .O(n1197)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb2cf */ ;
    defparam LUT__2742.LUTMASK = 16'hb2cf;
    EFX_LUT4 LUT__2743 (.I0(n1195), .I1(n1120), .I2(n1197), .O(n1198)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0e0e */ ;
    defparam LUT__2743.LUTMASK = 16'h0e0e;
    EFX_LUT4 LUT__2744 (.I0(\u_sobel/u_core/row [9]), .I1(\u_sobel/hreg [9]), 
            .O(n1199)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2744.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2745 (.I0(\u_sobel/u_core/row [8]), .I1(\u_sobel/hreg [8]), 
            .I2(n1199), .I3(n1135), .O(n1200)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3d4f */ ;
    defparam LUT__2745.LUTMASK = 16'h3d4f;
    EFX_LUT4 LUT__2746 (.I0(n1183), .I1(n1200), .I2(n1180), .I3(n1185), 
            .O(n1201)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2746.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2747 (.I0(\u_sobel/u_core/row [14]), .I1(\u_sobel/hreg [14]), 
            .O(n1202)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;
    defparam LUT__2747.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2748 (.I0(\u_sobel/u_core/row [13]), .I1(\u_sobel/hreg [13]), 
            .I2(n1125), .I3(n1202), .O(n1203)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb2cf */ ;
    defparam LUT__2748.LUTMASK = 16'hb2cf;
    EFX_LUT4 LUT__2749 (.I0(\u_sobel/hreg [14]), .I1(n1117), .I2(\u_sobel/hreg [15]), 
            .I3(\u_sobel/u_core/row [15]), .O(n1204)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4b00 */ ;
    defparam LUT__2749.LUTMASK = 16'h4b00;
    EFX_LUT4 LUT__2750 (.I0(\u_sobel/u_core/row [8]), .I1(\u_sobel/u_core/row [9]), 
            .I2(\u_sobel/u_core/row [10]), .I3(\u_sobel/u_core/row [11]), 
            .O(n1205)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2750.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2751 (.I0(\u_sobel/u_core/row [12]), .I1(\u_sobel/u_core/row [13]), 
            .I2(\u_sobel/u_core/row [14]), .I3(n1205), .O(n1206)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2751.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2752 (.I0(\u_sobel/u_core/row [1]), .I1(\u_sobel/u_core/row [2]), 
            .I2(\u_sobel/u_core/row [3]), .I3(\u_sobel/u_core/row [7]), 
            .O(n1207)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2752.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2753 (.I0(\u_sobel/u_core/row [4]), .I1(\u_sobel/u_core/row [5]), 
            .I2(\u_sobel/u_core/row [6]), .I3(\u_sobel/u_core/row [15]), 
            .O(n1208)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2753.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2754 (.I0(\u_sobel/u_core/col [1]), .I1(\u_sobel/u_core/col [2]), 
            .I2(\u_sobel/u_core/col [7]), .I3(\u_sobel/u_core/col [8]), 
            .O(n1209)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2754.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2755 (.I0(\u_sobel/u_core/col [3]), .I1(\u_sobel/u_core/col [4]), 
            .I2(\u_sobel/u_core/col [5]), .I3(\u_sobel/u_core/col [6]), 
            .O(n1210)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2755.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2756 (.I0(\u_sobel/u_core/col [9]), .I1(n1209), .I2(n1210), 
            .O(n1211)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;
    defparam LUT__2756.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2757 (.I0(n1207), .I1(n1208), .I2(n1206), .I3(n1211), 
            .O(n1212)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h007f */ ;
    defparam LUT__2757.LUTMASK = 16'h007f;
    EFX_LUT4 LUT__2758 (.I0(n1203), .I1(n1183), .I2(n1204), .I3(n1212), 
            .O(n1213)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;
    defparam LUT__2758.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2759 (.I0(n1196), .I1(n1198), .I2(n1201), .I3(n1213), 
            .O(n1214)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f00 */ ;
    defparam LUT__2759.LUTMASK = 16'h4f00;
    EFX_LUT4 LUT__2760 (.I0(n1176), .I1(n1187_q), .I2(n1214_q), .O(\u_sobel/u_core/n241 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2760.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2761 (.I0(\u_sobel/u_core/n199 ), .I1(\u_sobel/u_core/n1144 ), 
            .O(\u_sobel/u_core/n1637 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(136)
    defparam LUT__2761.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2762 (.I0(\u_sobel/wreg [0]), .I1(\u_sobel/wreg [1]), 
            .I2(\u_sobel/wreg [2]), .O(\u_sobel/n1141 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he1e1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2762.LUTMASK = 16'he1e1;
    EFX_LUT4 LUT__2763 (.I0(\u_sobel/wreg [0]), .I1(\u_sobel/wreg [1]), 
            .O(\u_sobel/n1136 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2763.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2764 (.I0(\u_sobel/u_core/st [0]), .I1(\u_sobel/u_core/st [1]), 
            .I2(\u_sobel/u_core/n199 ), .O(n1215)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__2764.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2765 (.I0(rx_seen), .I1(\u_sobel/in_frame ), .I2(n1110), 
            .I3(n1215), .O(ceg_net27)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf8ff */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(78)
    defparam LUT__2765.LUTMASK = 16'hf8ff;
    EFX_LUT4 LUT__2766 (.I0(n1158), .I1(\u_sobel/u_core/n1144 ), .O(\u_sobel/u_core/n1543 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2766.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2767 (.I0(\u_sobel/u_core/skip [0]), .I1(\u_sobel/wreg [0]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2767.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2768 (.I0(\u_sobel/u_core/skip [8]), .I1(\u_sobel/u_core/skip [9]), 
            .O(n1216)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2768.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2769 (.I0(\u_sobel/u_core/skip [4]), .I1(\u_sobel/u_core/skip [5]), 
            .I2(\u_sobel/u_core/skip [6]), .I3(\u_sobel/u_core/skip [7]), 
            .O(n1217)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2769.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2770 (.I0(\u_sobel/u_core/skip [0]), .I1(\u_sobel/u_core/skip [1]), 
            .I2(\u_sobel/u_core/skip [2]), .I3(\u_sobel/u_core/skip [3]), 
            .O(n1218)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2770.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2771 (.I0(\u_sobel/u_core/skip [10]), .I1(n1216), .I2(n1217), 
            .I3(n1218), .O(\u_sobel/u_core/not_equal_40/n31 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbfff */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam LUT__2771.LUTMASK = 16'hbfff;
    EFX_LUT4 LUT__2772 (.I0(\u_sobel/u_core/not_equal_40/n31 ), .I1(\u_sobel/u_core/n1144 ), 
            .I2(\u_sobel/u_core/n199 ), .O(ceg_net10)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0707 */ ;
    defparam LUT__2772.LUTMASK = 16'h0707;
    EFX_LUT4 LUT__2773 (.I0(\u_sobel/u_core/st [1]), .I1(\u_sobel/u_core/n199 ), 
            .I2(\u_sobel/u_core/st [0]), .O(n461)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2773.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2774 (.I0(\u_sobel/u_core/n199 ), .I1(\u_sobel/u_core/st [1]), 
            .O(\u_sobel/u_core/n1655 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2774.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2775 (.I0(\u_sobel/u_core/st [0]), .I1(\u_sobel/u_core/n1655 ), 
            .O(\u_sobel/u_core/n1827 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbbbb */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(136)
    defparam LUT__2775.LUTMASK = 16'hbbbb;
    EFX_LUT4 LUT__2776 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [0]), 
            .O(\u_sobel/pix [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2776.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2777 (.I0(rx_seen), .I1(\u_sobel/in_frame ), .I2(n1110), 
            .I3(n1215), .O(\u_sobel/u_core/n1633 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf800 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(97)
    defparam LUT__2777.LUTMASK = 16'hf800;
    EFX_LUT4 LUT__2778 (.I0(\u_sobel/u_core/row [0]), .I1(\u_sobel/u_core/row [1]), 
            .O(\u_sobel/u_core/n1014 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2778.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2779 (.I0(\u_sobel/u_core/row [0]), .I1(\u_sobel/u_core/row [1]), 
            .I2(\u_sobel/u_core/row [2]), .O(\u_sobel/u_core/n1019 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2779.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__2780 (.I0(\u_sobel/u_core/row [0]), .I1(\u_sobel/u_core/row [1]), 
            .I2(\u_sobel/u_core/row [2]), .I3(\u_sobel/u_core/row [3]), 
            .O(\u_sobel/u_core/n1024 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7f80 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2780.LUTMASK = 16'h7f80;
    EFX_LUT4 LUT__2781 (.I0(\u_sobel/u_core/row [0]), .I1(\u_sobel/u_core/row [1]), 
            .I2(\u_sobel/u_core/row [2]), .I3(\u_sobel/u_core/row [3]), 
            .O(n1219)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2781.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2782 (.I0(\u_sobel/u_core/row [4]), .I1(n1219), .O(\u_sobel/u_core/n1029 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2782.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2783 (.I0(\u_sobel/u_core/row [4]), .I1(n1219), .I2(\u_sobel/u_core/row [5]), 
            .O(\u_sobel/u_core/n1034 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2783.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__2784 (.I0(\u_sobel/u_core/row [4]), .I1(\u_sobel/u_core/row [5]), 
            .I2(n1219), .O(n1220)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2784.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2785 (.I0(\u_sobel/u_core/row [6]), .I1(n1220), .O(\u_sobel/u_core/n1039 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2785.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2786 (.I0(\u_sobel/u_core/row [6]), .I1(n1220), .I2(\u_sobel/u_core/row [7]), 
            .O(\u_sobel/u_core/n1044 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2786.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__2787 (.I0(\u_sobel/u_core/row [6]), .I1(\u_sobel/u_core/row [7]), 
            .I2(n1220), .O(n1221)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2787.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2788 (.I0(\u_sobel/u_core/row [8]), .I1(n1221), .O(\u_sobel/u_core/n1049 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2788.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2789 (.I0(\u_sobel/u_core/row [8]), .I1(n1221), .I2(\u_sobel/u_core/row [9]), 
            .O(\u_sobel/u_core/n1054 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2789.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__2790 (.I0(\u_sobel/u_core/row [8]), .I1(\u_sobel/u_core/row [9]), 
            .I2(n1221), .O(n1222)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2790.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2791 (.I0(\u_sobel/u_core/row [10]), .I1(n1222), .O(\u_sobel/u_core/n1059 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2791.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2792 (.I0(\u_sobel/u_core/row [10]), .I1(n1222), .I2(\u_sobel/u_core/row [11]), 
            .O(\u_sobel/u_core/n1064 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2792.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__2793 (.I0(\u_sobel/u_core/row [10]), .I1(\u_sobel/u_core/row [11]), 
            .I2(n1222), .I3(\u_sobel/u_core/row [12]), .O(\u_sobel/u_core/n1069 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7f80 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2793.LUTMASK = 16'h7f80;
    EFX_LUT4 LUT__2794 (.I0(\u_sobel/u_core/row [10]), .I1(\u_sobel/u_core/row [11]), 
            .I2(\u_sobel/u_core/row [12]), .I3(n1222), .O(n1223)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2794.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2795 (.I0(\u_sobel/u_core/row [13]), .I1(n1223), .O(\u_sobel/u_core/n1074 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2795.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2796 (.I0(\u_sobel/u_core/row [13]), .I1(n1223), .I2(\u_sobel/u_core/row [14]), 
            .O(\u_sobel/u_core/n1079 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2796.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__2797 (.I0(\u_sobel/u_core/row [13]), .I1(\u_sobel/u_core/row [14]), 
            .I2(n1223), .I3(\u_sobel/u_core/row [15]), .O(\u_sobel/u_core/n1084 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7f80 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(198)
    defparam LUT__2797.LUTMASK = 16'h7f80;
    EFX_LUT4 LUT__2798 (.I0(\u_sobel/n1136 ), .I1(\u_sobel/u_core/n252 [1]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5c5c */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2798.LUTMASK = 16'h5c5c;
    EFX_LUT4 LUT__2799 (.I0(\u_sobel/n240 [2]), .I1(\u_sobel/u_core/n252 [2]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2799.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2800 (.I0(\u_sobel/n240 [3]), .I1(\u_sobel/u_core/n252 [3]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2800.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2801 (.I0(\u_sobel/n240 [4]), .I1(\u_sobel/u_core/n252 [4]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2801.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2802 (.I0(\u_sobel/n240 [5]), .I1(\u_sobel/u_core/n252 [5]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2802.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2803 (.I0(\u_sobel/n240 [6]), .I1(\u_sobel/u_core/n252 [6]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2803.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2804 (.I0(\u_sobel/n240 [7]), .I1(\u_sobel/u_core/n252 [7]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2804.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2805 (.I0(\u_sobel/n240 [8]), .I1(\u_sobel/u_core/n252 [8]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2805.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2806 (.I0(\u_sobel/u_core/n201 [8]), .I1(\u_sobel/u_core/n252 [9]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2806.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2807 (.I0(\u_sobel/u_core/n200 ), .I1(\u_sobel/u_core/n252 [10]), 
            .I2(\u_sobel/u_core/n199 ), .O(\u_sobel/u_core/n542 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(137)
    defparam LUT__2807.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2808 (.I0(n1158), .I1(\u_sobel/u_core/col [0]), .I2(\u_sobel/u_core/col [1]), 
            .O(\u_sobel/u_core/n317 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2808.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2809 (.I0(\u_sobel/u_core/col [0]), .I1(\u_sobel/u_core/col [1]), 
            .O(n1224)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2809.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2810 (.I0(n1158), .I1(\u_sobel/u_core/col [2]), .I2(n1224), 
            .O(\u_sobel/u_core/n317 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2810.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2811 (.I0(\u_sobel/u_core/col [2]), .I1(n1224), .I2(n1158), 
            .I3(\u_sobel/u_core/col [3]), .O(\u_sobel/u_core/n317 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0708 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2811.LUTMASK = 16'h0708;
    EFX_LUT4 LUT__2812 (.I0(\u_sobel/u_core/col [2]), .I1(\u_sobel/u_core/col [3]), 
            .I2(n1224), .O(n1225)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2812.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2813 (.I0(n1158), .I1(\u_sobel/u_core/col [4]), .I2(n1225), 
            .O(\u_sobel/u_core/n317 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2813.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2814 (.I0(\u_sobel/u_core/col [4]), .I1(n1225), .O(n1226)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2814.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2815 (.I0(n1158), .I1(\u_sobel/u_core/col [5]), .I2(n1226), 
            .O(\u_sobel/u_core/n317 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2815.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2816 (.I0(\u_sobel/u_core/col [5]), .I1(n1226), .I2(n1158), 
            .I3(\u_sobel/u_core/col [6]), .O(\u_sobel/u_core/n317 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0708 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2816.LUTMASK = 16'h0708;
    EFX_LUT4 LUT__2817 (.I0(\u_sobel/u_core/col [5]), .I1(\u_sobel/u_core/col [6]), 
            .I2(n1226), .O(n1227)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2817.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2818 (.I0(n1158), .I1(\u_sobel/u_core/col [7]), .I2(n1227), 
            .O(\u_sobel/u_core/n317 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2818.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2819 (.I0(\u_sobel/u_core/col [7]), .I1(n1227), .O(n1228)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2819.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2820 (.I0(n1158), .I1(\u_sobel/u_core/col [8]), .I2(n1228), 
            .O(\u_sobel/u_core/n317 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2820.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2821 (.I0(\u_sobel/u_core/col [8]), .I1(n1228), .I2(n1158), 
            .I3(\u_sobel/u_core/col [9]), .O(\u_sobel/u_core/n317 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0708 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(132)
    defparam LUT__2821.LUTMASK = 16'h0708;
    EFX_LUT4 LUT__2822 (.I0(n1176), .I1(\u_sobel/u_core/sum [1]), .I2(n1187_q), 
            .I3(n1214_q), .O(\u_sobel/u_core/n241 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2822.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2823 (.I0(n1176), .I1(\u_sobel/u_core/sum [2]), .I2(n1187_q), 
            .I3(n1214_q), .O(\u_sobel/u_core/n241 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2823.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2824 (.I0(n1176), .I1(\u_sobel/u_core/sum [3]), .I2(n1187_q), 
            .I3(n1214_q), .O(\u_sobel/u_core/n241 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2824.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2825 (.I0(n1176), .I1(\u_sobel/u_core/sum [4]), .I2(n1187_q), 
            .I3(n1214_q), .O(\u_sobel/u_core/n241 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2825.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2826 (.I0(n1176), .I1(\u_sobel/u_core/sum [5]), .I2(n1187_q), 
            .I3(n1214_q), .O(\u_sobel/u_core/n241 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2826.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2827 (.I0(n1176), .I1(\u_sobel/u_core/sum [6]), .I2(n1187_q), 
            .I3(n1214_q), .O(\u_sobel/u_core/n241 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2827.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2828 (.I0(n1176), .I1(\u_sobel/u_core/sum [7]), .I2(n1187_q), 
            .I3(n1214_q), .O(\u_sobel/u_core/n241 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d00 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(121)
    defparam LUT__2828.LUTMASK = 16'h0d00;
    EFX_LUT4 LUT__2829 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [1]), 
            .O(\u_sobel/pix [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2829.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2830 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [2]), 
            .O(\u_sobel/pix [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2830.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2831 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [3]), 
            .O(\u_sobel/pix [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2831.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2832 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [4]), 
            .O(\u_sobel/pix [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2832.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2833 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [5]), 
            .O(\u_sobel/pix [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2833.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2834 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [6]), 
            .O(\u_sobel/pix [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2834.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2835 (.I0(\u_sobel/flushing ), .I1(\u_sobel/rx_data [7]), 
            .O(\u_sobel/pix [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(80)
    defparam LUT__2835.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2836 (.I0(\u_sobel/u_core/st [0]), .I1(\u_sobel/u_core/st [1]), 
            .O(\u_sobel/u_core/n400 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(136)
    defparam LUT__2836.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2837 (.I0(\u_sobel/wreg [8]), .I1(n1151), .I2(\u_sobel/wreg [9]), 
            .O(\u_sobel/n1176 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2837.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__2838 (.I0(\u_sobel/wreg [8]), .I1(n1151), .O(\u_sobel/n1171 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2838.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2839 (.I0(n1151), .I1(n1160), .O(\u_sobel/n1166 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2839.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2840 (.I0(\u_sobel/wreg [6]), .I1(n1147), .O(\u_sobel/n1161 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2840.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2841 (.I0(\u_sobel/u_core/pl [2]), .I1(\u_sobel/u_core/pr [2]), 
            .O(n1229)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2841.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2842 (.I0(\u_sobel/u_core/pr [1]), .I1(\u_sobel/u_core/pr [0]), 
            .I2(\u_sobel/u_core/pl [1]), .I3(\u_sobel/u_core/pl [0]), .O(n1230)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__2842.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__2843 (.I0(\u_sobel/u_core/pr [4]), .I1(\u_sobel/u_core/pl [4]), 
            .O(n1231)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2843.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2844 (.I0(\u_sobel/u_core/pr [2]), .I1(\u_sobel/u_core/pl [2]), 
            .I2(\u_sobel/u_core/pr [3]), .I3(\u_sobel/u_core/pl [3]), .O(n1232)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__2844.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__2845 (.I0(n1230), .I1(n1229), .I2(n1231), .I3(n1232), 
            .O(n1233)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0e00 */ ;
    defparam LUT__2845.LUTMASK = 16'h0e00;
    EFX_LUT4 LUT__2846 (.I0(\u_sobel/u_core/pr [4]), .I1(\u_sobel/u_core/pl [4]), 
            .I2(\u_sobel/u_core/pl [3]), .I3(\u_sobel/u_core/pr [3]), .O(n1234)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hd4dd */ ;
    defparam LUT__2846.LUTMASK = 16'hd4dd;
    EFX_LUT4 LUT__2847 (.I0(\u_sobel/u_core/pr [5]), .I1(n1233), .I2(\u_sobel/u_core/pl [5]), 
            .I3(n1234), .O(n1235)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__2847.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__2848 (.I0(\u_sobel/u_core/pl [6]), .I1(\u_sobel/u_core/pr [6]), 
            .O(n1236)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2848.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2849 (.I0(\u_sobel/u_core/pr [8]), .I1(\u_sobel/u_core/pl [8]), 
            .I2(\u_sobel/u_core/pl [7]), .I3(\u_sobel/u_core/pr [7]), .O(n1237)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hd4dd */ ;
    defparam LUT__2849.LUTMASK = 16'hd4dd;
    EFX_LUT4 LUT__2850 (.I0(\u_sobel/u_core/pr [7]), .I1(\u_sobel/u_core/pr [6]), 
            .I2(\u_sobel/u_core/pl [7]), .I3(\u_sobel/u_core/pl [6]), .O(n1238)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__2850.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__2851 (.I0(\u_sobel/u_core/pr [8]), .I1(\u_sobel/u_core/pl [8]), 
            .I2(n1238), .O(n1239)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb2b2 */ ;
    defparam LUT__2851.LUTMASK = 16'hb2b2;
    EFX_LUT4 LUT__2852 (.I0(n1236), .I1(n1235), .I2(n1237), .I3(n1239), 
            .O(n1240)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hef00 */ ;
    defparam LUT__2852.LUTMASK = 16'hef00;
    EFX_LUT4 LUT__2853 (.I0(\u_sobel/u_core/pr [9]), .I1(n1240), .I2(\u_sobel/u_core/pl [9]), 
            .O(n1241)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7171 */ ;
    defparam LUT__2853.LUTMASK = 16'h7171;
    EFX_LUT4 LUT__2854 (.I0(\u_sobel/u_core/sub_17/add_2/n20_q ), .I1(n1241_q), 
            .O(\u_sobel/u_core/ax [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2854.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2855 (.I0(\u_sobel/u_core/pb [1]), .I1(\u_sobel/u_core/pb [0]), 
            .I2(\u_sobel/u_core/pt [1]), .I3(\u_sobel/u_core/ay [0]), .O(n1242)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__2855.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__2856 (.I0(\u_sobel/u_core/pb [2]), .I1(\u_sobel/u_core/pt [2]), 
            .I2(\u_sobel/u_core/pb [4]), .I3(\u_sobel/u_core/pt [4]), .O(n1243)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__2856.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__2857 (.I0(\u_sobel/u_core/pb [3]), .I1(\u_sobel/u_core/pt [3]), 
            .O(n1244)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2857.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2858 (.I0(\u_sobel/u_core/pt [2]), .I1(\u_sobel/u_core/pb [2]), 
            .I2(\u_sobel/u_core/pt [3]), .I3(\u_sobel/u_core/pb [3]), .O(n1245)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__2858.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__2859 (.I0(\u_sobel/u_core/pb [4]), .I1(\u_sobel/u_core/pt [4]), 
            .I2(n1244), .I3(n1245), .O(n1246)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hddd4 */ ;
    defparam LUT__2859.LUTMASK = 16'hddd4;
    EFX_LUT4 LUT__2860 (.I0(n1244), .I1(n1243), .I2(n1242), .I3(n1246), 
            .O(n1247)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbf00 */ ;
    defparam LUT__2860.LUTMASK = 16'hbf00;
    EFX_LUT4 LUT__2861 (.I0(\u_sobel/u_core/pb [6]), .I1(\u_sobel/u_core/pt [6]), 
            .I2(\u_sobel/u_core/pb [7]), .I3(\u_sobel/u_core/pt [7]), .O(n1248)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__2861.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__2862 (.I0(\u_sobel/u_core/pt [8]), .I1(\u_sobel/u_core/pb [8]), 
            .I2(n1248), .O(n1249)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hd0d0 */ ;
    defparam LUT__2862.LUTMASK = 16'hd0d0;
    EFX_LUT4 LUT__2863 (.I0(\u_sobel/u_core/pb [5]), .I1(\u_sobel/u_core/pt [5]), 
            .I2(n1247), .I3(n1249), .O(n1250)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h2b00 */ ;
    defparam LUT__2863.LUTMASK = 16'h2b00;
    EFX_LUT4 LUT__2864 (.I0(\u_sobel/u_core/pb [7]), .I1(\u_sobel/u_core/pt [7]), 
            .I2(\u_sobel/u_core/pt [6]), .I3(\u_sobel/u_core/pb [6]), .O(n1251)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hd4dd */ ;
    defparam LUT__2864.LUTMASK = 16'hd4dd;
    EFX_LUT4 LUT__2865 (.I0(\u_sobel/u_core/pb [8]), .I1(\u_sobel/u_core/pt [8]), 
            .I2(n1251), .O(n1252)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hd4d4 */ ;
    defparam LUT__2865.LUTMASK = 16'hd4d4;
    EFX_LUT4 LUT__2866 (.I0(\u_sobel/u_core/pb [9]), .I1(n1250), .I2(\u_sobel/u_core/pt [9]), 
            .I3(n1252), .O(n1253)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__2866.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__2867 (.I0(\u_sobel/u_core/sub_21/add_2/n20_q ), .I1(n1253_q), 
            .O(\u_sobel/u_core/ay [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2867.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2868 (.I0(\u_sobel/u_core/n97_q [9]), .I1(\u_sobel/u_core/n109_q [9]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2868.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2869 (.I0(\u_sobel/u_core/n134_q [9]), .I1(\u_sobel/u_core/n146_q [9]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2869.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2870 (.I0(\u_sobel/u_core/n97_q [8]), .I1(\u_sobel/u_core/n109_q [8]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2870.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2871 (.I0(\u_sobel/u_core/n134_q [8]), .I1(\u_sobel/u_core/n146_q [8]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2871.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2872 (.I0(\u_sobel/u_core/n97_q [7]), .I1(\u_sobel/u_core/n109_q [7]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2872.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2873 (.I0(\u_sobel/u_core/n134_q [7]), .I1(\u_sobel/u_core/n146_q [7]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2873.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2874 (.I0(\u_sobel/u_core/n97_q [6]), .I1(\u_sobel/u_core/n109_q [6]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2874.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2875 (.I0(\u_sobel/u_core/n134_q [6]), .I1(\u_sobel/u_core/n146_q [6]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2875.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2876 (.I0(\u_sobel/u_core/n97_q [5]), .I1(\u_sobel/u_core/n109_q [5]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2876.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2877 (.I0(\u_sobel/u_core/n134_q [5]), .I1(\u_sobel/u_core/n146_q [5]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2877.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2878 (.I0(\u_sobel/u_core/n97_q [4]), .I1(\u_sobel/u_core/n109_q [4]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2878.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2879 (.I0(\u_sobel/u_core/n134_q [4]), .I1(\u_sobel/u_core/n146_q [4]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2879.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2880 (.I0(\u_sobel/u_core/n97_q [3]), .I1(\u_sobel/u_core/n109_q [3]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2880.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2881 (.I0(\u_sobel/u_core/n134_q [3]), .I1(\u_sobel/u_core/n146_q [3]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2881.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2882 (.I0(\u_sobel/u_core/n97_q [2]), .I1(\u_sobel/u_core/n109_q [2]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2882.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2883 (.I0(\u_sobel/u_core/n134_q [2]), .I1(\u_sobel/u_core/n146_q [2]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2883.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2884 (.I0(\u_sobel/u_core/n97_q [1]), .I1(\u_sobel/u_core/n109_q [1]), 
            .I2(n1241_q), .O(\u_sobel/u_core/ax [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam LUT__2884.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2885 (.I0(\u_sobel/u_core/n134_q [1]), .I1(\u_sobel/u_core/n146_q [1]), 
            .I2(n1253_q), .O(\u_sobel/u_core/ay [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam LUT__2885.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2886 (.I0(\u_sobel/u_rx/cnt [0]), .I1(\u_sobel/u_rx/cnt [2]), 
            .I2(\u_sobel/u_rx/cnt [1]), .I3(\u_sobel/u_rx/cnt [3]), .O(n1254)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2886.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2887 (.I0(\u_sobel/u_rx/cnt [4]), .I1(n1254), .O(n1255)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2887.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2888 (.I0(\u_sobel/u_rx/st [1]), .I1(n1255), .O(n1256)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2888.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2889 (.I0(\u_sobel/u_rx/bi [2]), .I1(\u_sobel/u_rx/bi [0]), 
            .I2(\u_sobel/u_rx/bi [1]), .I3(\u_sobel/u_rx/st [0]), .O(n1257)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h007f */ ;
    defparam LUT__2889.LUTMASK = 16'h007f;
    EFX_LUT4 LUT__2890 (.I0(\u_sobel/u_rx/cnt [0]), .I1(\u_sobel/u_rx/cnt [4]), 
            .I2(\u_sobel/u_rx/st [1]), .I3(\u_sobel/u_rx/cnt [3]), .O(n1258)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2890.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2891 (.I0(\u_sobel/u_rx/cnt [1]), .I1(\u_sobel/u_rx/cnt [2]), 
            .I2(n1258), .O(n1259)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;
    defparam LUT__2891.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2892 (.I0(\u_sobel/u_rx/st [1]), .I1(\u_sobel/u_rx/sy[1] ), 
            .I2(n1259), .I3(\u_sobel/u_rx/st [0]), .O(n1260)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0fbb */ ;
    defparam LUT__2892.LUTMASK = 16'h0fbb;
    EFX_LUT4 LUT__2893 (.I0(n1257), .I1(n1256), .I2(rst), .I3(n1260), 
            .O(ceg_net69)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf4ff */ ;
    defparam LUT__2893.LUTMASK = 16'hf4ff;
    EFX_LUT4 LUT__2894 (.I0(rst), .I1(\u_sobel/u_rx/st [0]), .I2(n1256), 
            .O(\u_sobel/u_rx/n393 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(83)
    defparam LUT__2894.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2895 (.I0(\u_sobel/u_rx/bi [0]), .I1(\u_sobel/u_rx/st [1]), 
            .O(\u_sobel/u_rx/n134 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2895.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2896 (.I0(n1256), .I1(n1259), .I2(rst), .I3(\u_sobel/u_rx/st [0]), 
            .O(ceg_net53)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf3f5 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(23)
    defparam LUT__2896.LUTMASK = 16'hf3f5;
    EFX_LUT4 LUT__2897 (.I0(n1255), .I1(\u_sobel/u_rx/st [1]), .I2(n1259), 
            .I3(\u_sobel/u_rx/st [0]), .O(n1261)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__2897.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__2898 (.I0(\u_sobel/u_rx/cnt [0]), .I1(n1261), .O(\u_sobel/u_rx/n119 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2898.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2899 (.I0(\u_sobel/u_rx/sy[1] ), .I1(n1255), .I2(\u_sobel/u_rx/st [1]), 
            .I3(\u_sobel/u_rx/st [0]), .O(n1262)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3ffa */ ;
    defparam LUT__2899.LUTMASK = 16'h3ffa;
    EFX_LUT4 LUT__2900 (.I0(rst), .I1(n1262), .O(ceg_net51)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbbbb */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(23)
    defparam LUT__2900.LUTMASK = 16'hbbbb;
    EFX_LUT4 LUT__2901 (.I0(\u_sobel/u_rx/st [0]), .I1(rst), .I2(n1256), 
            .O(\u_sobel/u_rx/n445 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(189)
    defparam LUT__2901.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2902 (.I0(n1261), .I1(\u_sobel/u_rx/cnt [0]), .I2(\u_sobel/u_rx/cnt [1]), 
            .O(\u_sobel/u_rx/n119 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2902.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2903 (.I0(\u_sobel/u_rx/cnt [0]), .I1(\u_sobel/u_rx/cnt [1]), 
            .I2(\u_sobel/u_rx/cnt [2]), .O(n1263)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8787 */ ;
    defparam LUT__2903.LUTMASK = 16'h8787;
    EFX_LUT4 LUT__2904 (.I0(\u_sobel/u_rx/st [1]), .I1(\u_sobel/u_rx/st [0]), 
            .I2(n1259), .I3(n1263), .O(\u_sobel/u_rx/n119 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h000e */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2904.LUTMASK = 16'h000e;
    EFX_LUT4 LUT__2905 (.I0(\u_sobel/u_rx/cnt [0]), .I1(\u_sobel/u_rx/cnt [1]), 
            .I2(\u_sobel/u_rx/cnt [2]), .O(n1264)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2905.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2906 (.I0(n1261), .I1(\u_sobel/u_rx/cnt [3]), .I2(n1264), 
            .O(\u_sobel/u_rx/n119 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2906.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2907 (.I0(\u_sobel/u_rx/cnt [3]), .I1(n1264), .I2(n1261), 
            .I3(\u_sobel/u_rx/cnt [4]), .O(\u_sobel/u_rx/n119 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0708 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2907.LUTMASK = 16'h0708;
    EFX_LUT4 LUT__2908 (.I0(\u_sobel/u_rx/bi [0]), .I1(\u_sobel/u_rx/bi [1]), 
            .I2(\u_sobel/u_rx/st [1]), .O(\u_sobel/u_rx/n134 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6060 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2908.LUTMASK = 16'h6060;
    EFX_LUT4 LUT__2909 (.I0(\u_sobel/u_rx/bi [0]), .I1(\u_sobel/u_rx/bi [1]), 
            .I2(\u_sobel/u_rx/bi [2]), .I3(\u_sobel/u_rx/st [1]), .O(\u_sobel/u_rx/n134 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7800 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2909.LUTMASK = 16'h7800;
    EFX_LUT4 LUT__2910 (.I0(\u_sobel/u_rx/sy[1] ), .I1(\u_sobel/u_rx/st [1]), 
            .I2(\u_sobel/u_rx/st [0]), .O(\u_sobel/u_rx/n116 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h2c2c */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_rx.v(84)
    defparam LUT__2910.LUTMASK = 16'h2c2c;
    EFX_LUT4 LUT__2911 (.I0(\u_sobel/n698 ), .I1(\u_sobel/u_tx/sh [3]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2911.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2912 (.I0(\u_sobel/u_tx/cnt [0]), .I1(\u_sobel/u_tx/cnt [2]), 
            .I2(\u_sobel/u_tx/cnt [1]), .I3(\u_sobel/u_tx/cnt [3]), .O(n1265)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2912.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2913 (.I0(n1265), .I1(\u_sobel/u_tx/cnt [4]), .I2(n1172), 
            .O(n1266)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0707 */ ;
    defparam LUT__2913.LUTMASK = 16'h0707;
    EFX_LUT4 LUT__2914 (.I0(\u_sobel/pop ), .I1(n1172), .I2(rst), .O(ceg_net35)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf4f4 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(23)
    defparam LUT__2914.LUTMASK = 16'hf4f4;
    EFX_LUT4 LUT__2915 (.I0(n1266), .I1(ceg_net35), .O(\~ceg_net54 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2915.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2916 (.I0(\u_sobel/n699 ), .I1(\u_sobel/u_tx/sh [2]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2916.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2917 (.I0(\u_sobel/u_tx/left [0]), .I1(n1172), .O(\u_sobel/u_tx/n76 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2917.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2918 (.I0(\u_sobel/pop ), .I1(n1172), .I2(n1266), .I3(rst), 
            .O(ceg_net57)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hff0b */ ;
    defparam LUT__2918.LUTMASK = 16'hff0b;
    EFX_LUT4 LUT__2919 (.I0(n1172), .I1(\u_sobel/u_tx/sh [1]), .O(\u_sobel/u_tx/n65 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2919.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2920 (.I0(\u_sobel/u_tx/cnt [0]), .I1(n1266), .O(\u_sobel/u_tx/n81 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(60)
    defparam LUT__2920.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2921 (.I0(\u_sobel/n697 ), .I1(\u_sobel/u_tx/sh [4]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2921.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2922 (.I0(rst), .I1(n1172), .O(\u_sobel/u_tx/n156 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2922.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2923 (.I0(\u_sobel/n696 ), .I1(\u_sobel/u_tx/sh [5]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2923.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2924 (.I0(\u_sobel/n695 ), .I1(\u_sobel/u_tx/sh [6]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2924.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2925 (.I0(\u_sobel/n694 ), .I1(\u_sobel/u_tx/sh [7]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2925.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2926 (.I0(\u_sobel/n693 ), .I1(\u_sobel/u_tx/sh [8]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2926.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2927 (.I0(\u_sobel/n692 ), .I1(\u_sobel/u_tx/sh [9]), 
            .I2(n1172), .O(\u_sobel/u_tx/n65 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hacac */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2927.LUTMASK = 16'hacac;
    EFX_LUT4 LUT__2928 (.I0(\u_sobel/u_tx/cnt [0]), .I1(\u_sobel/u_tx/cnt [1]), 
            .I2(n1266), .O(\u_sobel/u_tx/n81 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6060 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(60)
    defparam LUT__2928.LUTMASK = 16'h6060;
    EFX_LUT4 LUT__2929 (.I0(\u_sobel/u_tx/cnt [0]), .I1(\u_sobel/u_tx/cnt [1]), 
            .O(n1267)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2929.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2930 (.I0(n1172), .I1(\u_sobel/u_tx/cnt [2]), .I2(n1267), 
            .O(\u_sobel/u_tx/n81 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(60)
    defparam LUT__2930.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2931 (.I0(\u_sobel/u_tx/cnt [2]), .I1(n1267), .I2(\u_sobel/u_tx/cnt [3]), 
            .I3(n1266), .O(\u_sobel/u_tx/n81 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7800 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(60)
    defparam LUT__2931.LUTMASK = 16'h7800;
    EFX_LUT4 LUT__2932 (.I0(\u_sobel/u_tx/cnt [2]), .I1(\u_sobel/u_tx/cnt [3]), 
            .I2(n1267), .O(n1268)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2932.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2933 (.I0(\u_sobel/u_tx/cnt [4]), .I1(n1268), .I2(n1266), 
            .O(\u_sobel/u_tx/n81 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6060 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(60)
    defparam LUT__2933.LUTMASK = 16'h6060;
    EFX_LUT4 LUT__2934 (.I0(\u_sobel/u_tx/left [0]), .I1(\u_sobel/u_tx/left [1]), 
            .O(\u_sobel/u_tx/n186 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(213)
    defparam LUT__2934.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2935 (.I0(\u_sobel/u_tx/left [3]), .I1(\u_sobel/u_tx/left [0]), 
            .I2(\u_sobel/u_tx/left [1]), .I3(\u_sobel/u_tx/left [2]), .O(\u_sobel/u_tx/n76 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hfc02 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\uart_tx.v(61)
    defparam LUT__2935.LUTMASK = 16'hfc02;
    EFX_LUT4 LUT__2936 (.I0(\u_sobel/u_tx/left [0]), .I1(\u_sobel/u_tx/left [1]), 
            .I2(\u_sobel/u_tx/left [2]), .I3(\u_sobel/u_tx/left [3]), .O(\u_sobel/u_tx/n196 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hfe01 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(213)
    defparam LUT__2936.LUTMASK = 16'hfe01;
    EFX_LUT4 LUT__2937 (.I0(\u_sobel/n1136 ), .I1(\u_sobel/n276 [1]), .I2(n1110), 
            .O(\u_sobel/n293 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc5c5 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2937.LUTMASK = 16'hc5c5;
    EFX_LUT4 LUT__2938 (.I0(\u_sobel/n240 [2]), .I1(\u_sobel/n276 [2]), 
            .I2(n1110), .O(\u_sobel/n293 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2938.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2939 (.I0(\u_sobel/n240 [3]), .I1(\u_sobel/n276 [3]), 
            .I2(n1110), .O(\u_sobel/n293 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2939.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2940 (.I0(\u_sobel/n240 [4]), .I1(\u_sobel/n276 [4]), 
            .I2(n1110), .O(\u_sobel/n293 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2940.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2941 (.I0(\u_sobel/n240 [5]), .I1(\u_sobel/n276 [5]), 
            .I2(n1110), .O(\u_sobel/n293 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2941.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2942 (.I0(\u_sobel/n240 [6]), .I1(\u_sobel/n276 [6]), 
            .I2(n1110), .O(\u_sobel/n293 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2942.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2943 (.I0(\u_sobel/n240 [7]), .I1(\u_sobel/n276 [7]), 
            .I2(n1110), .O(\u_sobel/n293 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2943.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2944 (.I0(\u_sobel/n240 [8]), .I1(\u_sobel/n276 [8]), 
            .I2(n1110), .O(\u_sobel/n293 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2944.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2945 (.I0(\u_sobel/n240 [9]), .I1(\u_sobel/n276 [9]), 
            .I2(n1110), .O(\u_sobel/n293 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2945.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2946 (.I0(\u_sobel/n240 [10]), .I1(\u_sobel/n276 [10]), 
            .I2(n1110), .O(\u_sobel/n293 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2946.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2947 (.I0(\u_sobel/n240 [11]), .I1(\u_sobel/n276 [11]), 
            .I2(n1110), .O(\u_sobel/n293 [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2947.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2948 (.I0(\u_sobel/n240 [12]), .I1(\u_sobel/n276 [12]), 
            .I2(n1110), .O(\u_sobel/n293 [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2948.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2949 (.I0(\u_sobel/n240 [13]), .I1(\u_sobel/n276 [13]), 
            .I2(n1110), .O(\u_sobel/n293 [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2949.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2950 (.I0(\u_sobel/n240 [14]), .I1(\u_sobel/n276 [14]), 
            .I2(n1110), .O(\u_sobel/n293 [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2950.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2951 (.I0(\u_sobel/n240 [15]), .I1(\u_sobel/n276 [15]), 
            .I2(n1110), .O(\u_sobel/n293 [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam LUT__2951.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2952 (.I0(\u_sobel/n815 ), .I1(\u_sobel/hdr_step ), .I2(n1175), 
            .O(\u_sobel/n890 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4040 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2952.LUTMASK = 16'h4040;
    EFX_LUT4 LUT__2953 (.I0(\u_sobel/n560 ), .I1(\u_sobel/rp [0]), .I2(\u_sobel/pop ), 
            .O(\u_sobel/n615 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1414 */ ;
    defparam LUT__2953.LUTMASK = 16'h1414;
    EFX_LUT4 LUT__2954 (.I0(\u_sobel/rp [0]), .I1(\u_sobel/pop ), .I2(\u_sobel/n560 ), 
            .I3(\u_sobel/rp [1]), .O(\u_sobel/n614 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0708 */ ;
    defparam LUT__2954.LUTMASK = 16'h0708;
    EFX_LUT4 LUT__2955 (.I0(\u_sobel/rp [0]), .I1(\u_sobel/rp [1]), .O(n1269)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2955.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2956 (.I0(\u_sobel/pop ), .I1(n1269), .I2(\u_sobel/n560 ), 
            .I3(\u_sobel/rp [2]), .O(\u_sobel/n613 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0708 */ ;
    defparam LUT__2956.LUTMASK = 16'h0708;
    EFX_LUT4 LUT__2957 (.I0(\u_sobel/rp [2]), .I1(n1269), .O(n1270)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2957.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2958 (.I0(\u_sobel/rp [3]), .I1(n1270), .O(\u_sobel/n925 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2958.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2959 (.I0(\u_sobel/n925 ), .I1(\u_sobel/rp [3]), .I2(\u_sobel/n560 ), 
            .I3(\u_sobel/pop ), .O(\u_sobel/n612 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0a0c */ ;
    defparam LUT__2959.LUTMASK = 16'h0a0c;
    EFX_LUT4 LUT__2960 (.I0(\u_sobel/rp [3]), .I1(n1270), .O(n1271)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2960.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2961 (.I0(\u_sobel/rp [4]), .I1(n1271), .O(\u_sobel/n930 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2961.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2962 (.I0(\u_sobel/n930 ), .I1(\u_sobel/rp [4]), .I2(\u_sobel/n560 ), 
            .I3(\u_sobel/pop ), .O(\u_sobel/n611 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0a0c */ ;
    defparam LUT__2962.LUTMASK = 16'h0a0c;
    EFX_LUT4 LUT__2963 (.I0(\u_sobel/wp [0]), .I1(\u_sobel/wp [1]), .O(\u_sobel/n933 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2963.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2964 (.I0(\u_sobel/wp [0]), .I1(\u_sobel/wp [1]), .O(n1272)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2964.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2965 (.I0(\u_sobel/wp [2]), .I1(n1272), .O(\u_sobel/n940 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2965.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2966 (.I0(\u_sobel/wp [2]), .I1(n1272), .I2(\u_sobel/wp [3]), 
            .O(\u_sobel/n945 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2966.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__2967 (.I0(\u_sobel/wp [2]), .I1(\u_sobel/wp [3]), .I2(n1272), 
            .I3(\u_sobel/wp [4]), .O(\u_sobel/n950 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7f80 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2967.LUTMASK = 16'h7f80;
    EFX_LUT4 LUT__2968 (.I0(\u_sobel/rp [0]), .I1(\u_sobel/rp [1]), .O(\u_sobel/n913 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2968.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2969 (.I0(\u_sobel/rp [2]), .I1(n1269), .O(\u_sobel/n920 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(53)
    defparam LUT__2969.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2970 (.I0(n1170), .I1(n1175), .O(\u_sobel/select_57/Select_1/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(149)
    defparam LUT__2970.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2596 (.I0(done_cnt[5]), .I1(done_cnt[7]), .I2(done_cnt[8]), 
            .I3(done_cnt[9]), .O(n1080)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2596.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2597 (.I0(done_cnt[3]), .I1(done_cnt[4]), .I2(done_cnt[6]), 
            .I3(done_cnt[10]), .O(n1081)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2597.LUTMASK = 16'h0001;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1277)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_16/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1276)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_16/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_16/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_41/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1275)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(125)
    defparam \u_sobel/u_core/sub_41/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_41/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_72/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1274)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(161)
    defparam \u_sobel/sub_72/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_72/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \sub_14/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), .CI(1'b0), 
            .CO(n1273)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(42)
    defparam \sub_14/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \sub_14/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_20/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1278)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_20/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_20/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1279)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_21/add_2/i10__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1280), .O(\u_sobel/u_core/sub_21/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(66)
    defparam \u_sobel/u_core/sub_21/add_2/i10__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_21/add_2/i10__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/sub_17/add_2/i10__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1281), .O(\u_sobel/u_core/sub_17/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(64)
    defparam \u_sobel/u_core/sub_17/add_2/i10__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/sub_17/add_2/i10__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_248/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1282), .O(\u_sobel/u_core/n200 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(87)
    defparam \u_sobel/u_core/add_248/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_248/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_23/i11__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1283), .O(\u_sobel/u_core/sum [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(68)
    defparam \u_sobel/u_core/add_23/i11__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_23/i11__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_7/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1284), .O(\u_sobel/u_core/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(56)
    defparam \u_sobel/u_core/add_7/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_7/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_9/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1285), .O(\u_sobel/u_core/n30 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(58)
    defparam \u_sobel/u_core/add_9/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_9/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_11/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1286), .O(\u_sobel/u_core/n52 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(60)
    defparam \u_sobel/u_core/add_11/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_11/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/u_core/add_13/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1287), .O(\u_sobel/u_core/n74 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(62)
    defparam \u_sobel/u_core/add_13/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \u_sobel/u_core/add_13/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \u_sobel/sub_107/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1288)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_uart_top.v(184)
    defparam \u_sobel/sub_107/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \u_sobel/sub_107/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \sub_18/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), .CI(1'b0), 
            .CO(n1289)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_zen_top.v(44)
    defparam \sub_18/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \sub_18/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_14  (.D(\u_sobel/u_core/ay [0]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/ay_q [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_14 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_14 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_14 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_14 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_14 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_14 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_14 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[0]~FF_rt_1  (.D(n1187), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(n1187_q)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[0]~FF_rt_1 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[0]~FF_rt_1 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[0]~FF_rt_1 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[0]~FF_rt_1 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[0]~FF_rt_1 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[0]~FF_rt_1 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[0]~FF_rt_1 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[5]~FF_rt_2  (.D(n1214), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(n1214_q)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[5]~FF_rt_2 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[5]~FF_rt_2 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[5]~FF_rt_2 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[5]~FF_rt_2 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[5]~FF_rt_2 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[5]~FF_rt_2 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[5]~FF_rt_2 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_45  (.D(\u_sobel/u_core/n109 [9]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_45 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_45 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_45 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_45 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_45 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_45 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_45 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_44  (.D(\u_sobel/u_core/n97 [1]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_44 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_44 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_44 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_44 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_44 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_44 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_44 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_43  (.D(\u_sobel/u_core/n97 [2]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_43 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_43 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_43 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_43 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_43 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_43 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_43 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_42  (.D(\u_sobel/u_core/n97 [3]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_42 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_42 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_42 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_42 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_42 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_42 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_42 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_41  (.D(\u_sobel/u_core/n97 [4]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_41 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_41 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_41 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_41 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_41 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_41 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_41 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_40  (.D(\u_sobel/u_core/n97 [5]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_40 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_40 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_40 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_40 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_40 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_40 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_40 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_39  (.D(\u_sobel/u_core/n97 [6]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_39 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_39 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_39 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_39 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_39 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_39 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_39 .SR_SYNC_PRIORITY = 1'b1;
    EFX_GBUFCE CLKBUF__0 (.CE(1'b1), .I(clk), .O(\clk~O )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_GBUFCE, CE_POLARITY=1'b1 */ ;
    defparam CLKBUF__0.CE_POLARITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_46  (.D(\u_sobel/u_core/n109 [8]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_46 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_46 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_46 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_46 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_46 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_46 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_46 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_47  (.D(\u_sobel/u_core/n109 [7]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_47 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_47 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_47 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_47 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_47 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_47 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_47 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_48  (.D(\u_sobel/u_core/n109 [6]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_48 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_48 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_48 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_48 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_48 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_48 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_48 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_49  (.D(\u_sobel/u_core/n109 [5]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_49 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_49 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_49 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_49 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_49 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_49 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_49 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_50  (.D(\u_sobel/u_core/n109 [4]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_50 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_50 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_50 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_50 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_50 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_50 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_50 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_51  (.D(\u_sobel/u_core/n109 [3]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_51 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_51 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_51 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_51 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_51 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_51 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_51 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_52  (.D(\u_sobel/u_core/n109 [2]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_52 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_52 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_52 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_52 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_52 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_52 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_52 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_53  (.D(\u_sobel/u_core/n109 [1]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n109_q [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_53 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_53 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_53 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_53 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_53 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_53 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_53 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_54  (.D(\u_sobel/u_core/n134 [9]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_54 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_54 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_54 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_54 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_54 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_54 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_54 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_55  (.D(\u_sobel/u_core/n134 [8]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_55 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_55 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_55 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_55 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_55 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_55 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_55 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_56  (.D(\u_sobel/u_core/n134 [7]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_56 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_56 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_56 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_56 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_56 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_56 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_56 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_57  (.D(\u_sobel/u_core/n134 [6]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_57 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_57 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_57 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_57 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_57 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_57 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_57 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_58  (.D(\u_sobel/u_core/n134 [5]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_58 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_58 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_58 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_58 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_58 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_58 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_58 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_59  (.D(\u_sobel/u_core/n134 [4]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_59 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_59 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_59 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_59 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_59 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_59 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_59 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_60  (.D(\u_sobel/u_core/n134 [3]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_60 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_60 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_60 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_60 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_60 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_60 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_60 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_61  (.D(\u_sobel/u_core/n134 [2]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_61 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_61 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_61 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_61 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_61 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_61 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_61 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_62  (.D(\u_sobel/u_core/n134 [1]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n134_q [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_62 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_62 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_62 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_62 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_62 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_62 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_62 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_63  (.D(\u_sobel/u_core/n146 [9]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_63 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_63 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_63 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_63 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_63 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_63 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_63 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_64  (.D(\u_sobel/u_core/n146 [8]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_64 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_64 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_64 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_64 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_64 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_64 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_64 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_65  (.D(\u_sobel/u_core/n146 [7]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_65 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_65 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_65 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_65 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_65 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_65 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_65 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_66  (.D(\u_sobel/u_core/n146 [6]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_66 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_66 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_66 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_66 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_66 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_66 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_66 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_67  (.D(\u_sobel/u_core/n146 [5]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_67 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_67 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_67 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_67 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_67 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_67 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_67 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_68  (.D(\u_sobel/u_core/n146 [4]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_68 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_68 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_68 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_68 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_68 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_68 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_68 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_69  (.D(\u_sobel/u_core/n146 [3]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_69 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_69 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_69 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_69 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_69 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_69 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_69 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_70  (.D(\u_sobel/u_core/n146 [2]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_70 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_70 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_70 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_70 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_70 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_70 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_70 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_71  (.D(\u_sobel/u_core/n146 [1]), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n146_q [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_71 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_71 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_71 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_71 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_71 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_71 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_71 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_72  (.D(\u_sobel/u_core/n97 [9]), .CE(\u_sobel/u_core/n1637 ), 
           .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/n97_q [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_72 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_72 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_72 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_72 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_72 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_72 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_72 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_73  (.D(\u_sobel/u_core/sub_17/add_2/n20 ), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/sub_17/add_2/n20_q )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_73 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_73 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_73 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_73 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_73 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_73 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_73 .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \u_sobel/core_data[1]~FF_rt_74  (.D(\u_sobel/u_core/sub_21/add_2/n20 ), 
           .CE(\u_sobel/u_core/n1637 ), .CLK(\clk~O ), .SR(1'b0), .Q(\u_sobel/u_core/sub_21/add_2/n20_q )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1, INIT_VALUE=1'b0 */ ;   // C:\Users\ayush\Documents\vicharak\zen\examples\image-processing\webcam-sobel\sobel_core.v(138)
    defparam \u_sobel/core_data[1]~FF_rt_74 .CLK_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_74 .CE_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_74 .SR_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_74 .D_POLARITY = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_74 .SR_SYNC = 1'b1;
    defparam \u_sobel/core_data[1]~FF_rt_74 .SR_VALUE = 1'b0;
    defparam \u_sobel/core_data[1]~FF_rt_74 .SR_SYNC_PRIORITY = 1'b1;
    
endmodule

//
// Verific Verilog Description of module EFX_FF_93c84d7a_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_93c84d7a_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_93c84d7a_2
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_93c84d7a_3
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_93c84d7a_4
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_93c84d7a_5
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_93c84d7a_6
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_93c84d7a_7
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_ADD_93c84d7a_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_ADD_93c84d7a_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_RAM_5K_93c84d7a__4_4_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_RAM_5K_93c84d7a__4_4_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_RAM_5K_93c84d7a__4_4_2
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_RAM_5K_93c84d7a__4_4_3
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_RAM_5K_93c84d7a__8_8_4
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_2
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_3
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_4
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_5
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_6
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_7
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_8
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_9
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_10
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_11
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_12
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_13
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_14
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_15
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_16
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_17
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_18
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_19
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_20
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_21
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_22
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_23
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_24
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_25
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_26
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_27
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_28
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_29
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_30
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_31
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_32
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_33
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_34
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_35
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_36
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_37
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_38
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_39
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_40
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_41
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_42
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_43
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_44
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_45
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_46
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_47
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_48
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_49
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_50
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_51
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_52
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_53
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_54
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_55
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_56
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_57
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_58
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_59
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_60
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_61
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_62
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_63
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_64
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_65
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_66
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_67
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_68
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_69
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_70
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_71
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_72
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_73
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_74
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_75
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_76
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_77
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_78
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_79
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_80
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_81
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_82
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_83
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_84
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_85
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_86
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_87
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_93c84d7a_88
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_GBUFCE_93c84d7a_0
// module not written out since it is a black box. 
//


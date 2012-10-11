/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0xb4d1ced7 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "/home/jenn/quad/quad_fpga/spi_module.vhd";
extern char *IEEE_P_2592010699;
extern char *IEEE_P_1242562249;

char *ieee_p_1242562249_sub_1006216973935652998_1035706684(char *, char *, char *, char *, int );
unsigned char ieee_p_1242562249_sub_3307759752501467860_1035706684(char *, char *, char *, int );
unsigned char ieee_p_1242562249_sub_3307759752501503797_1035706684(char *, char *, char *, int );
unsigned char ieee_p_1242562249_sub_3307759752501539734_1035706684(char *, char *, char *, int );
unsigned char ieee_p_2592010699_sub_13554554585326073636_503743352(char *, char *, unsigned int , unsigned int );
unsigned char ieee_p_2592010699_sub_2763492388968962707_503743352(char *, char *, unsigned int , unsigned int );
unsigned char ieee_p_2592010699_sub_3488768496604610246_503743352(char *, unsigned char , unsigned char );
unsigned char ieee_p_2592010699_sub_374109322130769762_503743352(char *, unsigned char );


static void work_a_3415757621_3212880686_p_0(char *t0)
{
    char t17[16];
    char t19[16];
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    unsigned char t5;
    char *t6;
    char *t7;
    unsigned char t8;
    unsigned char t9;
    char *t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t15;
    unsigned char t16;
    char *t18;
    char *t20;
    char *t21;
    int t22;
    unsigned int t23;
    unsigned char t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;

LAB0:    xsi_set_current_line(52, ng0);
    t1 = (t0 + 1192U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)2);
    if (t4 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(87, ng0);
    t1 = xsi_get_transient_memory(8U);
    memset(t1, 0, 8U);
    t2 = t1;
    memset(t2, (unsigned char)2, 8U);
    t6 = (t0 + 9160);
    t7 = (t6 + 56U);
    t10 = *((char **)t7);
    t14 = (t10 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t1, 8U);
    xsi_driver_first_trans_fast(t6);
    xsi_set_current_line(88, ng0);
    t1 = (t0 + 9096);
    t2 = (t1 + 56U);
    t6 = *((char **)t2);
    t7 = (t6 + 56U);
    t10 = *((char **)t7);
    *((unsigned char *)t10) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(89, ng0);
    t1 = xsi_get_transient_memory(8U);
    memset(t1, 0, 8U);
    t2 = t1;
    memset(t2, (unsigned char)2, 8U);
    t6 = (t0 + 8904);
    t7 = (t6 + 56U);
    t10 = *((char **)t7);
    t14 = (t10 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t1, 8U);
    xsi_driver_first_trans_fast(t6);
    xsi_set_current_line(90, ng0);
    t1 = xsi_get_transient_memory(8U);
    memset(t1, 0, 8U);
    t2 = t1;
    memset(t2, (unsigned char)2, 8U);
    t6 = (t0 + 9288);
    t7 = (t6 + 56U);
    t10 = *((char **)t7);
    t14 = (t10 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t1, 8U);
    xsi_driver_first_trans_fast(t6);
    xsi_set_current_line(91, ng0);
    t1 = (t0 + 8968);
    t2 = (t1 + 56U);
    t6 = *((char **)t2);
    t7 = (t6 + 56U);
    t10 = *((char **)t7);
    *((unsigned char *)t10) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);

LAB3:    t1 = (t0 + 8664);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(53, ng0);
    t1 = (t0 + 992U);
    t5 = ieee_p_2592010699_sub_2763492388968962707_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t5 != 0)
        goto LAB5;

LAB7:
LAB6:    xsi_set_current_line(70, ng0);
    t1 = (t0 + 992U);
    t3 = ieee_p_2592010699_sub_13554554585326073636_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t3 != 0)
        goto LAB33;

LAB35:
LAB34:    goto LAB3;

LAB5:    xsi_set_current_line(55, ng0);
    t6 = (t0 + 2952U);
    t7 = *((char **)t6);
    t8 = *((unsigned char *)t7);
    t9 = (t8 == (unsigned char)3);
    if (t9 != 0)
        goto LAB8;

LAB10:
LAB9:    xsi_set_current_line(59, ng0);
    t1 = (t0 + 3912U);
    t2 = *((char **)t1);
    t1 = (t0 + 13371);
    t4 = 1;
    if (8U == 8U)
        goto LAB19;

LAB20:    t4 = 0;

LAB21:    if (t4 == 1)
        goto LAB16;

LAB17:    t3 = (unsigned char)0;

LAB18:    if (t3 != 0)
        goto LAB13;

LAB15:    t1 = (t0 + 3912U);
    t2 = *((char **)t1);
    t1 = (t0 + 13379);
    t3 = 1;
    if (8U == 8U)
        goto LAB27;

LAB28:    t3 = 0;

LAB29:    if (t3 != 0)
        goto LAB25;

LAB26:
LAB14:    xsi_set_current_line(66, ng0);
    t1 = (t0 + 3912U);
    t2 = *((char **)t1);
    t1 = (t0 + 13272U);
    t6 = ieee_p_1242562249_sub_1006216973935652998_1035706684(IEEE_P_1242562249, t17, t2, t1, 1);
    t7 = (t0 + 9160);
    t10 = (t7 + 56U);
    t14 = *((char **)t10);
    t15 = (t14 + 56U);
    t18 = *((char **)t15);
    memcpy(t18, t6, 8U);
    xsi_driver_first_trans_fast(t7);
    goto LAB6;

LAB8:    xsi_set_current_line(56, ng0);
    t6 = (t0 + 3592U);
    t10 = *((char **)t6);
    t11 = (7 - 6);
    t12 = (t11 * 1U);
    t13 = (0 + t12);
    t6 = (t10 + t13);
    t14 = (t0 + 1352U);
    t15 = *((char **)t14);
    t16 = *((unsigned char *)t15);
    t18 = ((IEEE_P_2592010699) + 4000);
    t20 = (t19 + 0U);
    t21 = (t20 + 0U);
    *((int *)t21) = 6;
    t21 = (t20 + 4U);
    *((int *)t21) = 0;
    t21 = (t20 + 8U);
    *((int *)t21) = -1;
    t22 = (0 - 6);
    t23 = (t22 * -1);
    t23 = (t23 + 1);
    t21 = (t20 + 12U);
    *((unsigned int *)t21) = t23;
    t14 = xsi_base_array_concat(t14, t17, t18, (char)97, t6, t19, (char)99, t16, (char)101);
    t23 = (7U + 1U);
    t24 = (8U != t23);
    if (t24 == 1)
        goto LAB11;

LAB12:    t21 = (t0 + 8904);
    t25 = (t21 + 56U);
    t26 = *((char **)t25);
    t27 = (t26 + 56U);
    t28 = *((char **)t27);
    memcpy(t28, t14, 8U);
    xsi_driver_first_trans_fast(t21);
    goto LAB9;

LAB11:    xsi_size_not_matching(8U, t23, 0);
    goto LAB12;

LAB13:    xsi_set_current_line(60, ng0);
    t14 = (t0 + 4232U);
    t18 = *((char **)t14);
    t9 = *((unsigned char *)t18);
    t16 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t9);
    t14 = (t0 + 8968);
    t20 = (t14 + 56U);
    t21 = *((char **)t20);
    t25 = (t21 + 56U);
    t26 = *((char **)t25);
    *((unsigned char *)t26) = t16;
    xsi_driver_first_trans_fast(t14);
    xsi_set_current_line(61, ng0);
    t1 = (t0 + 3592U);
    t2 = *((char **)t1);
    t1 = (t0 + 9032);
    t6 = (t1 + 56U);
    t7 = *((char **)t6);
    t10 = (t7 + 56U);
    t14 = *((char **)t10);
    memcpy(t14, t2, 8U);
    xsi_driver_first_trans_fast(t1);
    goto LAB14;

LAB16:    t14 = (t0 + 4712U);
    t15 = *((char **)t14);
    t5 = *((unsigned char *)t15);
    t8 = (t5 == (unsigned char)3);
    t3 = t8;
    goto LAB18;

LAB19:    t11 = 0;

LAB22:    if (t11 < 8U)
        goto LAB23;
    else
        goto LAB21;

LAB23:    t7 = (t2 + t11);
    t10 = (t1 + t11);
    if (*((unsigned char *)t7) != *((unsigned char *)t10))
        goto LAB20;

LAB24:    t11 = (t11 + 1);
    goto LAB22;

LAB25:    xsi_set_current_line(63, ng0);
    t14 = (t0 + 3592U);
    t15 = *((char **)t14);
    t22 = (6 - 7);
    t12 = (t22 * -1);
    t13 = (1U * t12);
    t23 = (0 + t13);
    t14 = (t15 + t23);
    t4 = *((unsigned char *)t14);
    t5 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t4);
    t18 = (t0 + 9096);
    t20 = (t18 + 56U);
    t21 = *((char **)t20);
    t25 = (t21 + 56U);
    t26 = *((char **)t25);
    *((unsigned char *)t26) = t5;
    xsi_driver_first_trans_fast(t18);
    goto LAB14;

LAB27:    t11 = 0;

LAB30:    if (t11 < 8U)
        goto LAB31;
    else
        goto LAB29;

LAB31:    t7 = (t2 + t11);
    t10 = (t1 + t11);
    if (*((unsigned char *)t7) != *((unsigned char *)t10))
        goto LAB28;

LAB32:    t11 = (t11 + 1);
    goto LAB30;

LAB33:    xsi_set_current_line(72, ng0);
    t2 = (t0 + 2792U);
    t6 = *((char **)t2);
    t4 = *((unsigned char *)t6);
    t5 = (t4 == (unsigned char)3);
    if (t5 != 0)
        goto LAB36;

LAB38:
LAB37:    xsi_set_current_line(76, ng0);
    t1 = (t0 + 3112U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB39;

LAB41:
LAB40:    xsi_set_current_line(80, ng0);
    t1 = (t0 + 3272U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB44;

LAB46:
LAB45:    goto LAB34;

LAB36:    xsi_set_current_line(73, ng0);
    t2 = (t0 + 3592U);
    t7 = *((char **)t2);
    t2 = (t0 + 9224);
    t10 = (t2 + 56U);
    t14 = *((char **)t10);
    t15 = (t14 + 56U);
    t18 = *((char **)t15);
    memcpy(t18, t7, 6U);
    xsi_driver_first_trans_fast(t2);
    goto LAB37;

LAB39:    xsi_set_current_line(77, ng0);
    t1 = (t0 + 3752U);
    t6 = *((char **)t1);
    t11 = (7 - 6);
    t12 = (t11 * 1U);
    t13 = (0 + t12);
    t1 = (t6 + t13);
    t10 = ((IEEE_P_2592010699) + 4000);
    t14 = (t19 + 0U);
    t15 = (t14 + 0U);
    *((int *)t15) = 6;
    t15 = (t14 + 4U);
    *((int *)t15) = 0;
    t15 = (t14 + 8U);
    *((int *)t15) = -1;
    t22 = (0 - 6);
    t23 = (t22 * -1);
    t23 = (t23 + 1);
    t15 = (t14 + 12U);
    *((unsigned int *)t15) = t23;
    t7 = xsi_base_array_concat(t7, t17, t10, (char)97, t1, t19, (char)99, (unsigned char)2, (char)101);
    t23 = (7U + 1U);
    t5 = (8U != t23);
    if (t5 == 1)
        goto LAB42;

LAB43:    t15 = (t0 + 9288);
    t18 = (t15 + 56U);
    t20 = *((char **)t18);
    t21 = (t20 + 56U);
    t25 = *((char **)t21);
    memcpy(t25, t7, 8U);
    xsi_driver_first_trans_fast(t15);
    goto LAB40;

LAB42:    xsi_size_not_matching(8U, t23, 0);
    goto LAB43;

LAB44:    xsi_set_current_line(81, ng0);
    t1 = (t0 + 2152U);
    t6 = *((char **)t1);
    t1 = (t0 + 9288);
    t7 = (t1 + 56U);
    t10 = *((char **)t7);
    t14 = (t10 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 8U);
    xsi_driver_first_trans_fast(t1);
    goto LAB45;

}

static void work_a_3415757621_3212880686_p_1(char *t0)
{
    char *t1;
    unsigned char t2;
    char *t3;
    char *t4;
    unsigned char t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;

LAB0:    xsi_set_current_line(100, ng0);
    t1 = (t0 + 1792U);
    t2 = ieee_p_2592010699_sub_2763492388968962707_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t2 != 0)
        goto LAB2;

LAB4:
LAB3:    t1 = (t0 + 8680);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(101, ng0);
    t3 = (t0 + 4392U);
    t4 = *((char **)t3);
    t5 = *((unsigned char *)t4);
    t3 = (t0 + 9352);
    t6 = (t3 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    *((unsigned char *)t9) = t5;
    xsi_driver_first_trans_fast(t3);
    xsi_set_current_line(102, ng0);
    t1 = (t0 + 4232U);
    t3 = *((char **)t1);
    t2 = *((unsigned char *)t3);
    t1 = (t0 + 9416);
    t4 = (t1 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((unsigned char *)t8) = t2;
    xsi_driver_first_trans_fast(t1);
    goto LAB3;

}

static void work_a_3415757621_3212880686_p_2(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    unsigned char t5;
    unsigned char t6;
    unsigned char t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;

LAB0:    xsi_set_current_line(106, ng0);

LAB3:    t1 = (t0 + 4552U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t1 = (t0 + 4392U);
    t4 = *((char **)t1);
    t5 = *((unsigned char *)t4);
    t6 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t5);
    t7 = ieee_p_2592010699_sub_3488768496604610246_503743352(IEEE_P_2592010699, t3, t6);
    t1 = (t0 + 9480);
    t8 = (t1 + 56U);
    t9 = *((char **)t8);
    t10 = (t9 + 56U);
    t11 = *((char **)t10);
    *((unsigned char *)t11) = t7;
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t12 = (t0 + 8696);
    *((int *)t12) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_3(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    char *t5;
    unsigned char t6;
    unsigned char t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    unsigned char t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;

LAB0:    xsi_set_current_line(114, ng0);
    t1 = (t0 + 3912U);
    t2 = *((char **)t1);
    t1 = (t0 + 13272U);
    t3 = ieee_p_1242562249_sub_3307759752501503797_1035706684(IEEE_P_1242562249, t2, t1, 8);
    if (t3 != 0)
        goto LAB3;

LAB4:
LAB5:    t16 = (t0 + 9544);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    t19 = (t18 + 56U);
    t20 = *((char **)t19);
    *((unsigned char *)t20) = (unsigned char)2;
    xsi_driver_first_trans_fast(t16);

LAB2:    t21 = (t0 + 8712);
    *((int *)t21) = 1;

LAB1:    return;
LAB3:    t4 = (t0 + 1192U);
    t5 = *((char **)t4);
    t6 = *((unsigned char *)t5);
    t7 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t6);
    t4 = (t0 + 4712U);
    t8 = *((char **)t4);
    t9 = *((unsigned char *)t8);
    t10 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t9);
    t11 = ieee_p_2592010699_sub_3488768496604610246_503743352(IEEE_P_2592010699, t7, t10);
    t4 = (t0 + 9544);
    t12 = (t4 + 56U);
    t13 = *((char **)t12);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    *((unsigned char *)t15) = t11;
    xsi_driver_first_trans_fast(t4);
    goto LAB2;

LAB6:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_4(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    char *t5;
    unsigned char t6;
    unsigned char t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    unsigned char t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;

LAB0:    xsi_set_current_line(117, ng0);
    t1 = (t0 + 3912U);
    t2 = *((char **)t1);
    t1 = (t0 + 13272U);
    t3 = ieee_p_1242562249_sub_3307759752501539734_1035706684(IEEE_P_1242562249, t2, t1, 8);
    if (t3 != 0)
        goto LAB3;

LAB4:
LAB5:    t16 = (t0 + 9608);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    t19 = (t18 + 56U);
    t20 = *((char **)t19);
    *((unsigned char *)t20) = (unsigned char)2;
    xsi_driver_first_trans_fast(t16);

LAB2:    t21 = (t0 + 8728);
    *((int *)t21) = 1;

LAB1:    return;
LAB3:    t4 = (t0 + 1192U);
    t5 = *((char **)t4);
    t6 = *((unsigned char *)t5);
    t7 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t6);
    t4 = (t0 + 4712U);
    t8 = *((char **)t4);
    t9 = *((unsigned char *)t8);
    t10 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t9);
    t11 = ieee_p_2592010699_sub_3488768496604610246_503743352(IEEE_P_2592010699, t7, t10);
    t4 = (t0 + 9608);
    t12 = (t4 + 56U);
    t13 = *((char **)t12);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    *((unsigned char *)t15) = t11;
    xsi_driver_first_trans_fast(t4);
    goto LAB2;

LAB6:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_5(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    char *t5;
    unsigned char t6;
    unsigned char t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    unsigned char t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;

LAB0:    xsi_set_current_line(118, ng0);
    t1 = (t0 + 3912U);
    t2 = *((char **)t1);
    t1 = (t0 + 13272U);
    t3 = ieee_p_1242562249_sub_3307759752501467860_1035706684(IEEE_P_1242562249, t2, t1, 8);
    if (t3 != 0)
        goto LAB3;

LAB4:
LAB5:    t12 = (t0 + 4712U);
    t13 = *((char **)t12);
    t14 = *((unsigned char *)t13);
    t12 = (t0 + 9672);
    t15 = (t12 + 56U);
    t16 = *((char **)t15);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    *((unsigned char *)t18) = t14;
    xsi_driver_first_trans_fast(t12);

LAB2:    t19 = (t0 + 8744);
    *((int *)t19) = 1;

LAB1:    return;
LAB3:    t4 = (t0 + 1192U);
    t5 = *((char **)t4);
    t6 = *((unsigned char *)t5);
    t7 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t6);
    t4 = (t0 + 9672);
    t8 = (t4 + 56U);
    t9 = *((char **)t8);
    t10 = (t9 + 56U);
    t11 = *((char **)t10);
    *((unsigned char *)t11) = t7;
    xsi_driver_first_trans_fast(t4);
    goto LAB2;

LAB6:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_6(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    char *t5;
    int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned char t10;
    unsigned char t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;

LAB0:    xsi_set_current_line(121, ng0);
    t1 = (t0 + 3912U);
    t2 = *((char **)t1);
    t1 = (t0 + 13272U);
    t3 = ieee_p_1242562249_sub_3307759752501503797_1035706684(IEEE_P_1242562249, t2, t1, 8);
    if (t3 != 0)
        goto LAB3;

LAB4:
LAB5:    t17 = (t0 + 9736);
    t18 = (t17 + 56U);
    t19 = *((char **)t18);
    t20 = (t19 + 56U);
    t21 = *((char **)t20);
    *((unsigned char *)t21) = (unsigned char)2;
    xsi_driver_first_trans_fast(t17);

LAB2:    t22 = (t0 + 8760);
    *((int *)t22) = 1;

LAB1:    return;
LAB3:    t4 = (t0 + 3592U);
    t5 = *((char **)t4);
    t6 = (7 - 7);
    t7 = (t6 * -1);
    t8 = (1U * t7);
    t9 = (0 + t8);
    t4 = (t5 + t9);
    t10 = *((unsigned char *)t4);
    t11 = ieee_p_2592010699_sub_374109322130769762_503743352(IEEE_P_2592010699, t10);
    t12 = (t0 + 9736);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    *((unsigned char *)t16) = t11;
    xsi_driver_first_trans_fast(t12);
    goto LAB2;

LAB6:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_7(char *t0)
{
    unsigned char t1;
    unsigned char t2;
    char *t3;
    char *t4;
    unsigned char t5;
    unsigned char t6;
    unsigned char t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    char *t11;
    unsigned char t12;
    unsigned char t13;
    unsigned char t14;
    char *t15;
    unsigned char t16;
    unsigned char t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned char t28;
    char *t29;
    char *t30;
    char *t31;
    char *t32;
    char *t33;
    char *t34;

LAB0:    xsi_set_current_line(123, ng0);
    t3 = (t0 + 3112U);
    t4 = *((char **)t3);
    t5 = *((unsigned char *)t4);
    t6 = (t5 == (unsigned char)3);
    if (t6 == 1)
        goto LAB8;

LAB9:    t3 = (t0 + 3272U);
    t8 = *((char **)t3);
    t9 = *((unsigned char *)t8);
    t10 = (t9 == (unsigned char)3);
    if (t10 == 1)
        goto LAB11;

LAB12:    t7 = (unsigned char)0;

LAB13:    t2 = t7;

LAB10:    t14 = (!(t2));
    if (t14 == 1)
        goto LAB5;

LAB6:    t3 = (t0 + 4712U);
    t15 = *((char **)t3);
    t16 = *((unsigned char *)t15);
    t17 = (t16 == (unsigned char)3);
    t1 = t17;

LAB7:    if (t1 != 0)
        goto LAB3;

LAB4:
LAB14:    t22 = (t0 + 3752U);
    t23 = *((char **)t22);
    t24 = (7 - 7);
    t25 = (t24 * -1);
    t26 = (1U * t25);
    t27 = (0 + t26);
    t22 = (t23 + t27);
    t28 = *((unsigned char *)t22);
    t29 = (t0 + 9800);
    t30 = (t29 + 56U);
    t31 = *((char **)t30);
    t32 = (t31 + 56U);
    t33 = *((char **)t32);
    *((unsigned char *)t33) = t28;
    xsi_driver_first_trans_fast_port(t29);

LAB2:    t34 = (t0 + 8776);
    *((int *)t34) = 1;

LAB1:    return;
LAB3:    t3 = (t0 + 9800);
    t18 = (t3 + 56U);
    t19 = *((char **)t18);
    t20 = (t19 + 56U);
    t21 = *((char **)t20);
    *((unsigned char *)t21) = (unsigned char)4;
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB5:    t1 = (unsigned char)1;
    goto LAB7;

LAB8:    t2 = (unsigned char)1;
    goto LAB10;

LAB11:    t3 = (t0 + 1032U);
    t11 = *((char **)t3);
    t12 = *((unsigned char *)t11);
    t13 = (t12 == (unsigned char)2);
    t7 = t13;
    goto LAB13;

LAB15:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_8(char *t0)
{
    char *t1;
    char *t2;
    unsigned int t3;
    unsigned int t4;
    unsigned int t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;

LAB0:    xsi_set_current_line(126, ng0);

LAB3:    t1 = (t0 + 3592U);
    t2 = *((char **)t1);
    t3 = (7 - 5);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t1 = (t2 + t5);
    t6 = (t0 + 9864);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    memcpy(t10, t1, 6U);
    xsi_driver_first_trans_fast_port(t6);

LAB2:    t11 = (t0 + 8792);
    *((int *)t11) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_9(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(127, ng0);

LAB3:    t1 = (t0 + 4072U);
    t2 = *((char **)t1);
    t1 = (t0 + 9928);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 8U);
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t7 = (t0 + 8808);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_3415757621_3212880686_p_10(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(128, ng0);

LAB3:    t1 = (t0 + 3432U);
    t2 = *((char **)t1);
    t1 = (t0 + 9992);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 6U);
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t7 = (t0 + 8824);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}


extern void work_a_3415757621_3212880686_init()
{
	static char *pe[] = {(void *)work_a_3415757621_3212880686_p_0,(void *)work_a_3415757621_3212880686_p_1,(void *)work_a_3415757621_3212880686_p_2,(void *)work_a_3415757621_3212880686_p_3,(void *)work_a_3415757621_3212880686_p_4,(void *)work_a_3415757621_3212880686_p_5,(void *)work_a_3415757621_3212880686_p_6,(void *)work_a_3415757621_3212880686_p_7,(void *)work_a_3415757621_3212880686_p_8,(void *)work_a_3415757621_3212880686_p_9,(void *)work_a_3415757621_3212880686_p_10};
	xsi_register_didat("work_a_3415757621_3212880686", "isim/spi_tb_isim_beh.exe.sim/work/a_3415757621_3212880686.didat");
	xsi_register_executes(pe);
}

/*
 * serial.h
 *
 * Created: 6/30/2012 3:34:22 PM
 *  Author: jenn
 */ 

#ifndef SERIAL_H_
#define SERIAL_H_

#include <stdio.h>
#include <avr/sfr_defs.h>
#include <avr/interrupt.h>
#include <util/atomic.h>
#include <avr/io.h>


#define RX_BUF_SIZE 128
#define RX_WATERMARK (RX_BUF_SIZE - 8)
#define TX_BUF_SIZE 128

void USART_init();
char USART_blocking_getchar();
char USART_getchar();
int8_t USART_putchar(char data);
void USART_putstring(char * string);
void USART_to_stdio();
int serial_stream_out(char c, FILE * stream);
int serial_stream_in(FILE * stream);
void flush_input(void);



#endif /* SERIAL_H_ */
/*
 * serial_test.c
 *
 * Created: 7/31/2012 5:30:58 PM
 *  Author: jenn
 */ 

#define F_CPU 16000000

#include <avr/io.h>
#include "serial.h"
#include <util/delay.h>

char cmd;

int main(void)
{
	USART_init(&PORTD, &DDRD, 5, 6);
	USART_to_stdio();
	
	
    while(1)
    {
		scanf("%c", &cmd);
		
		printf("Your char was %c\n", cmd);
    }
}
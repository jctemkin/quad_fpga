/*
 * untitled.c
 * 
 * Copyright 2012 Unknown <jenn@jenn-laptop>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */


#include <stdio.h>
#include <avr/io.h>
#include <avr/sfr_defs.h>
#include "serial/serial.h"
#include <util/delay.h>

#define SCK_BIT 5
#define MISO_BIT 4
#define MOSI_BIT 3
#define SS_BIT 2
#define SPI_DDR DDRB
#define SPI_PORT PORTB
#define SPI_PIN PINB

void spi_write(uint8_t);
uint8_t spi_read();

uint8_t data[5] = { 0, 200, 200, 200, 200 };

unsigned nums[4];

char cmd;

void main()
{
	
	DDRD |= _BV(6);
	DDRD |= _BV(5);

	//Set up serial port
	USART_init();
	USART_to_stdio();
	


	sei();

	//printf("Hi!\n");
	
	//Set up SPI pins
	SPI_DDR |= _BV(MOSI_BIT) | _BV(SCK_BIT) | _BV(SS_BIT);
	SPI_DDR &= ~(_BV(MISO_BIT));

	//Set SPI settings
	SPCR = 0x5D;
	SPSR &= ~(1 << SPI2X);
	
	//Frame with CS
	SPI_PORT &= ~(_BV(SS_BIT));
	_delay_us(2);
	//Send five bytes.
	for (unsigned i = 0; i < 5; ++i)
		spi_write(data[i]);
	_delay_us(2);
	//Unsnop.
	SPI_PORT |= _BV(SS_BIT);
	
	
	printf("Four numbers?\n");
	
	//Wait for input.
	while(1)
	{
		scanf("%u %u %u %u", &nums[0], &nums[1], &nums[2], &nums[3]);
		
		printf("Got %u %u %u %u.\n", nums[0], nums[1], nums[2], nums[3]);
		printf("Truncated to");
		//Truncate those ints to 1 byte each.
		for (unsigned i = 0; i < 4; ++i)
		{
			nums[i] &= 0x00FF;
			printf(" %u", nums[i]);
			data[i+1] = (char)nums[i];
		}
		printf("; Data array is %X%X%X%X%X\n", data[0], data[1], data[2], data[3], data[4]);
		
		SPI_PORT &= ~(_BV(SS_BIT));
		_delay_us(2);
		for (unsigned i = 0; i < 5; ++i)
			spi_write(data[i]);
		SPI_PORT |= _BV(SS_BIT);
		_delay_us(2);
		printf("Data sent.\n");

	}
	
}

void spi_write(uint8_t byte)
{
	SPDR = byte;
	while(!(SPSR & (1<<SPIF)));
}

uint8_t spi_read()
{
	uint8_t retval;
	
	SPDR = 0xAA;
	while(!(SPSR & (1<<SPIF)));
	retval = SPDR;
	
	return retval;
}

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


#include "spi.h"


#if DEVICE=atmega328
	#define SCK_BIT 5
	#define MISO_BIT 4
	#define MOSI_BIT 3
	#define SS_BIT 2
	#define SPI_DDR DDRB
	#define SPI_PORT PORTB
	#define SPI_PIN PINB
#endif


void spi_init(uint8_t * cs_port, uint8_t * cs_ddr, uint8_t cs_bit)
{
	
	//Set up SPI pins
	SPI_DDR |= _BV(MOSI_BIT) | _BV(SCK_BIT) | _BV(SS_BIT);
	SPI_DDR &= ~(_BV(MISO_BIT));
	
	*cs_ddr |= 
	
	
}

/*
 * serial.c
 * 
 * Library to interface with the USART on the ATMEGA328.
 *
 * Created: 6/30/2012 1:00:56 AM
 *  Author: jenn
 */ 


#include "serial.h"


#define BAUD 9600
#define BAUD_PRESCALER (((F_CPU / (BAUD * 16UL))) - 1)


#ifdef __AVR_ATtiny2313__

	#define UDR0 UDR
	#define UCSR0A UCSRA
	#define UCSR0B UCSRB
	#define UCSR0C UCSRC
	#define UBRR0H UBRRH
	#define UBRR0L UBRRL
	#define RXC0 RXC
	#define RXEN0 RXEN
	#define TXEN0 TXEN
	#define UCSZ00 UCSZ0
	#define UDRE0 UDRE


#endif

uint8_t cts_bit;
//uint8_t rts_bit;
volatile uint8_t * fc_port;

//RX and TX ring buffers.
char rx_buffer[RX_BUF_SIZE];
char tx_buffer[TX_BUF_SIZE];

//Pointers to head and tail of RX and TX buffers.
volatile char * rx_buf_head;
volatile char * tx_buf_head;
volatile char * rx_buf_tail;
volatile char * tx_buf_tail;

//How many bytes are currently used in the TX and RX buffers.
volatile uint8_t rx_bytes;
volatile uint8_t tx_bytes;

unsigned int rx_errors;
int discard;



void USART_init(volatile uint8_t * flow_port, volatile uint8_t * flow_ddr, uint8_t cts, uint8_t rts)
{
	//Save FC port and CTS and RTS pins.
	//cts_bit = cts;
	//rts_bit = rts;
	//fc_port = flow_port;
	
	//Set baud rate.
	UBRR0H = (uint8_t)(BAUD_PRESCALER>>8);
	UBRR0L = (uint8_t)(BAUD_PRESCALER);
	
	//Set 8 data bits, 1 stop bit, even parity
	//UCSR0C = 0x26;
	UCSR0C = (3 << UCSZ00);
	
	//Set up buffer variables.
	rx_buf_head = rx_buffer;
	rx_buf_tail = rx_buffer;
	tx_buf_head = tx_buffer;
	tx_buf_tail = tx_buffer;
	rx_bytes = 0;
	tx_bytes = 0;
	
	DDRD &= ~_BV(5);
	
	
	//Enable RX, TX, and the RXC interrupt.
	UCSR0B =  _BV(RXCIE0) | _BV(RXEN0) | _BV(TXEN0);
		
	
	//Set data direction for CTS and RTS.
	//*flow_ddr |= _BV(cts);
	//*flow_ddr &= ~_BV(rts);
	
	//Start with CTS low.
	//*flow_port &= ~_BV(cts);
	
	
	sei();
	
}




//Gets a character from the USART, blocking if needed.
char USART_blocking_getchar(void)
{
	char ret;
	
	//If there's no data, block.
	while(!rx_bytes);

	
	//Then pull a byte and adjust the shared count.
	//Make sure we aren't interrupted.
	ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
	{
		ret = *rx_buf_head;
		
		--rx_bytes;
		//If the buffer was brought below the watermark, lower CTS so we can receive some more.
		//if(--rx_bytes == RX_WATERMARK)
		//	*fc_port &= ~_BV(cts_bit);
	}
	
	
	//Adjust the head pointer.
	if(++rx_buf_head >= rx_buffer + RX_BUF_SIZE)
		rx_buf_head = rx_buffer;

	
	//Return the byte we received.
	return ret;
}


//Gets a character from the USART, or return null if buffer is empty.
char USART_getchar(void)
{
	char ret;
	
	//If there's no data, return null.
	if (!rx_bytes)
		ret = 0x00;
	//Otherwise, pull a byte and adjust the shared count.
	else
	{
		//Make sure we aren't interrupted.
		ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
		{
			ret = *rx_buf_head;
		
			--rx_bytes;
			//If the buffer was brought below the watermark, lower CTS so we can receive some more.
			//if(--rx_bytes == RX_WATERMARK)
			//	*fc_port &= ~_BV(cts_bit);
		}
		
		//Adjust the head pointer.
		if(++rx_buf_head >= rx_buffer + RX_BUF_SIZE)
			rx_buf_head = rx_buffer;
	}
	
	//Return the byte we received (or didn't).
	return ret;
}



//Transmits a character on the USART. Discards input if the buffer is full and returns -1.
int8_t USART_putchar(char data)
{
	int8_t retval;
	
	//If the buffer is full, bail.
	if (tx_bytes == TX_BUF_SIZE)
	{
		retval = -1;
	}		
	//Otherwise, put the char on the buffer.
	else
	{
		ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
		{
			*tx_buf_tail = data;
			++tx_bytes;
		
			//Adjust the tail pointer.
			if(++tx_buf_tail >= tx_buffer + TX_BUF_SIZE)
				tx_buf_tail = tx_buffer;
		}					
		retval = 0;
	}
	
	//Enable the UDRE interrupt, regardless-- we want to transmit.
	UCSR0B |= _BV(UDRIE0);

	
	return retval;
}

//Transmits a string on the USART.
void USART_putstring(char * string)
{
	//back in my days we didn't have strings
	for(; *string; ++string)
		USART_putchar(*string);
}


//Call this to attach STDIO to the serial port.
void USART_to_stdio()
{
	fdevopen(serial_stream_out, serial_stream_in);
}


//This special function is called by the compiler's standard output/error routines;
//once for each character send to the stream.
int serial_stream_out(char c, FILE * stream)
{
	//Simply pass the character on to our virtual serial port.
	return USART_putchar(c);
}

//This function parallels usb_stream_out, except is is designed to handle reads from the standard input.
int serial_stream_in(FILE * stream)
{
	return USART_blocking_getchar();
}


//Whenever a receive is complete:
ISR(USART_RX_vect) 
{	
	PORTD |= _BV(5);
	//Discard byte if there are errors or we run out of space.
	/*
	if ((UCSR0A & 0x1C) || (rx_bytes == RX_BUF_SIZE))
	{
		++discard;
		discard = UDR0;
		++rx_errors;
	}
	else */
	if (rx_bytes < RX_BUF_SIZE)
	{
		*rx_buf_tail = UDR0;	//read a byte to the buffer.
		
		if (++rx_buf_tail >= rx_buffer + RX_BUF_SIZE)	//Increment the tail,
			rx_buf_tail = rx_buffer; // looping to beginning of ring if necessary.
		
		++rx_bytes;
		//If incrementing brings it above the high-water mark,
		//if(++rx_bytes >= RX_WATERMARK)
			//*fc_port |= _BV(cts_bit); //raise CTS so we don't receive any more data.
	}
	PORTD &= ~_BV(5);
		
}


//When the transmit buffer is empty:
ISR(USART_UDRE_vect)
{
	//If there are bytes to transmit, 
	if(tx_bytes)
	{
		UDR0 = *tx_buf_head;	//transmit them.
		
		if (++tx_buf_head >= tx_buffer + TX_BUF_SIZE)	//Also increment the head pointer.
			tx_buf_head = tx_buffer;
		
		if(!(--tx_bytes)) //Decrement the number of bytes waiting.
			UCSR0B &= ~_BV(UDRIE0); //If there aren't any more, disable this interrupt.
	}
	else	//Otherwise, disable this interrupt until we want to transmit again. 
		UCSR0B &= ~_BV(UDRIE0); //We shouldn't ever reach this case, but let's handle it anyway.	
}
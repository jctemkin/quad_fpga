

#ifndef SPI_H_
#define SPI_H_

#include <avr/io.h>
#include <util/delay.h>

void spi_init(uint8_t * cs_port, uint8_t * cs_ddr, uint8_t cs_bit);
uint8_t spi_read(uint8_t * rx_buf, unsigned num_bytes);
uint8_t spi_write(uint8_t * tx_buf, unsigned num_bytes);

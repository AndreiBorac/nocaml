  .text
  .word 0x20002000 /* Top of stack */
  .word _start + 1 /* Reset handler */
  .word 0 /* NMI */
  .word 0 /* Hard Fault */
  .word 0 /* Reserved */
  .word 0 /* Reserved */
  .word 0 /* Reserved */
  .word 0 /* Reserved */
  .word 0 /* Reserved */
  .word 0 /* Reserved */
  .word 0 /* Reserved */
  .word 0 /* SVC */
  .word 0 /* Reserved */
  .word 0 /* Reserved */
  .word 0 /* PendSV */
  .word 0 /* SysTick */
  .word 0 /* WWDG */
  .word 0 /* PVD */
  .word 0 /* RTC */
  .word 0 /* FLASH */
  .word 0 /* RCC */
  .word 0 /* EXTI0_1 */
  .word 0 /* EXTI2_3 */
  .word 0 /* EXTI4_15 */
  .word 0 /* TSC */
  .word 0 /* DMA_CH1 */
  .word 0 /* DMA_CH2_3 */
  .word 0 /* DMA_CH4_5 */
  .word 0 /* ADC_COMP */
  .word 0 /* TIM1_BRK_UP_TRG_COM */
  .word 0 /* TIM1_CC */
  .word 0 /* TIM2 */
  .word 0 /* TIM3 */
  .word 0 /* TIM6_DAC */
  .word 0 /* RESERVED */
  .word 0 /* TIM14 */
  .word 0 /* TIM15 */
  .word 0 /* TIM16 */
  .word 0 /* TIM17 */
  .word 0 /* I2C1 */
  .word 0 /* I2C2 */
  .word 0 /* SPI1 */
  .word 0 /* SPI2 */
  .word 0 /* USART1 */
  .word 0 /* USART2 */
  .word 0 /* RESERVED */
  .word 0 /* CEC */
  .word 0 /* RESERVED */
  .thumb
_start:
  .extern  main
  bl main
  b .

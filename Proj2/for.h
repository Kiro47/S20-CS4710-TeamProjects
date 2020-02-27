#define for(I,low,high) \
byte I; \
I = low ; \
do \
:: ( I > high ) -> break \
:: else ->

#define rof(I) \
; I++ \
od

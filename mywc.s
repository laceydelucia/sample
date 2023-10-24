#include <stdio.h>
#include <ctype.h>

      .section .rodata

printfFormatStr:
        .string "%7ld %7ld %7ld\n"
        


//----------------------------------------------------------------------

        .section .data

        .global lLineCount
lLineCount: .quad 0
        .global lWordCount
lWordCount: .quad 0
        .global lCharCount
lCharCount: .quad 0
        .global iInWord
iInWord: .word 0;

//----------------------------------------------------------------------

        .section .bss

iChar:
        .skip   4

//----------------------------------------------------------------------

        .section .text


        .equ    MAIN_STACK_BYTECOUNT, 16
        .equ    EOF, -1
        .equ    TRUE, 1
        .equ    FALSE, 0

        .global main

main:
    // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

    // iChar = getchar();
        bl      getchar
        adr     x1, iChar
        str    x0, [x1]

loop1: 
    // if (iChar == EOF) goto endloop1;
        adr     x0, iChar
        ldr     w0, [x0]
        mov     w3, EOF
        cmp     w0, w3
        beq     endloop1

    // lCharCount++;
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
    // if (!isspace(iChar)) goto else1;
        adr     x0, iChar
        ldr     x0, [x0]

        bl      isspace
        cbz     x0, else1

    // if (!iInWord) goto end1;
        adr     x0, iInWord
        ldr     w0, [x0]
        cmp     w0, 0
        beq     end1

    // lWordCount++
    // iInWord = FALSE;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
    
        adr     x1, iInWord
        mov     w2, FALSE
        str     w2, [x1]
        bl      end1

else1: 
        // if (isspace(iChar) || iInWord) goto end1;
        adr     x0, iInWord
        ldr     w0, [x0]
        cmp     w0, 1
        beq     end1

        adr     x0, iChar
        ldr     x0, [x0]
        bl      isspace
        cmp     x0, 1
        beq     end1

        // iInWord = TRUE;
        adr     x0, iInWord
        mov     w1, TRUE
        str     w1, [x0]
        
end1: 
    // if (iChar != '\n') goto end3;
        adr     x0, iChar
        ldr     w0, [x0]
        // '\n'
        mov     w1, '\n'
        cmp     w0, w1
        bne     end3
   // lLineCount++;
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

end3:
    // iChar = getChar();
        bl      getchar
        adr     x1, iChar
        str     x0, [x1]
   // goto loop1
        bl    loop1

endloop1: 
    // if (!iInWord) goto end2;
        adr     x0, iInWord
        ldr     w0, [x0]
        cmp     w0, 0
        beq     end2
   // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

end2:

    // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount)
        adr     x0, printfFormatStr
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf
   // return 0;
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
        






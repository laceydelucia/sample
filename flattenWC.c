#include <stdio.h>
#include <ctype.h>


enum {FALSE, TRUE};
static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
    iChar = getchar();
    loop1:
    if (iChar == EOF) goto endloop1;
      lCharCount++;

      if (isspace(iChar) == FALSE) goto else1;
         if (!iInWord) goto end1;
            lWordCount++;
            iInWord = FALSE;
      else1:
         if (isspace(iChar) || iInWord) goto end1;
            iInWord = TRUE;
      
      end1:

      if (iChar != '\n') goto end3;
         lLineCount++;

      end3: 
      iChar = getchar();
      goto loop1;
      
   endloop1:
   
   if (iInWord == FALSE) goto end2;
      lWordCount++;

   end2:
   
   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}

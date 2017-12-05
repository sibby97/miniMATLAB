# Creating your own header file
## .h file
It holds the prototypes of the functions.
Ifndef is used to avoid creating multiple definitions of the prototypes during preprocessing of the test file(when the hashtags are opened before compiling).

## .c file
It holds the definitions of the functions.

## Using the header file
add the line 
"#include "header.h""

## Compiling 
gcc -o <Object_File_Name> <Test_File_Name> < .c File_Name>

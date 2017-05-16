%{

/*-------------------------------------------------------------------------*
 *---									---*
 *---		bakingLang.lex						---*
 *---									---*
 *---	    This file defines lexemes for the baking language.		---*
 *---									---*
 *---	----	----	----	----	----	----	----	----	---*
 *---									---*
 *---	Version 1.0		2016 November 2		Joseph Phillips	---*
 *---									---*
 *-------------------------------------------------------------------------*/

//  Compile with
//  unix> flex -o bakingLang.c bakingLang.lex
//  unix> gcc bakingLang.c -c
//  unix> gcc -o bakingLang bakingLang.tab.o bakingLang.o

#include	"bakingHeaders.h"
#include	"bakingLang.tab.h"

#undef		YY_INPUT
#define		YY_INPUT(buffer,result,maxSize)		\
		{ result = ourInput(buffer,maxSize); }

extern
int		ourInput(char* buffer, int maxSize);

%}

%%

[ \t\n\r,]	{ /* ignore */}
(\-|\+)?[0-9]+|([0-9]*\.[0-9]+)	{
			  yylval.flt	= strtod(yytext,NULL);
			  return(NUMSYM);
			}

into		{ return(INTO);  	}
toMake		{printf("DOING toMake\n"); 	return(TOMAKE);	}
for		{ return(FOR);		}
at		{ return(AT);		}
"."		{return(PERIOD);}
portion|portions {return(PORTIONS);}




unsalted	{yylval.adjectives = UNSALTED_ADJ; return(ADJ);}
powdered	{yylval.adjectives = POWDERED_ADJ; return(ADJ);}	
soft		{yylval.adjectives = SOFT_ADJ; return(ADJ);}
firm		{yylval.adjectives = UNSALTED_ADJ; return(ADJ);}
unrefined	{yylval.adjectives = UNREFINED_ADJ; return(ADJ);}
organic		{yylval.adjectives = ORGANIC_ADJ;   return(ADJ);}
unsweetened	{yylval.adjectives = UNSWEETENED_ADJ; return(ADJ);}
bittersweet	{yylval.adjectives = BITTERSWEET_ADJ; return(ADJ);}
semisweet	{yylval.adjectives = SEMISWEET_ADJ; return(ADJ);}


mix|Mix		{yylval.verbs = MIX_VERB; return(VERBSYM);}
pour|Pour	{yylval.verbs = POUR_VERB; return(VERBSYM);}
flip|Flip	{yylval.verbs = FLIP_VERB; return(VERBSYM);}
remove|Remove	{yylval.verbs = REMOVE_VERB; return(VERBSYM);}
bake|Bake|cook|Cook	{yylval.verbs = BAKE_VERB; return(VERBSYM);}
add|Add		{yylval.verbs = ADD_VERB; return(VERBSYM);}
preheat|Preheat	{yylval.verbs = PREHEAT_VERB; return(VERBSYM);}
divide|Divide|separate|Separate	{yylval.verbs = DIVIDE_VERB; return(VERBSYM);}

tsp|teaspoon|teaspoons		{yylval.volumeMeasure = TEASPOON_MEASURE; return(VMEASURE);}
tbsp|tablespoon|tablespoons	{yylval.volumeMeasure = TABLESPOON_MEASURE; return(VMEASURE);}
cup|cups 			{yylval.volumeMeasure = CUP_MEASURE; return(VMEASURE);}


second|seconds	 {yylval.timeMeasure = SECOND_TIME_MEASURE; return(TIMEASURE);}
minute|minutes	 {yylval.timeMeasure = MINUTE_TIME_MEASURE; return(TIMEASURE);}
hour|hours	 {yylval.timeMeasure = HOUR_TIME_MEASURE; return(TIMEASURE);}

Celsius|C	 {yylval.tempMeasure = CELSIUS_TEMP_MEASURE; return(TEMEASURE);}
Fahrenheit|F	 {yylval.tempMeasure = FAHRENHEIT_TEMP_MEASURE; return(TEMEASURE);}





[a-zA-Z_][a-zA-Z_0-9]* {
			printf("DOING identifier pantry.getIngred\n");			
                        if( pantry.getIngredient(yytext) == NULL)
                        {
                                 yylval.charPtr = strdup(yytext);
				 printf("indentSYM\n");
                                 return(IDENTSYM);
                        }
                        else if(pantry.getIngredient(yytext) != NULL)
                        {	
                                yylval.ingredPtr = pantry.getIngredient(yytext);
			        return(INGREDSYM);
                        }
			else
			{
			printf("NOPE GOOD BYE");
			}
}

%%

//  PURPOSE:  To hold the input file from which to read the program (if it is
//	not 'stdin').
FILE*		filePtr		= NULL;

//  PURPOSE:  To point to the beginning of the input yet to read (if being
//	typed from the command line).
char*		textPtr		= NULL;

//  PURPOSE:  To point to the end of all input (if being typed from the command
//	line).
char*		textEndPtr	= NULL;


//  PURPOSE:  To return 1 if the tokenizer should quit after EOF is reached.
//	Returns 0 otherwise.  No parameters.
int	yywrap	()
{
  return(1);
}


//  PURPOSE:  To get up to 'maxSize' more characters of input and put them
//	into 'buffer'.   Returns how many characters were obtained.
int		ourInput	(char*	     buffer,
				 int	     maxSize
				)
{
  unsigned int	n;

  if  (filePtr == NULL)
  {
    n	= MIN(maxSize,textEndPtr - textPtr);

    if  (n > 0)
    {
      memcpy(buffer,textPtr,n);
      textPtr	+= n;
    }
  }
  else
  {
    errno	= 0;

    while  ( (n = fread(buffer,1,maxSize,yyin)) == 0 && ferror(yyin))
    {
      if  (errno != EINTR)
      {
        fprintf(stderr,"Reading file failed: %s\n",strerror(errno));
	exit(EXIT_FAILURE);
      }

      errno	= 0;
      clearerr(yyin);
    }

  }

  return(n);
}

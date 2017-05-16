%{

/*-------------------------------------------------------------------------*
 *---									---*
 *---		bakingLang.y						---*
 *---									---*
 *---	    This file defines a grammar for the baking language.	---*
 *---									---*
 *---	----	----	----	----	----	----	----	----	---*
 *---									---*
 *---	Version 1.0		2016 November 1		Joseph Phillips	---*
 *---									---*
 *-------------------------------------------------------------------------*/

//  Compile with
//  $ bison --verbose -d --debug bakingLang.y
//  $ gcc bakingLang.tab.c -c
#include  "bakingHeaders.h"

%}
 
%union
{
Recipe*					recipePtr;
Step*					stepPtr;

std::list<MeasuredIngredient*>*		listMesIngredPtr;

MeasuredIngredient*			mesIngredPtr;
const Ingredient*			ingredPtr;
char*					charPtr;

measurement_t				volumeMeasure;
timeMeasurement_t			timeMeasure;
tempMeasurement_t			tempMeasure;

adjective_t				adjectives;

float					flt;

verb_t					verbs;


}

%start					recipe


%right					PERIOD
%left					INTO
%left					TOMAKE
%left					FOR
%left					AT
%left					PORTIONS

%token	<adjectives>			ADJ

%token	<volumeMeasure>			VMEASURE
%token	<timeMeasure>			TIMEASURE
%token	<tempMeasure>			TEMEASURE
%token	<flt>				NUMSYM
%token	<verbs>				VERBSYM
%token	<ingredPtr>			INGREDSYM
%token	<charPtr>			IDENTSYM

%type	<stepPtr>			step
%type	<listMesIngredPtr>		list
%type	<mesIngredPtr>			subStep
%type	<recipePtr>			recipe
%type	<adjectives>			adjectiveList



%%

recipe	: recipe step
 	  {
	    if ($2 != NULL)
		((Recipe*)$1)->addStep($2);
	    

	    $$ = $1;
	  }
 	|
	  {
	    // lambda production
	    $$ = recipePtr = new Recipe;
	  };

adjectiveList : ADJ adjectiveList
		{
			printf("DOING adj \n");
			$$ = $1;
		}
		|
		{
			printf("DOING adj lambda \n");
			//lambda production
		};



step	: VERBSYM	IDENTSYM INTO IDENTSYM PERIOD
	{
	   printf("DOING verbsym ident into ident period\n");
	   $$ = new CombineStep($1, $4, $2);
	}
	
	| VERBSYM	list TOMAKE IDENTSYM PERIOD
	{
	   printf("DOING list tomake ident period\n");
	   $$ = new MixStep( $1, $2, $4);
	}
	| VERBSYM	IDENTSYM AT NUMSYM TEMEASURE FOR NUMSYM TIMEASURE PERIOD
	{
	   printf("DOING verb indent at\n");
	   $$ = new BakeStep( $1, $2, $5, $4, $8, $7);
	}
	| VERBSYM	IDENTSYM FOR NUMSYM TIMEASURE AT NUMSYM TEMEASURE PERIOD
	{
	   printf("DOING verb ident for \n");
	   $$ = new BakeStep( $1, $2, $8, $7, $5, $4);
	}
	| VERBSYM	IDENTSYM INTO NUMSYM PORTIONS PERIOD
	{
	  printf("DOING verb ident INTO NUMSYM PORTIONS PERIOD  \n");
          $$ = new SeparateStep( $1, $2, $4);
	};

list	: list subStep
	{
	  printf("DOING list subStep\n");
	  ((std::list<MeasuredIngredient*>*)$1)->push_back($2);
	  printf("done\n");
	  $$ =  $1; 
	}
	|
	{
	  //lambda production
	  $$ = new std::list<MeasuredIngredient*>;
	};

subStep	: NUMSYM VMEASURE adjectiveList INGREDSYM
	{
	 printf("DOING num vmeasure ingred\n");
	 $$ = new MeasuredIngredient($4, $1, $2);
	
	}

	| NUMSYM adjectiveList INGREDSYM 
	{
	printf("DOING num ingred\n");
	 $$ = new MeasuredIngredient($3, $1, EGG_MEASURE);
	};




%%


//  PURPOSE:  To show the error message pointed to by 'cPtr'.  Returns '0'.
int	yyerror	(const char *cPtr)
{
  printf("%s, sorry!\n",cPtr);

  if  (recipePtr != NULL)
    recipePtr->setWasParseTimeProblemFound();

  return(0);
}

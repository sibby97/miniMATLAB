%{
#include <stdio.h>
#include <ctype.h>
int yyerror(char *);
extern int yylex();
%}


%start translation_unit

%token UNSIGNED
%token BREAK
%token RETURN
%token VOID
%token CASE
%token FLOAT
%token SHORT
%token CHAR
%token FOR
%token SIGNED
%token WHILE
%token GOTO
%token BOOL
%token CONTINUE
%token IF
%token DEFAULT
%token DO
%token INT
%token SWITCH
%token DOUBLE
%token LONG
%token ELSE
%token MATRIX

%token IDENTIFIER
%token CONSTANT
%token STRINGLITERAL

%token opencurly
%token closecurly
%token opensq
%token closesq
%token openbrac
%token closebrac
%token fullstop
%token arrow
%token plusplus
%token minusminus
%token and
%token multiply
%token plus
%token minus
%token wave
%token negate
%token divide
%token mod
%token leftleft
%token rightright
%token less
%token great
%token lesseq
%token greateq
%token eq
%token noteq
%token cap
%token or
%token andand
%token oror
%token question
%token colon
%token semicolon
%token assign
%token mulass
%token divass
%token modass
%token plusass
%token minusass
%token leftleftass
%token rightrightass
%token andass
%token capass
%token orass
%token comma
%token hash
%token trans

%%
primary_expression 
		:	IDENTIFIER
			{ printf("primary-expression: %s\n",yytext);}
		|	CONSTANT
			{ printf("primary-expression: CONSTANT\n");}
		| 	STRINGLITERAL
			{ printf("primary-expression: STRINGLITERAL\n");}
		|	openbrac expression closebrac
			{ printf("primary-expression: ( expression )\n");}
		;

postfix_expression
		:	primary_expression
			{ printf("postfix-expression: primary-expression\n");}
		|	postfix_expression opensq expression closesq
			{ printf("postfix-expression: postfix-expression [ expression ]\n");}
		|	postfix_expression openbrac closebrac
			{ printf("postfix-expression: postfix-expression ( )\n");}
		|	postfix_expression openbrac argument_expression_list closebrac
			{ printf("postfix-expression: postfix-expression ( argument-expression-list )\n");}
		|	postfix_expression fullstop IDENTIFIER
			{ printf("postfix-expression: postfix-expression . IDENTIFIER\n");}
		|	postfix_expression arrow IDENTIFIER
			{ printf("postfix-expression: postfix-expression −> IDENTIFIER\n");}
		|	postfix_expression plusplus
			{ printf("postfix-expression: postfix-expression ++\n");}
		|	postfix_expression minusminus
			{ printf("postfix-expression: postfix-expression −−\n");}
		|	postfix_expression trans
			{ printf("postfix-expression: postfix-expression .'\n");}
		;


argument_expression_list
		:	assignment_expression
			{ printf("argument-expression-list: assignment-expression\n");}
		|	argument_expression_list comma assignment_expression
			{ printf("argument-expression-list: argument-expression-list , assignment-expression\n");}
		;

unary_expression
		:	postfix_expression
			{ printf("unary-expression: postfix-expression\n");}
		|	plusplus unary_expression
			{ printf("unary-expression: ++ unary-expression\n");}
		|	minusminus unary_expression
			{ printf("unary-expression: −− unary-expression\n");}
		|	unary_operator cast_expression
			{ printf("unary-expression: unary-operator cast-expression\n");}
		;

unary_operator
		:	and
			{ printf("unary-operator: &\n");}
		|	multiply
			{ printf("unary-operator: *\n");}
		|	plus
			{ printf("unary-operator: +\n");}
		|	minus
			{ printf("unary-operator: -\n");}
		;

cast_expression
		:	unary_expression
			{ printf("cast-expression: unary-expression\n");}
		;

multiplicative_expression
		:	cast_expression
			{ printf("multiplicative-expression: cast-expression\n");}
		|	multiplicative_expression multiply cast_expression
			{ printf("multiplicative-expression:multiplicative-expression ∗ cast-expression\n");}
		|	multiplicative_expression divide cast_expression
			{ printf("multiplicative-expression: multiplicative-expression / cast-expression\n");}
		|	multiplicative_expression mod cast_expression
			{ printf("multiplicative-expression: multiplicative-expression mod cast-expression\n");}
		;

additive_expression
		:	multiplicative_expression
			{ printf("additive-expression: multiplicative-expression\n");}
		|	additive_expression plus	multiplicative_expression
			{ printf("additive-expression: additive-expression + multiplicative-expression\n");}
		|	additive_expression minus multiplicative_expression
			{ printf("additive-expression: additive-expression − multiplicative-expression\n");}
		;

shift_expression
		:	additive_expression
			{ printf("shift-expression: additive-expression\n");}
		|	shift_expression leftleft additive_expression
			{ printf("shift-expression: shift-expression << additive-expression\n");}
		|	shift_expression rightright additive_expression
			{ printf("shift-expression: shift-expression >> additive-expression\n");}
		;

relational_expression
		:	shift_expression
			{ printf("relational-expression: shift-expression\n");}
		|	relational_expression less shift_expression
			{ printf("relational-expression: relational-expression < shift-expression\n");}
		|	relational_expression great shift_expression
			{ printf("relational-expression: relational-expression > shift-expression\n");}
		|	relational_expression lesseq shift_expression
			{ printf("relational-expression: relational-expression <= shift-expression\n");}
		| 	relational_expression greateq shift_expression
			{ printf("relational-expression: relational-expression >= shift-expression\n");}
		;

equality_expression
		:	relational_expression
			{ printf("equality-expression: relational-expression\n");}
		|	equality_expression eq relational_expression
			{ printf("equality-expression: equality-expression == relational-expression\n");}
		|	equality_expression noteq relational_expression
			{ printf("equality-expression: equality-expression != relational-expression\n");}
		;

AND_expression
		:	equality_expression
			{ printf("AND-expression: equality-expression\n");}
		|	AND_expression and equality_expression
			{ printf("AND-expression: AND-expression & equality-expression\n");}
		;

exclusive_OR_expression
		:	AND_expression
			{ printf("exclusive-OR-expression: AND-expression\n");}
		|	exclusive_OR_expression cap AND_expression
			{ printf("exclusive-OR-expression: exclusive-OR-expression ˆ AND-expression\n");}
		;

inclusive_OR_expression
		:	exclusive_OR_expression
			{ printf("inclusive-OR-expression: exclusive-OR-expression\n");}
		|	inclusive_OR_expression or exclusive_OR_expression
			{ printf("inclusive-OR-expression: inclusive-OR-expression | exclusive-OR-expression\n");}
		;

logical_AND_expression
		:	inclusive_OR_expression
			{ printf("logical-AND-expression: inclusive-OR-expression\n");}
		|	logical_AND_expression andand inclusive_OR_expression
			{ printf("logical-AND-expression: ogical-AND-expression && inclusive-OR-expression\n");}
		;

logical_OR_expression
		:	logical_AND_expression
			{ printf("logical-OR-expression: logical-AND-expression\n");}
		|	logical_OR_expression oror logical_AND_expression
			{ printf("logical-OR-expression: logical-OR-expression || logical-AND-expression\n");}
		;

conditional_expression
		:	logical_OR_expression
			{ printf("conditional-expression: logical-OR-expression\n");}
		|	logical_OR_expression question expression colon conditional_expression
			{ printf("conditional-expression: logical-OR-expression ? expression : conditional-expression\n");}
		;

assignment_expression
		:	conditional_expression
			{ printf("assignment-expression: conditional-expression\n");}
		|	unary_expression assignment_operator assignment_expression
			{ printf("assignment-expression: unary-expression assignment-operator assignment-expression\n");}
		;

assignment_operator
		:	assign
			{ printf("assignment-operator: =\n");}
		|	mulass
			{ printf("assignment-operator: *=\n");}
		|	divass
			{ printf("assignment-operator: /=\n");}
		|	modass
			{ printf("assignment-operator: mod=\n");}
		|	plusass
			{ printf("assignment-operator: +=\n");}
		|	minusass
			{ printf("assignment-operator: -=\n");}
		|	leftleftass
			{ printf("assignment-operator: <<=\n");}
		|	rightrightass
			{ printf("assignment-operator: >>=\n");}
		|	andass
			{ printf("assignment-operator: &=\n");}
		|	capass
			{ printf("assignment-operator: ^=\n");}
		|	orass
			{ printf("assignment-operator: |=\n");}
		;

expression
		:	assignment_expression
			{ printf("expression: assignment-expression\n");}
		|	expression comma assignment_expression
			{ printf("expression: expression , assignment-expression\n");}
		;

CONSTANT_expression
		:	conditional_expression
			{ printf("CONSTANT-expression: conditional-expression\n");}
		;


declaration
		:	declaration_specifiers semicolon
			{ printf("declaration: declaration-specifiers ;\n");}
		|	declaration_specifiers init_declarator_list semicolon
			{ printf("declaration: declaration-specifiers init-declarator-list ;\n");}
		;

declaration_specifiers
		:	
			type_specifier
			{ printf("declaration-specifiers: type-specifier\n");}
		|	type_specifier declaration_specifiers
			{ printf("declaration-specifiers: type-specifier declaration-specifiers\n");}
		;

init_declarator_list
		:	init_declarator
			{ printf("init-declarator-list: init-declarator\n");}
		|	init_declarator_list comma init_declarator
			{ printf("init-declarator-list: init-declarator-list , init-declarator\n");}
		;

init_declarator
		:	declarator
			{ printf("init-declarator: declarator\n");}
		|	declarator assign initializer
			{ printf("init-declarator: declarator = initializer\n");}
		;


type_specifier
		:	VOID
			{ printf("type-specifier: VOID\n");}
		|	CHAR
			{ printf("type-specifier: CHAR\n");}
		|	SHORT
			{ printf("type-specifier: SHORT\n");}
		|	INT
			{ printf("type-specifier: INT\n");}
		|	LONG
			{ printf("type-specifier: LONG\n");}
		|	FLOAT
			{ printf("type-specifier: FLOAT\n");}
		|	DOUBLE
			{ printf("type-specifier: DOUBLE\n");}
		|	SIGNED
			{ printf("type-specifier: SIGNED\n");} 
		|	UNSIGNED
			{ printf("type-specifier: UNSIGNED\n");}
		|	BOOL
			{ printf("type-specifier: BOOL\n");}
		|	MATRIX
			{printf("type-specifier: MATRIX\n");}
		;


declarator
		:	pointer direct_declarator
			{ printf("declarator: pointer direct-declarator\n");}
		|	direct_declarator
			{ printf("declarator: direct-declarator\n");}
		;

direct_declarator
		:	IDENTIFIER
			{ printf("direct-declarator: IDENTIFIER\n");}
		|	openbrac declarator closebrac
			{ printf("direct-declarator: ( declarator )\n");}
		|	direct_declarator opensq  assignment_expression_opt	closesq
			{ printf("direct-declarator: direct-declarator [  assignment-expression-opt ]\n");}
		|	direct_declarator openbrac parameter_type_list closebrac
			{ printf("direct-declarator: direct-declarator ( parameter-type-list )\n");}
		|	direct_declarator openbrac IDENTIFIER_list closebrac
			{ printf("direct-declarator: direct-declarator ( IDENTIFIER-list )\n");}
		|	direct_declarator openbrac closebrac
			{ printf("direct-declarator: direct-declarator ( )\n");}
		;

assignment_expression_opt
		:	assignment_expression
			{ printf("assignment_expression_opt: assignment_expression\n");}
		|
			{ printf("assignment_expression_opt: \n");}
		;


pointer
		:	multiply 
			{ printf("pointer: *\n");}
		|	multiply pointer
			{ printf("pointer: * pointer\n");}
		;


parameter_type_list
		:	parameter_list
			{ printf("parameter-type-list: parameter-list\n");}
		;

parameter_list
		:	parameter_declaration
			{ printf("parameter-list: parameter-declaration\n");}
		|	parameter_list comma parameter_declaration
			{ printf("parameter-list: parameter-list , parameter-declaration\n");}
		;

parameter_declaration
		:	declaration_specifiers declarator
			{ printf("parameter-declaration: declaration-specifiers declarator\n");}
		|	declaration_specifiers
			{ printf("parameter-declaration: declaration-specifiers\n");}
		;

IDENTIFIER_list
		:	IDENTIFIER
			{ printf("IDENTIFIER-list: IDENTIFIER\n");}
		|	IDENTIFIER_list comma IDENTIFIER
			{ printf("IDENTIFIER-list: IDENTIFIER-list , IDENTIFIER\n");}
		;


initializer
		:	assignment_expression
			{ printf("initializer: assignment-expression\n");}
		|	opencurly initializer_row_list closecurly
			{ printf("initializer: { initializer-row-list }\n");}
		;
initializer_row_list
		:	initializer_row
			{printf("initializer-row-list : initializer_row\n"); }
		|	initializer_row_list semicolon initializer_row
			{ printf("initializer-row-list: initializer-row-list ; initializer-row\n");}
		;
initializer_row
		:	designation_opt initializer
			{ printf("initializer-row: designation-opt initializer\n");}
		|	initializer_row comma designation_opt initializer
			{ printf("initializer-row: initializer-row , designation-opt initializer\n");}
		;

designation_opt
		:	designation
			{ printf("designation_opt: designation \n");}
		|
			{ printf("designation_opt: \n");}
		;

designation
		:	designator_list assign
			{ printf("designation: designator-list =\n");}
		;

designator_list
		:	designator
			{ printf("designator-list: designator\n");}
		|	designator_list designator
			{ printf("designator-list: designator-list designator\n");}
		;

designator
		:	opensq CONSTANT_expression closesq
			{ printf("designator: [ CONSTANT-expression ]\n");}
		|	fullstop IDENTIFIER
			{ printf("designator: . IDENTIFIER\n");}
		;

statement
		:	labeled_statement
			{ printf("statement: labeled-statement\n");}
		|	compound_statement
			{ printf("statement: compound-statement\n");}
		|	expression_statement
			{ printf("statement: expression-statement\n");}
		|	selection_statement
			{ printf("statement: selection-statement\n");}
		|	iteration_statement
			{ printf("statement: iteration-statement\n");}
		|	jump_statement
			{ printf("statement: jump-statement\n");}
		;

labeled_statement
		:	IDENTIFIER colon statement
			{ printf("labeled-statement: IDENTIFIER : statement\n");}
		|	CASE CONSTANT_expression colon statement
			{ printf("labeled-statement: CASE CONSTANT-expression : statement\n");}
		|	DEFAULT colon statement
			{ printf("labeled-statement: DEFAULT : statement\n");}
		;

compound_statement
		:	opencurly closecurly
			{ printf("compound-statement: { }\n");}
		|	opencurly block_item_list closecurly
			{ printf("compound-statement: { block-item-list }\n");}
		;

block_item_list
		:	block_item
			{ printf("block-item-list: block-item\n");}
		|	block_item_list block_item
			{ printf("block-item-list: block-item-list block-item\n");}
		;

block_item
		:	declaration
			{ printf("block-item: declaration\n");}
		|	statement
			{ printf("block-item: statement\n");}
		;

expression_statement
		:	expression_opt semicolon
			{ printf("expression-statement: expression-opt;\n");}
		;

expression_opt
		:	expression
			{ printf("expression-opt: expression\n");}
		|
			{ printf("expression-opt: \n");}
		;

selection_statement
		:	IF openbrac expression closebrac statement
			{ printf("selection-statement: IF ( expression ) statement\n");}
		|	IF openbrac expression closebrac statement ELSE statement
			{ printf("selection-statement: IF ( expression ) statement ELSE statement\n");}
		|	SWITCH openbrac expression closebrac statement
			{ printf("selection-statement: SWITCH ( expression ) statement\n");}
		;

iteration_statement
		:	WHILE openbrac expression closebrac statement
			{ printf("iteration-statement: WHILE ( expression ) statement\n");}
		|   DO statement WHILE openbrac expression closebrac semicolon
			{ printf("iteration-statement: DO statement WHILE ( expression ) ;\n");}
		|	FOR openbrac expression_opt semicolon expression_opt semicolon expression_opt closebrac statement
			{ printf("iteration-statement: FOR ( expression-opt ; expression-opt ; expression-opt ) statement\n");}
		|	FOR openbrac declaration expression_opt semicolon expression_opt closebrac statement
			{ printf("iteration-statement: FOR ( declaration expression-opt ; expression-opt ) statement\n");}
		;

jump_statement
		:	GOTO IDENTIFIER semicolon
			{ printf("jump-statement: GOTO IDENTIFIER ;\n");}
		|	CONTINUE semicolon
			{ printf("jump-statement: CONTINUE ;\n");}
		|	BREAK semicolon
			{ printf("jump-statement: BREAK ;\n");}
		|	RETURN expression_opt semicolon
			{ printf("jump-statement: RETURN expression-opt ;\n");}
		;

translation_unit
		:	external_declaration
			{ printf("translation-unit: external-declaration\n");}
		|	translation_unit external_declaration
			{ printf("translation-unit: translation-unit external-declaration\n");}
		;

external_declaration
		:	function_definiton
			{ printf("external-declaration: function-definition\n");}
		|	declaration
			{ printf("external-declaration: declaration\n");}
		;

function_definiton
		:	declaration_specifiers declarator compound_statement
			{ printf("function-definition: declaration-specifiers declarator compound-statement\n");}
		|	declaration_specifiers declarator declaration_list compound_statement
			{ printf("function-definition: declaration-specifiers declarator declaration-list compound-statement\n");}
		;

declaration_list
		:	declaration
			{ printf("declaration-list: declaration\n");}
		|	declaration_list declaration
			{ printf("declaration-list: declaration-list declaration\n");}
		;

%%

int yyerror(char *s){
  printf("Parser Error : %s\n",s);
  return -1;
}





%{
	#include <stdio.h>
	#include <ctype.h>
	#include <string>
	#include "ass4_15CS30031_translator.h"
	int yyerror(string);
	extern char *yytext;
	extern int yylex();
	extern basicType TYPE;
	vector <string> allstrings;
%}


%start translation_unit

%union {
	char charval;
	int intval;
	int instr;
	int tnewp;
	char* strval;
	float floatval;
	symbolEntry* symbolEntryPointer;
	expr* exp;
	intlist* nl;
	symbolType* st;
	char tnewchar;
	statement* stat;
	unary* A;
	char uop;	//unary operator
}

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

%token <symbolEntryPointer> IDENTIFIER
%token <charval> char_CONSTANT
%token <intval> int_CONSTANT 
%token <strval> double_CONSTANT
%token <strval> STRINGLITERAL

%token OPENCURLY
%token CLOSECURLY
%token OPENSQ
%token CLOSESQ
%token OPENBRAC
%token CLOSEBRAC
%token FULLSTOP
%token ARROW
%token PLUSPLUS
%token MINUSMINUS
%token AND
%token MULTIPLY
%token PLUS
%token MINUS
%token WAVE
%token NEGATE
%token DIVIDE
%token MOD
%token LEFTLEFT
%token RIGHTRIGHT
%token LESS
%token GREAT
%token LESSEQ
%token GREATEQ
%token EQ
%token NOTEQ
%token CAP
%token OR
%token ANDAND
%token OROR
%token QUESTION
%token COLON
%token SEMICOLON
%token ASSIGN
%token MULASS
%token DIVASS
%token MODASS
%token PLUSASS
%token MINUSASS
%token LEFTLEFTASS
%token RIGHTRIGHTASS
%token ANDASS
%token CAPASS
%token ORASS
%token COMMA
%token HASH
%token TRANS

%type <A> postfix_expression
	unary_expression
	cast_expression

%type <exp>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	AND_expression
	exclusive_OR_expression
	inclusive_OR_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement

%type <uop> unary_operator
%type <symbolEntryPointer> CONSTANT initializer

%type <instr> address_of_next_instruction
%type <exp> goto_from_this_instruction
%type <st> pointer

%type <symbolEntryPointer> direct_declarator init_declarator declarator
%type <intval> argument_expression_list

%type <stat>  statement
	labeled_statement 
	compound_statement
	selection_statement
	iteration_statement
	jump_statement
	block_item
	block_item_list

%%
primary_expression 
		:	IDENTIFIER
			{ 
				$$ = new expr();
				$$->symbolEntryPointer = $1;
				$$->isBoolean = false;
			
				printf("primary-expression: %s\n",yytext);
			}
		|	CONSTANT
			{
				$$ = new expr();
				$$->symbolEntryPointer = $1;
				printf("primary-expression : CONSTANT\n");
			}
		| 	STRINGLITERAL
			{ 
				$$ = new expr();
				$$->symbolEntryPointer = gentemp(_PTR, $1);
				$$->symbolEntryPointer->type->ptr = new symbolType(_CHAR);
				$$->symbolEntryPointer->initialize($1);
				allstrings.push_back($1);
				emit(EQLSTR, $$->symbolEntryPointer->name, intToString (allstrings.size()-1));
		    
	            printf("primary-expression: STRINGLITERAL\n");
            }
		|	OPENBRAC expression CLOSEBRAC
			{ 
				$$ = $2;

				printf("primary-expression: ( expression )\n");
			}
		;

CONSTANT
		:	char_CONSTANT
			{ 
				$$ = gentemp(_CHAR, charToString($1));
				emit(EQLCHAR, $$->name,$1);
				
				printf("primary-expression: char_CONSTANT\n");
			}
		|	int_CONSTANT
			{ 
				$$ = gentemp(_INT, numberToString($1));
				emit(EQL, $$->name, $1);

				printf("primary-expression: int_CONSTANT\n");
			}
		|	double_CONSTANT
			{ 
				$$ = gentemp(_DOUBLE, *new string($1));
				emit(EQL, $$->name, *new string($1));

				printf("primary-expression: double_CONSTANT\n");
			}
		;

postfix_expression
		:	primary_expression
			{
				$$ = new unary ();
				$$->symbolEntryPointer = $1->symbolEntryPointer;
				$$->loc = $$->symbolEntryPointer;
				$$->type = $1->symbolEntryPointer->type;
				
				printf("postfix-expression: primary-expression\n");
			}
		|	postfix_expression OPENSQ expression CLOSESQ OPENSQ expression CLOSESQ//////////////////////
			{
				$$ = new unary();
				$$->symbolEntryPointer = new symbolEntry($1->symbolEntryPointer->name, $1->symbolEntryPointer->type->bastype, $1->symbolEntryPointer->type->ptr, $1->symbolEntryPointer->type->row, $1->symbolEntryPointer->type->column);
				//$$->symbolEntryPointer = $1->symbolEntryPointer;			//copy the base
				$$->bastype = _DOUBLE;		//type = type of element
				$$->type = new symbolType($$->bastype);
				if(($3->symbolEntryPointer->init!="")&&($6->symbolEntryPointer->init!="")){
					$$->loc = gentemp(_INT);		//store computed address
					table->computeOffsets();
					int off = $1->symbolEntryPointer->offset;

					symbolEntry *t = gentemp(_INT);
					t->init = numberToString((stoi($3->symbolEntryPointer->init)-1) * $1->type->column);
					emit(MULT, t->name, $3->symbolEntryPointer->name, numberToString($1->type->column));
					symbolEntry *t1 = gentemp(_INT);
					t1->init = numberToString(stoi($6->symbolEntryPointer->init) + stoi(t->init));
		 			emit(ADD, t1->name, t->name, $6->symbolEntryPointer->name);
					symbolEntry *t2 = gentemp(_INT);
					t2->init = numberToString(stoi(t1->init) * sizeOfType($$->type));
		 			emit(MULT, t2->name, t1->name, numberToString(sizeOfType($$->type)));		//$$ should be of type _DOUBLE
		 			$$->loc->init=numberToString($1->loc->offset+stoi(t2->init));
					emit (ADD, $$->loc->name, $1->loc->name, t2->name);

					symbolEntry* t3 = table->lookOff(stoi($$->loc->init));
						cout<<t3->init<<endl;
						$$->symbolEntryPointer->init = t3->init;

				}


				printf("postfix-expression: postfix-expression [ expression ] [ expression ]\n");
			}
		|	postfix_expression OPENSQ expression CLOSESQ
			{ 
				$$ = new unary();
				
				$$->symbolEntryPointer = $1->symbolEntryPointer;			//copy the base
				$$->type = $1->type->ptr;		//type = type of element
				$$->loc = gentemp(_INT);		//store computed address
				
				//New address = already computed + $3 * new width
				if ($1->bastype==_ARR) {		//if something already computed
					symbolEntry *t = gentemp(_INT);
		 			emit(MULT, t->name, $3->symbolEntryPointer->name, numberToString(sizeOfType($$->type)));
					emit (ADD, $$->loc->name, $1->loc->name, t->name);

				}
		 		else {
			 		emit(MULT, $$->loc->name, $3->symbolEntryPointer->name, numberToString(sizeOfType($$->type)));
		 		}

				printf("postfix-expression: postfix-expression [ expression ]\n");
			}
		|	postfix_expression OPENBRAC CLOSEBRAC
			{ printf("postfix-expression: postfix-expression ( )\n");
			}
		|	postfix_expression OPENBRAC argument_expression_list CLOSEBRAC
			{ 
				//function call
				$$ = new unary();
				$$->symbolEntryPointer = gentemp($1->type->bastype);
				emit(CALL, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, intToString($3));
		  		
				printf("postfix-expression: postfix-expression ( argument-expression-list )\n");
			}
		|	postfix_expression FULLSTOP IDENTIFIER
			{ printf("postfix-expression: postfix-expression . IDENTIFIER\n");
			}
		|	postfix_expression ARROW IDENTIFIER
			{ printf("postfix-expression: postfix-expression −> IDENTIFIER\n");
			}
		|	postfix_expression PLUSPLUS
			{
				$$ = new unary();

				//copy $1 to $$
				$$->symbolEntryPointer = gentemp($1->symbolEntryPointer->type->bastype);
				emit (EQL, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name);

				//Increment $1
				emit (ADD, $1->symbolEntryPointer->name, $1->symbolEntryPointer->name, "1");

				printf("postfix-expression: postfix-expression ++\n");
			}
		|	postfix_expression MINUSMINUS
			{ 
				$$ = new unary();

				//copy $1 to $$
				$$->symbolEntryPointer = gentemp($1->symbolEntryPointer->type->bastype);
				emit (EQL, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name);

				//Decrement $1
				emit (SUB, $1->symbolEntryPointer->name, $1->symbolEntryPointer->name, "1");

				printf("postfix-expression: postfix-expression −−\n");
				}
		|	postfix_expression TRANS
			{ printf("postfix-expression: postfix-expression .'\n");
			}
		;


argument_expression_list
		:	assignment_expression
			{ 
				emit (PARAM, $1->symbolEntryPointer->name);
				$$ = 1;

				printf("argument-expression-list: assignment-expression\n");
			}
		|	argument_expression_list COMMA assignment_expression
			{ 
				emit (PARAM, $3->symbolEntryPointer->name);
				$$ = $1+1;

				printf("argument-expression-list: argument-expression-list , assignment-expression\n");
			}
		;

unary_expression
		:	postfix_expression
			{ 
				$$ = $1;
				printf("unary-expression: postfix-expression\n");
			}
		|	PLUSPLUS unary_expression
			{ 
				emit (ADD, $2->symbolEntryPointer->name, $2->symbolEntryPointer->name, "1");		//Increment $2
				$$ = $2;

				printf("unary-expression: ++ unary-expression\n");
			}
		|	MINUSMINUS unary_expression
			{ 
				emit (SUB, $2->symbolEntryPointer->name, $2->symbolEntryPointer->name, "1");		//Decrement $2
				$$ = $2;

				printf("unary-expression: −− unary-expression\n");
			}
		|	unary_operator cast_expression
			{ 
				$$ = new unary();
				switch ($1) {///////////////////////////////////////////////////add something for Matrix??
					case '&':
						$$->symbolEntryPointer = gentemp(_PTR);
						$$->symbolEntryPointer->type->ptr = $2->symbolEntryPointer->type; 
						emit (ADDRESS, $$->symbolEntryPointer->name, $2->symbolEntryPointer->name);
						
						break;
					case '*':
						$$->bastype = _PTR;
						
						$$->loc = gentemp ($2->symbolEntryPointer->type->ptr);
						emit (PTRR, $$->loc->name, $2->symbolEntryPointer->name);
						$$->symbolEntryPointer = $2->symbolEntryPointer;
						
						break;
					case '+':
						$$ = $2;
						
						break;
					case '-':
						$$->symbolEntryPointer = gentemp($2->symbolEntryPointer->type->bastype);
						emit (UMINUS, $$->symbolEntryPointer->name, $2->symbolEntryPointer->name);
						
						break;
					default:
				
						break;
				}

				printf("unary-expression: unary-operator cast-expression\n");
			}
		;

unary_operator
		:	AND
			{ 
				$$ = '&';

				printf("unary-operator: &\n");
			}
		|	MULTIPLY
			{
				$$ = '*';

				printf("unary-operator: *\n");
			}
		|	PLUS
			{ 
				$$ = '+';

				printf("unary-operator: +\n");
			}
		|	MINUS
			{ 
				$$ = '-';
				printf("unary-operator: -\n");
			}
		;

cast_expression
		:	unary_expression
			{ 
				$$ = $1;
				printf("cast-expression: unary-expression\n");
			}
		;

multiplicative_expression
		:	cast_expression
			{ 
				//Now the cast expression can't go to LHS of assignment_expression
				//So we can safely store the rvalues of pointer and arrays in temporary
				//We don't need to carry lvalues anymore
				$$ = new expr();
				if ($1->bastype==_ARR) {
					$$->symbolEntryPointer = gentemp($1->loc->type);
					emit(ARRR, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $1->loc->name);
				}
				
				else if ($1->bastype==_PTR) {
					$$->symbolEntryPointer = $1->loc;
				}
				else {
					$$->symbolEntryPointer = $1->symbolEntryPointer;
				}

				printf("multiplicative-expression: cast-expression\n");
			}
		|	multiplicative_expression MULTIPLY cast_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					$$ = new expr();
					$$->symbolEntryPointer = gentemp($1->symbolEntryPointer->type->bastype);
					$$->symbolEntryPointer->init = numberToString(stoi($1->symbolEntryPointer->init) * stoi($3->symbolEntryPointer->init));
					emit (MULT, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;

				printf("multiplicative-expression:multiplicative-expression ∗ cast-expression\n");
			}
		|	multiplicative_expression DIVIDE cast_expression
			{
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					$$ = new expr();
					$$->symbolEntryPointer = gentemp($1->symbolEntryPointer->type->bastype);
					$$->symbolEntryPointer->init = numberToString(stoi($1->symbolEntryPointer->init) / stoi($3->symbolEntryPointer->init));
					emit (DIV, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;

				printf("multiplicative-expression: multiplicative-expression / cast-expression\n");
			}
		|	multiplicative_expression MOD cast_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					$$ = new expr();
					$$->symbolEntryPointer = gentemp($1->symbolEntryPointer->type->bastype);
					$$->symbolEntryPointer->init = numberToString(stoi($1->symbolEntryPointer->init) % stoi($3->symbolEntryPointer->init));
					emit (MODOP, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;

				printf("multiplicative-expression: multiplicative-expression MOD cast-expression\n");
			}
		;

additive_expression
		:	multiplicative_expression
			{ 
				$$ = $1;
				printf("additive-expression: multiplicative-expression\n");
				}
		|	additive_expression PLUS multiplicative_expression
			{ 
				cout<<$1->symbolEntryPointer->init<<" "<<$3->symbolEntryPointer->init<<endl;
				if (typecheck($1->symbolEntryPointer, $3->symbolEntryPointer)) {
					$$ = new expr();
					$$->symbolEntryPointer = gentemp($1->symbolEntryPointer->type->bastype);
					$$->symbolEntryPointer->init = numberToString(stoi($1->symbolEntryPointer->init) + stoi($3->symbolEntryPointer->init));
					emit (ADD, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;
				printf("additive-expression: additive-expression + multiplicative-expression\n");
			}
		|	additive_expression MINUS multiplicative_expression
			{ 
				if (typecheck($1->symbolEntryPointer, $3->symbolEntryPointer)) {
					$$ = new expr();
					$$->symbolEntryPointer = gentemp($1->symbolEntryPointer->type->bastype);
					$$->symbolEntryPointer->init = numberToString(stoi($1->symbolEntryPointer->init) - stoi($3->symbolEntryPointer->init));
					emit (ADD, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;

				printf("additive-expression: additive-expression − multiplicative-expression\n");
			}
		;

shift_expression
		:	additive_expression
			{ 
				$$ = $1;

				printf("shift-expression: additive-expression\n");
			}
		|	shift_expression LEFTLEFT additive_expression
			{ 
				if ($3->symbolEntryPointer->type->bastype == _INT) {
					$$ = new expr();
					$$->symbolEntryPointer = gentemp (_INT);
					emit (LEFTOP, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;
				
				printf("shift-expression: shift-expression << additive-expression\n");
			}
		|	shift_expression RIGHTRIGHT additive_expression
			{ 
				if ($3->symbolEntryPointer->type->bastype == _INT) {
					$$ = new expr();
					$$->symbolEntryPointer = gentemp (_INT);
					emit (RIGHTOP, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;

				printf("shift-expression: shift-expression >> additive-expression\n");
			}
		;

relational_expression
		:	shift_expression
			{ 
				$$ = $1;

				printf("relational-expression: shift-expression\n");
			}
		|	relational_expression LESS shift_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					//New bool
					$$ = new expr();
					$$->isBoolean = true;

					$$->trueList = makelist (nextInstr());
					$$->falseList = makelist (nextInstr()+1);
					emit(LT, "", $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
					emit (GOTOOP, "");
				}
				else cout << "Type Error"<< endl;

				printf("relational-expression: relational-expression < shift-expression\n");
			}
		|	relational_expression GREAT shift_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					//New bool
					$$ = new expr();
					$$->isBoolean = true;

					$$->trueList = makelist (nextInstr());
					$$->falseList = makelist (nextInstr()+1);
					emit(GT, "", $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
					emit (GOTOOP, "");
				}
				else cout << "Type Error"<< endl;

				printf("relational-expression: relational-expression > shift-expression\n");
			}
		|	relational_expression LESSEQ shift_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					//New bool
					$$ = new expr();
					$$->isBoolean = true;

					$$->trueList = makelist (nextInstr());
					$$->falseList = makelist (nextInstr()+1);
					emit(LE, "", $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
					emit (GOTOOP, "");
				}
				else cout << "Type Error"<< endl;
				
				printf("relational-expression: relational-expression <= shift-expression\n");
			}
		| 	relational_expression GREATEQ shift_expression
			{ 	
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
				//New bool
				$$ = new expr();
				$$->isBoolean = true;

				$$->trueList = makelist (nextInstr());
				$$->falseList = makelist (nextInstr()+1);
				emit(GE, "", $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				emit (GOTOOP, "");
			}
			else cout << "Type Error"<< endl;

			printf("relational-expression: relational-expression >= shift-expression\n");
			}
		;

equality_expression
		:	relational_expression
			{ 
				$$ = $1;

				printf("equality-expression: relational-expression\n");
			}
		|	equality_expression EQ relational_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
				//If any is bool get its value
				convertfrombool ($1);
				convertfrombool ($3);
				
				$$ = new expr();
				$$->isBoolean = true;
				
				$$->trueList = makelist (nextInstr());
				$$->falseList = makelist (nextInstr()+1);
				emit (EQOP, "", $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				emit (GOTOOP, "");
			}
			else cout << "Type Error"<< endl;

			printf("equality-expression: equality-expression == relational-expression\n");
		}
		|	equality_expression NOTEQ relational_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
				//If any is bool get its value
				convertfrombool ($1);
				convertfrombool ($3);
				
				$$ = new expr();
				$$->isBoolean = true;
				
				$$->trueList = makelist (nextInstr());
				$$->falseList = makelist (nextInstr()+1);
				emit (NEOP, "", $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				emit (GOTOOP, "");
			}
			else cout << "Type Error"<< endl;

				printf("equality-expression: equality-expression != relational-expression\n");
			}
		;

AND_expression
		:	equality_expression
			{ 
				$$ = $1;

				printf("AND-expression: equality-expression\n");
			}
		|	AND_expression AND equality_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					$$ = new expr();
					$$->isBoolean = false;

					$$->symbolEntryPointer = gentemp (_INT);
					emit (BAND, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;

				printf("AND-expression: AND-expression & equality-expression\n");
			}
		;

exclusive_OR_expression
		:	AND_expression
			{ 
				$$ = $1;

				printf("exclusive-OR-expression: AND-expression\n");
			}
		|	exclusive_OR_expression CAP AND_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					//If any is bool get its value
					convertfrombool ($1);
					convertfrombool ($3);

					$$ = new expr();
					$$->isBoolean = false;

					$$->symbolEntryPointer = gentemp (_INT);
					emit (XOR, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;
				printf("exclusive-OR-expression: exclusive-OR-expression ˆ AND-expression\n");
			}
		;

inclusive_OR_expression
		:	exclusive_OR_expression
			{ 
				$$ = $1;

				printf("inclusive-OR-expression: exclusive-OR-expression\n");
			}
		|	inclusive_OR_expression OR exclusive_OR_expression
			{ 
				if (typecheck ($1->symbolEntryPointer, $3->symbolEntryPointer) ) {
					//If any is bool get its value
					convertfrombool ($1);
					convertfrombool ($3);

					$$ = new expr();
					$$->isBoolean = false;
					
					$$->symbolEntryPointer = gentemp (_INT);
					emit (INOR, $$->symbolEntryPointer->name, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
				}
				else cout << "Type Error"<< endl;
				printf("inclusive-OR-expression: inclusive-OR-expression | exclusive-OR-expression\n");
			}
		;

logical_AND_expression
		:	inclusive_OR_expression
			{ 
				$$ = $1;

				printf("logical-AND-expression: inclusive-OR-expression\n");
			}
		|	logical_AND_expression goto_from_this_instruction ANDAND address_of_next_instruction inclusive_OR_expression
			{ 
				convert2bool($5);

				//goto_from_this_instruction to convert $1 to bool
				backpatch($2->nextList, nextInstr());
				convert2bool($1);

				$$ = new expr();
				$$->isBoolean = true;

				backpatch($1->trueList, $4);
				$$->trueList = $5->trueList;
				$$->falseList = merge ($1->falseList, $5->falseList);

				printf("logical-AND-expression: ogical-AND-expression && inclusive-OR-expression\n");
			}
		;

logical_OR_expression
		:	logical_AND_expression
			{ 
				$$ = $1;

				printf("logical-OR-expression: logical-AND-expression\n");
			}
		|	logical_OR_expression goto_from_this_instruction OROR address_of_next_instruction logical_AND_expression
			{ 
				convert2bool($5);

				//goto_from_this_instruction to convert $1 to bool
				backpatch($2->nextList, nextInstr());
				convert2bool($1);

				$$ = new expr();
				$$->isBoolean = true;

				backpatch ($1->falseList, $4);
				$$->trueList = merge ($1->trueList, $5->trueList);
				$$->falseList = $5->falseList;

				printf("logical-OR-expression: logical-OR-expression || logical-AND-expression\n");
			}
		;

address_of_next_instruction 	: %empty{	//To store the address of the next instruction for further use.
		$$ = nextInstr();
	};

goto_from_this_instruction 	: %empty { 	//Non terminal to prevent fallthrough by emitting a goto
		
		$$  = new expr();
		$$->nextList = makelist(nextInstr());
		emit (GOTOOP,"");
	
	}

conditional_expression
		:	logical_OR_expression
			{ 
				$$ = $1;

				printf("conditional-expression: logical-OR-expression\n");
			}
		|	logical_OR_expression goto_from_this_instruction QUESTION address_of_next_instruction expression goto_from_this_instruction COLON address_of_next_instruction conditional_expression
			{ 
				convert2bool($5);
				$$->symbolEntryPointer = gentemp();
				$$->symbolEntryPointer->update($5->symbolEntryPointer->type);
				emit(EQL, $$->symbolEntryPointer->name, $9->symbolEntryPointer->name);
				intlist l = makelist(nextInstr());
				emit (GOTOOP, "");

				backpatch($6->nextList, nextInstr());
				emit(EQL, $$->symbolEntryPointer->name, $5->symbolEntryPointer->name);
				intlist m = makelist(nextInstr());
				l = merge (l, m);
				emit (GOTOOP, "");

				backpatch($2->nextList, nextInstr());
				convert2bool ($1);
				backpatch ($1->trueList, $4);
				backpatch ($1->falseList, $8);
				backpatch (l, nextInstr());

				printf("conditional-expression: logical-OR-expression ? expression : conditional-expression\n");
			}
		;

assignment_expression
		:	conditional_expression
			{ 
				$$ = $1;

				printf("assignment-expression: conditional-expression\n");
			}
		|	unary_expression assignment_operator assignment_expression
			{ 
				if((TYPE == _MATRIX)&&($1->loc->init!="")){
					symbolEntry* t = table->lookOff(stoi($1->loc->init));
						cout<<t->init<<endl;
						cout<<$3->symbolEntryPointer->name<<" "<<$3->symbolEntryPointer->init<<"replacing"<<$1->loc->name<<" "<<$1->loc->init<<endl;
						t->init = $3->symbolEntryPointer->init;
						emit(EQL, t->name, $3->symbolEntryPointer->name);
						
				}
				else{
					switch ($1->bastype) {
						case _ARR:
							$3->symbolEntryPointer = convert($3->symbolEntryPointer, $1->type->bastype);
							emit(ARRL, $1->symbolEntryPointer->name, $1->loc->name, $3->symbolEntryPointer->name);	
							break;
						case _PTR:
							emit(PTRL, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);	
							break;
						
						default:
							$3->symbolEntryPointer = convert($3->symbolEntryPointer, $1->symbolEntryPointer->type->bastype);
							emit(EQL, $1->symbolEntryPointer->name, $3->symbolEntryPointer->name);
							break;
					}
				}
				$$ = $3;

				printf("assignment-expression: unary-expression assignment-operator assignment-expression\n");
			}
		;

assignment_operator	//IGNORED
		:	ASSIGN
			{ printf("assignment-operator: =\n");
			}
		|	MULASS
			{ printf("assignment-operator: *=\n");
			}
		|	DIVASS
			{ printf("assignment-operator: /=\n");
			}
		|	MODASS
			{ printf("assignment-operat	or: MOD=\n");
			}
		|	PLUSASS
			{ printf("assignment-operator: +=\n");
			}
		|	MINUSASS
			{ printf("assignment-operator: -=\n");
			}
		|	LEFTLEFTASS
			{ printf("assignment-operator: <<=\n");
			}
		|	RIGHTRIGHTASS
			{ printf("assignment-operator: >>=\n");
			}
		|	ANDASS
			{ printf("assignment-operator: &=\n");
			}
		|	CAPASS
			{ printf("assignment-operator: ^=\n");
			}
		|	ORASS
			{ printf("assignment-operator: |=\n");
			}
		;

expression
		:	assignment_expression
			{ 
				$$ = $1;
				
				printf("expression: assignment-expression\n");
			}
		|	expression COMMA assignment_expression
			{ 
				printf("expression: expression , assignment-expression\n");
			}
		;

constant_expression
		:	conditional_expression
			{ 
				printf("constant-expression: conditional-expression\n");
			}
		;


declaration
		:	declaration_specifiers SEMICOLON
			{ 
				printf("declaration: declaration-specifiers ;\n");
			}
		|	declaration_specifiers init_declarator_list SEMICOLON
			{ 
				printf("declaration: declaration-specifiers init-declarator-list ;\n");
			}
		;

declaration_specifiers
		:	
			type_specifier
			{ 
				printf("declaration-specifiers: type-specifier\n");
			}
		|	type_specifier declaration_specifiers
			{ 
				printf("declaration-specifiers: type-specifier declaration-specifiers\n");
			}
		;

init_declarator_list
		:	init_declarator
			{ 
				printf("init-declarator-list: init-declarator\n");
			}
		|	init_declarator_list COMMA init_declarator
			{ 
				printf("init-declarator-list: init-declarator-list , init-declarator\n");
			}
		;

init_declarator
		:	declarator
			{ 
				$$ = $1;

				printf("init-declarator: declarator\n");
			}
		|	declarator ASSIGN initializer
			{ 
				
				if($1->type->bastype!=_MATRIX){
					if ($3->init!="") $1->initialize($3->init);
					emit (EQL, $1->name, $3->name);	

				}

				printf("init-declarator: declarator = initializer\n");
			}
		;


type_specifier
		:	VOID
			{ 
				TYPE = _VOID;

				printf("type-specifier: VOID\n");
			}
		|	CHAR
			{ 
				TYPE = _CHAR;

				printf("type-specifier: CHAR\n");
			}
		|	SHORT
			{ printf("type-specifier: SHORT\n");
			}
		|	INT
			{ 
				TYPE = _INT;

				printf("type-specifier: INT\n");
			}
		|	LONG
			{ printf("type-specifier: LONG\n");
			}
		|	FLOAT
			{ printf("type-specifier: FLOAT\n");
			}
		|	DOUBLE
			{ 
				TYPE = _DOUBLE;

				printf("type-specifier: DOUBLE\n");
			}
		|	SIGNED
			{ printf("type-specifier: SIGNED\n");
			} 
		|	UNSIGNED
			{ printf("type-specifier: UNSIGNED\n");
			}
		|	BOOL
			{ 
				printf("type-specifier: BOOL\n");
			}
		|	MATRIX
			{
				TYPE = _MATRIX;

				printf("type-specifier: MATRIX\n");
			}
		;


declarator
		:	pointer direct_declarator
			{ 
				symbolType *t = $1;
				while (t->ptr !=NULL) t = t->ptr;
				t->ptr = $2->type;
				$$ = $2->update($1);

				printf("declarator: pointer direct-declarator\n");
			}
		|	direct_declarator
			{ printf("declarator: direct-declarator\n");
			}
		;

direct_declarator
		:	IDENTIFIER
			{ 
				$$ = $1->update(TYPE);
				curSymEntry = $$;		//latest function entry in the symbol table

				printf("direct-declarator: IDENTIFIER\n");
			}
		|	OPENBRAC declarator CLOSEBRAC
			{ 
				$$ = $2;

				printf("direct-declarator: ( declarator )\n");
			}
		|	direct_declarator OPENSQ assignment_expression CLOSESQ OPENSQ assignment_expression CLOSESQ
			{
					$1->type->row = atoi($3->symbolEntryPointer->init.c_str());
						$1->type->column = atoi($6->symbolEntryPointer->init.c_str());
						$$ = $1->update ($1->type);

				printf("direct-declarator: direct-declarator [ assignment-expression ] [ asignment-expression ]\n");
			}
		|	direct_declarator OPENSQ assignment_expression CLOSESQ
			{ 
				symbolType *t = $1 -> type;
				symbolType *prev = NULL;
				if(t->bastype == _ARR) {
					while (t->bastype == _ARR) {
						prev = t;
						t = t->ptr;
					}
					if (prev==NULL) {
						int x = atoi($3->symbolEntryPointer->init.c_str());
						symbolType *s = new symbolType(_ARR, $1->type, x);
						int y = sizeOfType(s);
						$$ = $1->update(s);
					}
					else {
						prev->ptr =  new symbolType(_ARR, t, atoi($3->symbolEntryPointer->init.c_str()));
						$$ = $1->update ($1->type);
					}
				}
				printf("direct-declarator: direct-declarator [ assignment-expression ]\n");
			}
		|	direct_declarator OPENSQ CLOSESQ OPENSQ CLOSESQ
			{
				$$ = $1->update ($1->type);
					
			}	
		| 	direct_declarator OPENSQ CLOSESQ 
			{
				symbolType *t = $1 -> type;
				symbolType *prev = NULL;
				if(t->bastype == _ARR) {
					while (t->bastype == _ARR) {
						prev = t;
						t = t->ptr;
					}
					if (prev==NULL) {
						symbolType *s = new symbolType(_ARR, $1->type, 0);
						int y = sizeOfType(s);
						$$ = $1->update(s);
					}
					else {
						prev->ptr =  new symbolType(_ARR, t, 0);
						$$ = $1->update ($1->type);
					}
				}
			}
		|	direct_declarator OPENBRAC CST parameter_type_list CLOSEBRAC
			{ 
				table->tableName = $1->name;

				if ($1->type->bastype !=_VOID) {
					symbolEntry *s = table->lookup("retVal");
					s->update($1->type);		
				}

				$1 = $1->linkSymTab(table);

				table->parent = globTable;
				//changeTable (globTable);				//Come back to globalsymbol table
			
				curSymEntry = $$;

				printf("direct-declarator: direct-declarator ( parameter-type-list )\n");
			}
		|	direct_declarator OPENBRAC IDENTIFIER_list CLOSEBRAC
			{ printf("direct-declarator: direct-declarator ( IDENTIFIER-list )\n");
			}
		|	direct_declarator OPENBRAC CST CLOSEBRAC
			{ 
				table->tableName = $1->name;

				if ($1->type->bastype !=_VOID) {
					symbolEntry *s = table->lookup("retVal");
					s->update($1->type);		
				}

				$1 = $1->linkSymTab(table);

				table->parent = globTable;
				//changeTable (globTable);			//Come back to globalsymbol table
	
				curSymEntry = $$;

				printf("direct-declarator: direct-declarator ( )\n");
			}
		;

CST : %empty { //Used for changing to symbol table for a function
		if (curSymEntry->nestedTable==NULL) changeTable(new symbolTable(""));	//Function symbol table doesn't already exist
		else {
			changeTable (curSymEntry ->nestedTable);						//Function symbol table already exists
			emit (FUNC, table->tableName);
		}
	}
	;


pointer
		:	MULTIPLY 
			{ 
				$$ = new symbolType(_PTR);

				printf("pointer: *\n");
			}
		|	MULTIPLY pointer
			{ 
				$$ = new symbolType(_PTR, $2);

				printf("pointer: * pointer\n");
			}
		;


parameter_type_list
		:	parameter_list
			{ printf("parameter-type-list: parameter-list\n");
			}
		;

parameter_list
		:	parameter_declaration
			{ printf("parameter-list: parameter-declaration\n");
			}
		|	parameter_list COMMA parameter_declaration
			{ printf("parameter-list: parameter-list , parameter-declaration\n");
			}
		;

parameter_declaration
		:	declaration_specifiers declarator
			{ 
				$2->category = "param";

				printf("parameter-declaration: declaration-specifiers declarator\n");
			}
		|	declaration_specifiers
			{ printf("parameter-declaration: declaration-specifiers\n");
			}
		;

IDENTIFIER_list
		:	IDENTIFIER
			{ printf("IDENTIFIER-list: IDENTIFIER\n");
			}
		|	IDENTIFIER_list COMMA IDENTIFIER
			{ printf("IDENTIFIER-list: IDENTIFIER-list , IDENTIFIER\n");
			}
		;


initializer
		:	assignment_expression
			{ 
				$$ = $1->symbolEntryPointer;
				if(TYPE == _MATRIX){
					table->computeOffsets();
					$$->type->bastype = _DOUBLE;
					$$->size = SIZEOF_DOUBLE;
					$$->offset = curSymEntry->offset + (2*SIZEOF_INT) + (curSymEntry->c * SIZEOF_DOUBLE);
					emit(ARRL, curSymEntry->name, numberToString(curSymEntry->c), $$->name);
					curSymEntry->c++;
					//cout<<curSymEntry->c<<endl;
					//$$->offset = curSymEntry->offset + (curSymEntry->c * $$->size);
					//curSymEntry->c++;
				}
				printf("initializer: assignment-expression\n");
			}
		|	OPENCURLY initializer_row_list CLOSECURLY
			{ printf("initializer: { initializer-row-list }\n");
			}
		;
initializer_row_list
		:	initializer_row
			{printf("initializer-row-list : initializer_row\n"); 
			}
		|	initializer_row_list SEMICOLON initializer_row
			{ printf("initializer-row-list: initializer-row-list ; initializer-row\n");
			}
		;
initializer_row
		:	designation initializer
			{ printf("initializer-row: designation initializer\n");
			}
		|	initializer
			{
				//symbolEntry *t = gentemp($1->type,$1->init.c_str());
				//emit(EQL, t->name, atoi($1->init.c_str()));
			}
		|	initializer_row COMMA designation initializer
			{ printf("initializer-row: initializer-row , designation initializer\n");
			}
		|	initializer_row COMMA initializer
			{
				//symbolEntry *t = gentemp($3->type,$3->init.c_str());
				//emit(EQL, t->name, atoi($3->init.c_str()));
			}
		;

designation
		:	designator_list ASSIGN
			{ printf("designation: designator-list =\n");
			}
		;

designator_list
		:	designator
			{ printf("designator-list: designator\n");
			}
		|	designator_list designator
			{ printf("designator-list: designator-list designator\n");
			}
		;

designator
		:	OPENSQ constant_expression CLOSESQ
			{ printf("designator: [ constant-expression ]\n");
			}
		|	FULLSTOP IDENTIFIER
			{ printf("designator: . IDENTIFIER\n");
			}
		;

statement
		:	labeled_statement
			{ printf("statement: labeled-statement\n");
			}
		|	compound_statement
			{ 
				$$ = $1;

				printf("statement: compound-statement\n");
			}
		|	expression_statement
			{ 
				$$ = new statement();
				$$->nextList = $1->nextList;

				printf("statement: expression-statement\n");
			}
		|	selection_statement
			{
				$$ = $1;

				printf("statement: selection-statement\n");
			}
		|	iteration_statement
			{ 
				$$ = $1;

				printf("statement: iteration-statement\n");
			}
		|	jump_statement
			{ 
				$$ = $1;

				printf("statement: jump-statement\n");
			}
		;

labeled_statement
		:	IDENTIFIER COLON statement
			{ 
				$$ = new statement();

				printf("labeled-statement: IDENTIFIER : statement\n");
			}
		|	CASE constant_expression COLON statement
			{ 
				$$ = new statement();

				printf("labeled-statement: CASE constant-expression : statement\n");
			}
		|	DEFAULT COLON statement
			{ 
				$$ = new statement();

				printf("labeled-statement: DEFAULT : statement\n");
			}
		;

compound_statement
		:	OPENCURLY CLOSECURLY
			{ 
				$$ = new statement();

				printf("compound-statement: { }\n");
			}
		|	OPENCURLY block_item_list CLOSECURLY
			{ 
				$$ = $2;

				printf("compound-statement: { block-item-list }\n");
			}
		;

block_item_list
		:	block_item
			{ 
				$$ = $1;

				printf("block-item-list: block-item\n");
			}
		|	block_item_list address_of_next_instruction block_item
			{ 
				$$ = $3;
				backpatch ($1->nextList, $2);

				printf("block-item-list: block-item-list block-item\n");
			}
		;

block_item
		:	declaration
			{ 
				$$ = new statement();

				printf("block-item: declaration\n");
			}
		|	statement
			{ 
				$$ = $1;

				printf("block-item: statement\n");
			}
		;

expression_statement
		:	SEMICOLON
			{ 
				new expr();

				printf("expression-statement: expression-opt;\n");
			}
		|	expression SEMICOLON
			{
				$$ = $1;
			}
		;

selection_statement
		:	IF OPENBRAC expression goto_from_this_instruction CLOSEBRAC address_of_next_instruction statement goto_from_this_instruction
			{ 
				backpatch ($4->nextList, nextInstr());
				convert2bool($3);
				$$ = new statement();
				backpatch ($3->trueList, $6);
				intlist temp = merge ($3->falseList, $7->nextList);
				$$->nextList = merge ($8->nextList, temp);

				printf("selection-statement: IF ( expression ) statement\n");
			}
		|	IF OPENBRAC expression goto_from_this_instruction CLOSEBRAC address_of_next_instruction statement goto_from_this_instruction ELSE address_of_next_instruction statement
			{ 
				backpatch ($4->nextList, nextInstr());
				convert2bool($3);
				$$ = new statement();
				backpatch ($3->trueList, $6);
				backpatch ($3->falseList, $10);
				intlist temp = merge ($7->nextList, $8->nextList);
				$$->nextList = merge (temp, $11->nextList);

				printf("selection-statement: IF ( expression ) statement ELSE statement\n");
			}
		|	SWITCH OPENBRAC expression CLOSEBRAC statement
			{ printf("selection-statement: SWITCH ( expression ) statement\n");
			}
		;

iteration_statement
		:	WHILE address_of_next_instruction OPENBRAC expression CLOSEBRAC address_of_next_instruction statement
			{ 
				$$ = new statement();
				convert2bool($4);
				//M1 to go back to boolean again
				//M2 to go to statement if the boolean is true
				backpatch($7->nextList, $2);
				backpatch($4->trueList, $6);
				$$->nextList = $4->falseList;
				//Emit to prevent fallthrough
				emit (GOTOOP, intToString($2));

				printf("iteration-statement: WHILE ( expression ) statement\n");
			}
		|   DO address_of_next_instruction statement address_of_next_instruction WHILE OPENBRAC expression CLOSEBRAC SEMICOLON
			{ 
				$$ = new statement();
				convert2bool($7);
				//M1 to go back to statement if expression is true
				//M2 to go to check expression if statement is complete
				backpatch ($7->trueList, $2);
				backpatch ($3->nextList, $4);

				//Some bug in the next statement
				$$->nextList = $7->falseList;

				printf("iteration-statement: DO statement WHILE ( expression ) ;\n");
			}
		|	FOR OPENBRAC expression_statement address_of_next_instruction expression_statement address_of_next_instruction expression goto_from_this_instruction  CLOSEBRAC address_of_next_instruction statement
			{ 
				$$ = new statement();
				convert2bool($5);
				backpatch ($5->trueList, $10);
				backpatch ($8->nextList, $4);
				backpatch ($11->nextList, $6);
				emit (GOTOOP, intToString($6));
				$$->nextList = $5->falseList;

				printf("iteration-statement: FOR ( expression-opt ; expression-opt ; expression-opt ) statement\n");
			}
		|	FOR OPENBRAC declaration address_of_next_instruction expression_statement address_of_next_instruction expression goto_from_this_instruction CLOSEBRAC address_of_next_instruction statement
			{ 
				$$ = new statement();
				convert2bool($5);
				backpatch ($5->trueList, $10);
				backpatch ($7->nextList, $4);
				backpatch ($11->nextList, $6);
				emit (GOTOOP, intToString($6));
				$$->nextList = $5->falseList;

				printf("iteration-statement: FOR ( declaration expression-opt ; expression-opt ) statement\n");
			}
		;

jump_statement
		:	GOTO IDENTIFIER SEMICOLON
			{ 
				$$ = new statement();

				printf("jump-statement: GOTO IDENTIFIER ;\n");
			}
		|	CONTINUE SEMICOLON
			{ 
				$$ = new statement();

				printf("jump-statement: CONTINUE ;\n");
			}
		|	BREAK SEMICOLON
			{ 
				$$ = new statement();

				printf("jump-statement: BREAK ;\n");
			}
		|	RETURN SEMICOLON
			{ 
				$$ = new statement();
				emit(RET, "");

				printf("jump-statement: RETURN ;\n");
			}
		|	RETURN expression SEMICOLON
			{
				$$ = new statement();
				emit(RET,$2->symbolEntryPointer->name);

				printf("jump-statement: RETURN expression ;\n");
			}
		;

translation_unit
		:	external_declaration
			{ 
			changeTable(globTable);
		
				printf("translation-unit: external-declaration\n");
				}
		|	translation_unit external_declaration
			{ 	
				changeTable(globTable);
				
				
				printf("translation-unit: translation-unit external-declaration\n");
			}
		;

external_declaration
		:	function_definiton
			{ printf("external-declaration: function-definition\n");
			}
		|	declaration
			{ printf("external-declaration: declaration\n");
			}
		;

function_definiton
		:	declaration_specifiers declarator compound_statement
			{ printf("function-definition: declaration-specifiers declarator compound-statement\n");
			}
		|	declaration_specifiers declarator declaration_list compound_statement
			{ 
				emit (FUNCEND, table->tableName);
				table->parent = globTable;
				changeTable (globTable);

				printf("function-definition: declaration-specifiers declarator declaration-list compound-statement\n");
			}
		;

declaration_list
		:	declaration
			{ printf("declaration-list: declaration\n");
			}
		|	declaration_list declaration
			{ printf("declaration-list: declaration-list declaration\n");
			}
		;

%%

int yyerror(string s){
  cout<<s;
  return -1;
}




	
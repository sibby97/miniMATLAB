#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <iostream>
#include <vector>
#include <bits/stdc++.h>
#include <string>

/*--------MACRO DEFINTIONS-------*/

#define SIZEOF_CHAR		1
#define SIZEOF_INT 		4
#define SIZEOF_POINTER		4
#define SIZEOF_DOUBLE		8
#define dimension		2

extern char* yytext;
extern int yyparse();

using namespace std;

/*--------FORWARD DECLARATIONS---------*/

class symbolEntry;		//Entry in a symbol table
class symbolTable;		//Symbol Table
class quadEntry;		//Entry in quad array
class quads;		//All Quads
class symbolType;		//Type of a symbol in symbol table

/*--------------Enum TYPES ---------------*/

enum basicType {		//Type enumeration
	_VOID,
	_CHAR,
	_INT,
	_DOUBLE,
	_PTR,
	_ARR,
	_MATRIX
};

enum opType {		//Operator types
	EQL,
	EQLSTR,
	EQLCHAR,
	LT,		//Relational Operators
	GT, 
	LE, 
	GE, 
	EQOP,
	NEOP,
	GOTOOP, 
	RET,
	ADD,		//Arithmatic Operators
	SUB, 
	MULT, 
	DIV, 
	RIGHTOP, 
	LEFTOP, 
	MODOP,
	UMINUS,		//Unary Operators
	UPLUS,
	ADDRESS, 
	RIGHT_POINTER, 
	BNOT, 
	LNOT,
	BAND,		//Bit Operators 
	XOR, 
	INOR,
	PTRL,		//PTR Assign 
	PTRR,
	ARRR,		//MATRIX Assign 
	ARRL,
	PARAM,		//Function call
	CALL,
	FUNC, 
	FUNCEND
};

/*---------------GLOBAL VARIABLES DECLARED IN translator.cxx FILE-----------------*/

extern symbolTable* globTable;		//Global Symbol Table
extern symbolTable* table;		//Current Symbol Table
extern quads quadArr;		//Quads
extern symbolEntry* curSymEntry;		//Pointer to just encountered symbol

/*--------------CLASS DECLARATIONS--------------*/

class symbolType {		//Type of an element in symbol table
public:
	symbolType(basicType bastype, symbolType* ptr = NULL, int row = 0, int column = 0);
	basicType bastype;	
	int row;		//Rows in Matrix
	int column;		//Columns of Matrix
	symbolType* ptr;		//Array -> array of ptr type; pointer-> pointer to ptr type 
};

class symbolEntry {		//Row in a Symbol Table
public:
	string name;		//Name of symbol
	symbolType *type;		//Type of Symbol
	string init;		//Symbol initialisation
	string category;		//local, temp or global
	int size;		//Size of the type of symbol
	int offset;		//Offset of symbol computed at the end
	symbolTable* nestedTable;		//Pointer to nested symbol table
	void printEntry();
	bool isMatrixType;
	symbolEntry (string, basicType t=_INT, symbolType* ptr = NULL, int row = 0, int column = 0);
	symbolEntry* update(symbolType *t);		//Update using type object and nested table pointer
	symbolEntry* update(basicType t);		//Update using raw type and nested table pointer
	symbolEntry* initialize (string);
	symbolEntry* linkSymTab(symbolTable* t);		//Link the symbol table for a function(nested table)
};

class symbolTable {		//Symbol Table
public:
	string tableName;		//Name of Table
	int tempCount;		//Count of temporary variables
	list <symbolEntry> table;		//The table of symbols
	symbolTable* parent;		//Parent table of this symbol table
	map<string, int> ar;		//Activation Record

	symbolTable (string name="");
	symbolEntry* lookup (string name);		//Lookup for a symbol in symbol table
	symbolEntry* lookOff (int offset);		//Look for a symbol in the symbol table from its offset
	void print(int all = 0);		//Print the symbol table
	void computeOffsets();		//Compute offset of the whole symbol table recursively
};

class quadEntry { //Individual Quad
public:
	opType op;					//Operator
	string result;				//Result
	string arg1;				//Argument 1
	string arg2;				//Argument 2

	void print ();								//Print Quads
	void update (int addr);						//Used for backpatching address
	quadEntry (string result, string arg1, opType op = EQL, string arg2 = "");
	quadEntry (string result, int arg1, opType op = EQL, string arg2 = "");
};

class quads { //Quad Array
public:
	vector <quadEntry> quadArray;		//Vector of quads

	quads () {quadArray.reserve(300);}
	void print ();								//Print all the quads
	void printTab();							//Print quads in tabular form
};

/*------------FUNCTION DECLATRATIONS------------*/

symbolEntry* gentemp (basicType t=_INT, string init = "");		//Generate a temporary variable and insert it in symbol table
symbolEntry* gentemp (symbolType* t, string init = "");		//Generate a temporary variable and insert it in symbol table

void backpatch (list <int>, int);

void emit(opType op, string result, string arg1= "", string arg2 = "");
void emit(opType op, string result, int arg1, string arg2 = "");

typedef list<int> intlist;

typedef list<list<char>> charcharlist;	

typedef vector<char> vechar;

list<int> makelist (int);		//Make a new list contaninig an integer

list<int> merge (list<int> &, list<int> &);		//Merge two lists

int sizeOfType (symbolType*);		//Calculate size of any type

string convertToString (const symbolType*);		//For printing type structure

string opcodeToString(int);

symbolEntry* convert (symbolEntry*, basicType);		//Convert symbol to different type
bool typecheck(symbolEntry* &s1, symbolEntry* &s2);		//Checks if two symbbol table entries have same type
bool typecheck(symbolType* s1, symbolType* s2);		//Check if the type objects are equivalent

int nextInstr();		//Returns the address of the next instruction
string numberToString(int);		//Converts a number to string mainly used for storing numbers

void changeTable (symbolTable* newtable);

/*------------ATTRIBUTES/GLOBAL FOR BOOLEAN EXPRESSIONS------------*/

struct expr {
	bool isBoolean;				//Boolean variable that stores if the expression is bool
	bool isMatrix; 

	//Valid for non-bool type
	symbolEntry* symbolEntryPointer;					//Pointer to the symbol table entry

	//Valid for bool type
	intlist trueList;				//Truelist valid for boolean
	intlist falseList;				//Falselist valid for boolean expressions

	//Valid for statement expression
	intlist nextList;
};

struct statement {
	intlist nextList;				//Nextlist for statement
};

struct unary {
	basicType bastype;
	symbolEntry* loc;					//Temporary used for computing array address
	symbolEntry* symbolEntryPointer;					//Pointer to symbol table
	symbolType* type;				//type of the subarray generated
};

struct matstruct {
	bool isMatrixStart;
	int count;
	int row;
	int column;
	int dim;
	matstruct();
};
/*------------------UTILITY FUNCTIONS-------------------*/

string intToString(int);

string charToString(char);

expr* convert2bool (expr*);				//convert any expression to bool

expr* convertfrombool (expr*);			//convert bool to expression

int dim();

int chartoascii(char a);

int max(int a, int b);

double maxd(double a, double b);

string integer2string(int);

bool areEqual(basicType, basicType);

#endif

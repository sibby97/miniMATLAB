#include "ass4_15CS30031_translator.h"

/*---------------GLOBAL VARIABLES---------------*/

symbolTable* globTable;		//Global Symbbol Table
quads quadArr;		//Quads
basicType TYPE;		//Stores latest type specifier
//bool gDebug = false;		//Debug mode
symbolTable* table;		//Points to current symbol table
symbolEntry* curSymEntry;		//points to latest function entry in symbol table

int sizeOfType (symbolType* t){
	if(t->bastype == _VOID){
		return 0;
	}
	else if(t->bastype == _CHAR){
		return SIZEOF_CHAR;
	}
	else if(t->bastype == _INT){
		return SIZEOF_INT;
	}
	else if(t->bastype == _PTR){
		return SIZEOF_POINTER;
	}
	else if(t->bastype == _DOUBLE){
		return SIZEOF_DOUBLE;
	}
	else if(t->bastype == _MATRIX){
		return t->row * t->column * SIZEOF_DOUBLE + 2 * SIZEOF_INT;
	}
	else{
		return 0;
	}
}
string convertToString (const symbolType* t){
	if (t==NULL) return "null";
	if(t->bastype == _VOID){
		return "void";
	}
	else if(t->bastype == _CHAR){
		return "char";
	}
	else if(t->bastype == _INT){
		return "int";
	}
	else if(t->bastype == _PTR){
		return "ptr("+ convertToString(t->ptr)+")";
	}
	else if(t->bastype == _DOUBLE){
		return "double";
	}
	else if(t->bastype == _MATRIX){
		return "Matrix(" + intToString(t->row) + ", "+ intToString(t->column) + ")";
	}
	else{
		return "type";
	}
}
symbolType::symbolType(basicType bastype, symbolType* ptr, int row, int column): 
	bastype (bastype), 
	ptr (ptr), 
	row (row),
	column (column){};

symbolEntry* symbolTable::lookup (string name){		//add new entry in the symbol table if it is not already present
	symbolEntry* s;
	list <symbolEntry>::iterator it;
	for (it = table.begin(); it!=table.end(); it++){
		if (it->name == name ) break;
	}
	if (it!=table.end() ){
		//if (gDebug) cout<<name<<" already present"<<endl;
		return &*it;
	}
	else{
		/*
		for (it = globTable->table.begin(); it!=globTable->table.end(); it++){
			if (it->name == name ) break;
		}
		if (it!=globTable->table.end() ){
			if (gDebug) cout<<name<<" already present in global table"<<endl;
			return &*it;
		}
		else{
			*/
			s =  new symbolEntry (name);
			s->category = "local";
			table.push_back (*s);
//			if (gDebug) print();
			return &table.back();		//Returns a pointer to the reference to the last element in the list container.
		//}		
	}
}
symbolEntry* symbolTable::lookOff(int offset){		//Searches for an element of a Matrix/ Array by its offset, if present return the value ,if not generate new temp to hold the value
	symbolEntry* s;
	bool pt = false;
	list <symbolEntry>::iterator it;
	for (it = table.begin(); it!=table.end(); it++){
		if (it->offset == offset ) break;
	}
	if (it!=table.end() ){
		//if (gDebug) cout<<name<<" already present"<<endl;
		return &*it;
	}
	else{
		/*
		for (it = globTable->table.begin(); it!=globTable->table.end(); it++){
			if (it->name == name ) break;
		}
		if (it!=globTable->table.end() ){
			if (gDebug) cout<<name<<" already present in global table"<<endl;
			return &*it;
		}
		else{
			*/
			s =  gentemp(_DOUBLE);
			s->category = "local";
			table.push_back (*s);
//			if (gDebug) print();
			return &table.back();		//Returns a pointer to the reference to the last element in the list container.
		//}		
	}
}
symbolEntry* gentemp (basicType t, string init){		//generate temperory of basic type t and initial val init
	char n[20];
	sprintf(n, "t%02d", table->tempCount++);		//Name the new temp variable as "t"+ "tempCount" (only 2 digits of tempCount with left padding 0) in char* n
	symbolEntry* s = new symbolEntry (n, t);
	s-> init = init;
	s->category = "temp";
	table->table.push_back ( *s);
//	if (gDebug) table->print();
	return &table->table.back();
}
symbolEntry* gentemp (symbolType* t, string init){		//generate temperory of type t and initial val init
	char n[20];
	sprintf(n, "t%02d", table->tempCount++);
	symbolEntry* s = new symbolEntry (n);
	s->type = t;
	s-> init = init;
	s->category = "temp";
	table->table.push_back ( *s);
//	if (gDebug) table->print();
	return &table->table.back();
}
void symbolEntry::printEntry()		//print symbol entry
{
	cout<<left<<setw(20)<<this->name;
	cout<<left<<setw(20)<<convertToString(this->type);
	cout<<left<<setw(20)<<this->category;
	cout<<left<<setw(20)<<this->init;
	cout<<left<<setw(20)<<this->size;
	cout<<left<<setw(20)<<this->offset;
	cout<<left;
	if (this->nestedTable != NULL) {
		cout << this->nestedTable->tableName <<  endl;
	}
	else {
		cout << "null" <<  endl;
	}
}
symbolTable::symbolTable (string name): tableName (name), tempCount(0){}		//Constructor of symbolTable
void symbolTable::print(int all){		//print the symbol table
	list<symbolTable*> tablelist;
	cout<<endl<<endl<<endl<<".....................................PRINTING THE SYMBOL TABLE................................."<<endl<<endl<<endl;
	cout<<setw(150)<<setfill ('.')<<"."<< endl;
	cout<<"Symbol Table: "<<setfill (' ')<<left<<setw(35) <<this -> tableName ;
	cout<<right<<setw(20)<<"Parent: ";
	if (this->parent!=NULL)
		cout<<this -> parent->tableName;
	else cout<<"null" ;
	cout<<endl;
	cout<<setw(150)<<setfill ('-')<<"-"<< endl;
	cout<<setfill (' ')<<left<<setw(20)<<"Name";
	cout<<left<<setw(20)<<"Type";
	cout<<left<<setw(20)<<"Category";
	cout<<left<<setw(20)<<"Init Val";
	cout<<left<<setw(20)<<"Size";
	cout<<left<<setw(20)<<"Offset";
	cout<<left<<"Nested Table"<<endl;
	cout<<setw(150)<<setfill ('-')<<"-"<< setfill (' ')<<endl;
	
	for (list <symbolEntry>::iterator it = table.begin(); it!=table.end(); it++){
		it->printEntry();
		if (it->nestedTable!=NULL) tablelist.push_back (it->nestedTable);
	}

	cout<<setw(150)<<setfill ('.')<<"."<< setfill (' ')<<endl;
	cout<<endl;
	if (all){
		for (list<symbolTable*>::iterator iterator = tablelist.begin();
				iterator != tablelist.end();
				++iterator){
		    (*iterator)->print();
		}		
	}
}
void symbolTable::computeOffsets(){		//compute the offsets of the symbol table entries
	list<symbolTable*> tablelist;
	int off;
	int max=0;
	for (list <symbolEntry>::iterator it = table.begin(); it!=table.end(); it++){
		if (it==table.begin()){
			it->offset = 0;
			off = it->size;
			//for (list <symbolEntry>::iterator it2 = table.begin(); it2!=table.end(); it2++){
			//	if(it2->offset>max){
			//		max=it2->offset;
			//		size=it2->size;
			//	}
			//}
			//off = max;
			//off += size;
		}
		else{
				it->offset = off;	//if offset is already set then leave it
			if(it->type->bastype != _MATRIX){
				off = it->offset + it->size;
			}
		}
		if (it->nestedTable!=NULL) tablelist.push_back (it->nestedTable);
	}
	for (list<symbolTable*>::iterator iterator = tablelist.begin(); 
			iterator != tablelist.end(); 
			++iterator){
//	    debug ("computing for child");
	    (*iterator)->computeOffsets();
//		if (gDebug) (*iterator)->print();
	}
}
symbolEntry* symbolEntry::linkSymTab(symbolTable* t){		//link the symbol table of a function (every function has its own symbol table)
	this->nestedTable = t;
	this->category = "function";
}
quadEntry::quadEntry (string result, string arg1, opType op, string arg2):		//constructor of quadEntry
	result (result), arg1(arg1), arg2(arg2), op (op){};

quadEntry::quadEntry (string result, int arg1, opType op, string arg2):		//constructor of quadEntry with int operand
	result (result), arg2(arg2), op (op){
		this ->arg1 = numberToString(arg1);
	}
symbolEntry::symbolEntry (string name, basicType t, symbolType* ptr, int row, int column): name(name){		//constructor of symbolEntry
	type = new symbolType (symbolType(t, ptr, row, column));
	nestedTable = NULL;
	init = "";
	category = "";
	offset = 0;
	c = 0;
	isMatrixType = false;
	size = sizeOfType(type);
}
symbolEntry* symbolEntry::initialize (string init){		//initialize the symbol entry
	this->init = init;
	return this;
}
symbolEntry* symbolEntry::update(symbolType* t){		//update the symbol entry
	type = t;
	this -> size = sizeOfType(t);
//	if (gDebug) table->print();
	return this;
}
symbolEntry* symbolEntry::update(basicType t){		//update the symbol entry with basic type t
	this->type = new symbolType(t);
	this->size = sizeOfType(this->type);
	//table->print();
	return this;
}
void quadEntry::update (int addr){	//Used for backpatching address
	this ->result = addr;
}
void quadEntry::print (){		//print op code
		//Binary Operations
		if(op ==  ADD){			cout<<result<<" = "<<arg1<<" + "<<arg2;				}
		else if(op ==  SUB){			cout<<result<<" = "<<arg1<<" - "<<arg2;				}
		else if(op ==  MULT){			cout<<result<<" = "<<arg1<<" * "<<arg2;				}
		else if(op ==  DIV){		cout<<result<<" = "<<arg1<<" / "<<arg2;				}

		//Bit Operators /* Ignored */
		else if(op ==  MODOP){			cout<<result<<" = "<<arg1<<" % "<<arg2;				}
		else if(op ==  XOR){			cout<<result<<" = "<<arg1<<" ^ "<<arg2;				}
		else if(op ==  INOR){			cout<<result<<" = "<<arg1<<" | "<<arg2;				}
		else if(op ==  BAND){			cout<<result<<" = "<<arg1<<" & "<<arg2;				}
		//Shelse ift Operations /* Ignored */
		else if(op ==  LEFTOP){		cout<<result<<" = "<<arg1<<"<<"<<arg2;				}
		else if(op ==  RIGHTOP){		cout<<result<<" = "<<arg1<<" >> "<<arg2;				}

		else if(op ==  EQL){			cout<<result<<" = "<<arg1 ;								}
		//Relational Operations
		else if(op ==  EQOP){			cout<<"if "<<arg1<< " == "<<arg2<<" goto "<<result;				}
		else if(op ==  NEOP){			cout<<"if "<<arg1<< " != "<<arg2<<" goto "<<result;				}
		else if(op ==  LT){			cout<<"if "<<arg1<< " < " <<arg2<<" goto "<<result;				}
		else if(op ==  GT){			cout<<"if "<<arg1<< " > " <<arg2<<" goto "<<result;				}
		else if(op ==  GE){			cout<<"if "<<arg1<< " >= "<<arg2<<" goto "<<result;				}
		else if(op ==  LE){			cout<<"if "<<arg1<< " <= "<<arg2<<" goto "<<result;				}
		else if(op ==  GOTOOP){		cout<<"goto "<<result;						}
		//Unary Operators
		else if(op ==  ADDRESS){		cout<<result<<" = &"<<arg1;				}
		else if(op ==  PTRR){			cout<<result	<< " = *"<<arg1 ;				}
		else if(op ==  PTRL){			cout<<"*"<<result	<< " = "<<arg1 ;		}
		else if(op ==  UMINUS){		cout<<result 	<< " = -"<<arg1;				}
		else if(op ==  BNOT){			cout<<result 	<< " = ~"<<arg1;				}
		else if(op ==  LNOT){			cout<<result 	<< " = !"<<arg1;				}

		else if(op ==  ARRR){	 		cout << this->result << " = " << this->arg1 << "[" << this->arg2 << "]";			}
		else if(op ==  ARRL){	 		cout << this->result << "[" << this->arg1 << "]" <<" = " <<  this->arg2;			}
		else if(op ==  RET){ 		cout<<"ret "<<result;				}
		else if(op ==  PARAM){ 		cout<<"param "<<result;				}
		else if(op ==  CALL){ 			cout<<result<<" = "<<"call "<<arg1<< ", "<<arg2;				}
		else if(op ==  FUNC){			cout<<result<<": ";					}
		else if(op ==  FUNCEND){		}
		else{		cout<<"op";							}
	cout<<endl;
}
void quads::printTab(){		//print the quad table
	cout<<endl<<endl<<endl<<"......................................PRINTING THE QUAD TABLE..................................."<<endl<<endl<<endl;
	cout<<setw(70)<<setfill ('.')<<".";
	cout<<"Quad Table";
	cout<<setw(70)<<setfill ('.')<<"."<<endl;
	cout<<setw(24)<<setfill (' ')<<"index";
	cout<<setw(24)<<"result";
	cout<<setw(24)<<" op";
	cout<<setw(24)<<"arg1";
	cout<<setw(24)<<"arg2"<<endl;
	cout<<setw(70)<<setfill ('-')<<"-"<<endl;
	for (vector<quadEntry>::iterator it = quadArray.begin(); it!=quadArray.end(); it++){
		cout<<left<<setw(24)<<setfill(' ')<<it - quadArray.begin(); 
		cout<<left<<setw(24)<<it->result;
		cout<<left<<setw(24)<<opcodeToString(it->op);
		cout<<left<<setw(24)<<it->arg1;
		cout<<left<<setw(24)<<it->arg2<<endl;
	}
	cout<<setw(150)<<setfill ('.')<<"."<<endl;
}
void backpatch (list <int> l, int addr){		//backpatch list l with addr
	for (list<int>::iterator it= l.begin(); it!=l.end(); it++) quadArr.quadArray[*it].result = intToString(addr);
	//if (gDebug) quadArr.print();
}
void quads::print (){		//print all the quad translations
	
	cout<<endl<<endl<<endl<<".............................................PRINTING THE QUAD TRANSLATIONS...................................."<<endl<<endl<<endl;
	cout<<setw(70)<<setfill ('.')<<".";
	cout<<"Quad Translation";
	cout<<setw(70)<<setfill ('.')<<"."<<endl;
	cout<<setw(150)<<setfill ('-')<<"-"<< setfill (' ')<<endl;
	for (vector<quadEntry>::iterator it = quadArray.begin(); it!=quadArray.end(); it++){
		switch (it->op){
			case FUNC:
				cout<<"\n";
				it->print();
				cout<<"\n";
				break;
			case FUNCEND:
				break;
			default:
				cout<<"\t"<<setw(14)<<it - quadArray.begin()<<":\t";
				it->print();
		}
	}
	cout<<setw(150)<<setfill ('.')<<"."<< endl;
}
void emit(opType op, string result, string arg1, string arg2){		//for adding in the quad table
	quadArr.quadArray.push_back(*(new quadEntry(result,arg1,op,arg2)));
	//if (gDebug) quadArr.print();
}
void emit(opType op, string result, int arg1, string arg2){		//for adding in the quad table
	quadArr.quadArray.push_back(*(new quadEntry(result,arg1,op,arg2)));
	//if (gDebug) quadArr.print();
}
string opcodeToString (int op){		//convert opcode to string
	if(op == ADD){
		return " + ";
	}
	else if(op == SUB){
		return " - ";
	}
	else if(op == MULT){
		return " * ";
	}
	else if(op == DIV){
		return " / ";
	}
	else if(op == MODOP){
		return " % ";
	}
	else if(op == EQL){
		return " = ";
	}
	else if(op == EQOP){
		return " == ";
	}
	else if(op == NEOP){
		return " != ";
	}
	else if(op == LT){
		return " < ";
	}
	else if(op == GT){
		return " > ";
	}
	else if(op == LE){
		return " <= ";
	}
	else if(op == GE){
		return " >= ";
	}
	else if(op == XOR){
		return " ^ ";
	}
	else if(op == INOR){
		return " | ";
	}
	else if(op == ADDRESS){
		return " address ";
	}
	else if(op == PTRR){
		return " *R ";
	}
	else if(op == PTRL){
		return " *L ";
	}
	else if(op == UMINUS){
		return " minus ";
	}
	else if(op == BNOT){
		return " ~ ";
	}
	else if(op == LNOT){
		return " ! ";
	}
	else if(op == RIGHTOP){
		return " >> ";
	}
	else if(op == LEFTOP){
		return " << ";
	}
	else if(op == GOTOOP){
		return " goto ";
	}
	else if(op == ARRL){
		return " []= ";
	}
	else if(op == ARRR){
		return " =[] ";
	}
	else if(op == RET){
		return " ret ";
	}
	else if(op == PARAM){
		return " param ";
	}
	else if(op == CALL){
		return " call ";
	}
	else 
		return " op ";
}
list<int> makelist (int i){		//makelist with initializing element i
	list<int> l(1,i);
	return l;
}
list<int> merge (list<int> &a, list <int> &b){		//merge two lists a,b
	a.merge(b);
	return a;
}
int nextInstr(){		//find the nextinstruction
	return quadArr.quadArray.size();
}
string numberToString ( int Number ){		//convert number to string
	std::string s = std::to_string(Number);
	return s;
}
expr* convert2bool (expr* e){	//Convert any expression to bool
	bool ifnot = true;
	if ((!e->isBoolean)&&(ifnot)){
		e->falseList = makelist (nextInstr());
		emit (EQOP, "", e->symbolEntryPointer->name, "0");
		e->trueList = makelist (nextInstr());
		emit (GOTOOP, "");
	}
}
expr* convertfrombool (expr* e){	//Convert any expression to bool
	bool ifnot = true;
	if ((e->isBoolean)&&(ifnot)){
		e->symbolEntryPointer = gentemp(_INT);
		backpatch (e->trueList, nextInstr());
		emit (EQL, e->symbolEntryPointer->name, "true");
		emit (GOTOOP, intToString (nextInstr()+1));
		backpatch (e->falseList, nextInstr());
		emit (EQL, e->symbolEntryPointer->name, "false");
	}
}
bool typecheck(symbolEntry*& s1, symbolEntry*& s2){ 	//Check if the symbols have same type or not
	symbolType* type1 = s1->type;
	symbolType* type2 = s2->type;
	if ( typecheck (type1, type2) ) return true;
	else if (s1 = convert (s1, type2->bastype) ) return true;
	else if (s2 = convert (s2, type1->bastype) ) return true;
	return false;
}
bool typecheck(symbolType* t1, symbolType* t2){ 	//Check if the symbol types are same or not
	bool ifnot = false;
	if (t1 != NULL || t2 != NULL){
		if (t1==NULL) 
		{
			return false;
		}
		if (t2==NULL) 
		{
			return false;
		}
		if (t1->bastype==t2->bastype) 
		{
			return typecheck(t1->ptr, t2->ptr);
		}
		else 
		{
			return false;
		}
	}
	ifnot = true;
	return true;
}

symbolEntry* convert (symbolEntry* s, basicType t){		//convert a symbolentry to basic type t
	symbolEntry* temp = gentemp(t);
	if(s->type->bastype == _INT){
			switch (t){
				case _DOUBLE:{
					emit (EQL, temp->name, "int2double(" + s->name + ")");
					return temp;
				}
				case _CHAR:{
					emit (EQL, temp->name, "int2char(" + s->name + ")");
					return temp;
				}
			}
			return s;
	}
	else if(s->type->bastype == _DOUBLE){
			switch (t){
				case _INT:{
					emit (EQL, temp->name, "double2int(" + s->name + ")");
					return temp;
				}
				case _CHAR:{
					emit (EQL, temp->name, "double2char(" + s->name + ")");
					return temp;
				}
			}
			return s;
	}
	else if(s->type->bastype == _CHAR){
		switch (t){
				case _INT:{
					emit (EQL, temp->name, "char2int(" + s->name + ")");
					return temp;
				}
				case _DOUBLE:{
					emit (EQL, temp->name, "char2double(" + s->name + ")");
					return temp;
				}
			}
			return s;
	}
	return s;
}
void changeTable (symbolTable* newtable){	//Change current symbol table
	//if (gDebug)	cout<<"Symbol table changed from "<<table->tableName;
	table = newtable;
	//if (gDebug)	cout<<" to "<<table->tableName<<endl;
} 


string intToString(int t) { 		//convert int to string
	return to_string(t); 
} 

string charToString(char t) {		//convert char to string
	return string(1,t);
}

string integer2string(int n) {
    char tmp[10];
    sprintf(tmp, "%d", n);
    return tmp;
}

bool areEqual(basicType t1, basicType t2) {       //utility function -check if the two given types are equal
    if(t1 == t2){
    	return true;
    }
    return false;
}

int  main (int argc, char* argv[])
{
	//if (argc>1) gDebug = true;
	globTable = new symbolTable("Global");
	table = globTable;
	//symbolTable* nt = new symbolTable("nested");
	yyparse();
	list<symbolTable*> tablelist;
	for (list <symbolEntry>::iterator it = table->table.begin(); it!=table->table.end(); it++){
		if (it->nestedTable!=NULL) tablelist.push_back (it->nestedTable);
	}
	for (list<symbolTable*>::iterator iterator = tablelist.begin();
				iterator != tablelist.end();
				++iterator){
		    (*iterator)->computeOffsets();
		}
				table->print(1);
				quadArr.print();
				quadArr.printTab();
	return 0;
} 
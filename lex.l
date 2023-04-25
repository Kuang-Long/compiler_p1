%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n", t, int(i));}
#define tokenFloat(t,f) {LIST; printf("<%s:%f>\n", t, float(f));}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n", t, s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
%}

%Start COMMENT

%%
// tokens
<INITIAL> "."  {token('.');}
<INITIAL> ","  {token(',');}
<INITIAL> ":"  {token(':');}
<INITIAL> ";"  {token(';');}
<INITIAL> "("  {token('(');}
<INITIAL> ")"  {token(')');}
<INITIAL> "["  {token('[');}
<INITIAL> "]"  {token(']');}
<INITIAL> "{"  {token('{');}
<INITIAL> "}"  {token('}');}
<INITIAL> "+"  {token('+');}
<INITIAL> "-"  {token('-');}
<INITIAL> "*"  {token('*');}
<INITIAL> "/"  {token('/');}
<INITIAL> "mod"  {token("mod");}
<INITIAL> ":="   {token(":=");}
<INITIAL> "<"    {token('<');}
<INITIAL> "<="   {token("<=");}
<INITIAL> ">"    {token(">");}
<INITIAL> ">="   {token(">=");}
<INITIAL> "not=" {token("not=");}
<INITIAL> "and"  {token("and");}
<INITIAL> "or"   {token("or");}
<INITIAL> "not"  {token("not");}
<INITIAL> "array"      {token("array");}
<INITIAL> "begin"      {token("begin");}
<INITIAL> "bool"       {token("bool");}
<INITIAL> "char"       {token("char");}
<INITIAL> "const"      {token("const");}
<INITIAL> "decreasing" {token("decreasing");}
<INITIAL> "default"    {token("default");}
<INITIAL> "do"         {token("do");}
<INITIAL> "else"       {token("else");}
<INITIAL> "end"        {token("end");}
<INITIAL> "exit"       {token("exit");}
<INITIAL> "false"      {token("false");}
<INITIAL> "for"        {token("for");}
<INITIAL> "function"   {token("function");}
<INITIAL> "get"        {token("get");}
<INITIAL> "if"         {token("if");}
<INITIAL> "int"        {token("int");}
<INITIAL> "loop"       {token("loop");}
<INITIAL> "of"         {token("of");}
<INITIAL> "put"        {token("put");}
<INITIAL> "procedure"  {token("procedure");}
<INITIAL> "real"       {token("real");}
<INITIAL> "result"     {token("result");}
<INITIAL> "return"     {token("return");}
<INITIAL> "skip"       {token("skip");}
<INITIAL> "string"     {token("string");}
<INITIAL> "then"       {token("then");}
<INITIAL> "true"       {token("true");}
<INITIAL> "var"        {token("var");}
<INITIAL> "when"       {token("when");}

// identifiers
<INITIAL> [a-zA-Z][a-zA-Z0-9]*  {tokenString("idintifier", yytext)}

// numerical constants 
<INITIAL> [0-9][0-9]* {tokenInteger("integer", yytext);}
<INITIAL> [0-9][0-9]*.[0-9][0-9]* {tokenFloat("float", yytext)}

// string constants


// comments


<INITIAL> \n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

<INITIAL> [ \t]*  {LIST;}

<INITIAL> .       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n", yytext);
        exit(-1);
        }
%%

typedef struct SymbolTable SymbolTable;
typedef struct SymbolNode SymbolNode;

int _index = 0;

struct SymbolNode {
	char* id;
	int index;
	SymbolNode* next;
};

struct SymbolTable {
	SymbolNode* table[MAX_LINE_LENG];
};

SymbolTable sTable;

int ascii_len(char* str) {
	int length = 0;
	while (*str != '\0') {
		length += *str;
		str++;
	}
	return length % 256;
}

void create() {
	for (int i = 0; i < MAX_LINE_LENG; i++) {
		sTable.table[i] = (SymbolNode*)malloc(sizeof(SymbolNode));
		SymbolNode* s = NULL;
		sTable.table[i] = s;
	}
}
int lookup(char* a) {
	int x = ascii_len(a);
	SymbolNode* tmp = sTable.table[x];
	while (tmp != NULL) {
		if (tmp->id == a)
			return tmp->index;
		else
			tmp = tmp->next;
	}
	return NULL;
}
int insert(char* a) {
	if (lookup(a) == NULL) {
		int x = ascii_len(a);
		SymbolNode* tmp = (SymbolNode*)malloc(sizeof(SymbolNode));
		tmp->id = a;
		tmp->index = _index++;
		tmp->next = sTable.table[x];
		sTable.table[x] = tmp;
		return _index - 1;
	}
	return -1;
}

void dump() {
	for (int i = 0; i < MAX_LINE_LENG; i++) {
		SymbolNode* tmp = sTable.table[i];
		while (tmp != NULL) {
			printf("id: %s, index: %d\n", tmp->id, tmp->index);
			tmp = tmp->next;
		}
	}
	return 0;
}
int yywrap() {
    return 1;
}
int main() {
    while(yylex())
        printf("%d:%s\n", yylineno, yytext);
    return 0;
}
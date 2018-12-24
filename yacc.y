%{
#include "main.h

nodeType *pro(int nfns, ...);
nodeType *fun(int npts, ...);
nodeType *lis(int nlis, ...);
nodeType *prs(int npas, ...);
nodeType *par(int npts, ...);
nodeType *sta(int mark, int npts, ...);
nodeType *opr(int oper, int nops, ...);
nodeType *eps(int neps, ...);
nodeType *id(int i);
nodeType *conTyp(typeEnum value);
nodeType *conInt(int value);
nodeType *conDbl(double value);
nodeType *conChr(int i);
nodeType *conStr(int i);
int getParamNum(nodeType* params);
int getStateNum(nodeType* p);
int getExpNum(nodeType* p);
int getFuncNum(nodeType* p);
void freeNode(nodeType *p);
void yyerror(char* s);
int yylex(void);
%}
	
%union {
	typeEnum iType;				/* type category */
	int iValue;					/* integer value */
	int sIndex;					/* sym, str, chr vector index */
	double dValue;				/* double value */
	nodeType *nPtr;				/* node pointer */
};

%token <iValue> INTEGER
%token <iType> INT CHAR DOUBLE
%token <dValue> DOUBLE_NUM
%token <sIndex> CHARACTER
%token <sIndex> STRING COMMENT
%token <sIndex> IDENTIFIER

%token INC_OP DEC_OP INC_OP_LEFT INC_OP_RIGHT DEC_OP_LEFT DEC_OP_RIGHT LE_OP GE_OP NOT_OP
%token AND_OP OR_OP
%token DECLARE DECLARE_ARRAY
%token WHILE IF PRINTF BREAK RETURN GETS STRLEN CONTINUE FOR ISDIGIT STRCMP

%nonassoc IFX
%nonassoc ELSE

%left EQ_OP NE_OP '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> function function_list type_name statement statement_list expr expr_list param param_list
%expect 180

%%
program:
		function_list														{codeGenPro($1); freeNode($1); exit(0);}
		;

function_list:
		function															{$$ = pro(1, $1);}
		| function function_list											{$$ = pro(1 + getFuncNum($2), $1, $2);}
		;

function:
		type_name IDENTIFIER '(' param_list ')' '{' statement_list '}'		{$$ = fun(4, $1, id($2), $4, $7);}
		| type_name IDENTIFIER '(' ')' '{' statement_list '}'				{$$ = fun(3, $1, id($2), $6);}
		;

param_list:
		param																{$$ = prs(1, $1);}
		| param ',' param_list												{$$ = prs(1 + getParamNum($3), $1, $3);}
		;

param:
		type_name IDENTIFIER												{$$ = par(2, $1, id($2));}
		| type_name IDENTIFIER '[' ']'										{$$ = par(2, $1, id($2));}
		;

type_name:
		INT																	{$$ = conTyp($1);}
		| CHAR																{$$ = conTyp($1);}
		| DOUBLE															{$$ = conTyp($1);}
		;

statement_list:
		statement															{$$ = lis(1, $1);}
		| statement statement_list											{$$ = lis(1 + getStateNum($2), $1, $2);}
		;

statement:
		BREAK ';'															{$$ = sta(BREAK, 0);}
		| CONTINUE ';'														{$$ = sta(CONTINUE, 0);}
		| RETURN expr ';'													{$$ = sta(RETURN, 1, $2);}
		| PRINTF '(' expr_list ')' ';'										{$$ = sta(PRINTF, 1, $3);}
		| IDENTIFIER '(' expr_list ')' ';'									{$$ = sta(IDENTIFIER, 2, id($1), $3);}
		| GETS '(' IDENTIFIER ')' ';'										{$$ = sta(GETS, 1, id($3));}
		| IDENTIFIER '=' expr ';'											{$$ = sta('=', 2, id($1), $3);}
		| IDENTIFIER '[' expr ']' '=' expr ';'								{$$ = sta('=', 3, id($1), $3, $6);}
		| type_name IDENTIFIER '[' INTEGER ']' ';'							{$$ = sta(DECLARE_ARRAY, 3, $1, id($2), conInt($4));}
		| type_name IDENTIFIER '=' expr ';'									{$$ = sta(DECLARE, 3, $1, id($2), $4);}
		| type_name IDENTIFIER ';'											{$$ = sta(DECLARE, 2, $1, id($2));}
		| WHILE '(' expr ')' '{' statement_list '}'							{$$ = sta(WHILE, 2, $3, $6);}
		| IF '(' expr ')' '{' statement_list '}' %prec IFX					{$$ = sta(IF, 2, $3, $6);}
		| IF '(' expr ')' '{' statement_list '}' ELSE '{' statement_list '}'{$$ = sta(ELSE, 3, $3, $6, $10);}// IF-ELSE is prior to the IF statement
		| FOR '(' statement expr ';' expr ')' '{' statement_list '}'		{$$ = sta(FOR, 4, $3, $4, $6, $9);}
		| INC_OP expr ';'													{$$ = sta(INC_OP_LEFT, 1, $2);}
		| DEC_OP expr ';'													{$$ = sta(DEC_OP_LEFT, 1, $2);}
		| expr INC_OP ';'													{$$ = sta(INC_OP_RIGHT, 1, $1);}
		| expr DEC_OP ';'													{$$ = sta(DEC_OP_RIGHT, 1, $1);}
		| COMMENT															{$$ = sta(COMMENT, 1, conStr($1));}
		;

expr_list:
		expr																{$$ = eps(1, $1);}
		| expr ',' expr_list												{$$ = eps(1 + getExpNum($3), $1, $3);}
		;

expr:
		INTEGER																{$$ = conInt($1);}
		| DOUBLE_NUM														{$$ = conDbl($1);}
		| CHARACTER															{$$ = conChr($1);}
		| STRING															{$$ = conStr($1);}
		| IDENTIFIER														{$$ = id($1);}
		| '-' expr %prec UMINUS												{$$ = opr(UMINUS, 1, $2);}
		| STRLEN '(' IDENTIFIER ')'											{$$ = opr(STRLEN, 1, id($3));}
		| STRCMP '(' expr ',' expr ')'										{$$ = opr(STRCMP, 2, $3, $5);}
		| ISDIGIT '(' expr ')'												{$$ = opr(ISDIGIT, 1, $3);}
		| IDENTIFIER '(' expr_list ')'										{$$ = opr(IDENTIFIER, 2, id($1), $3);}
		| IDENTIFIER '[' expr ']'											{$$ = opr('[', 2, id($1), $3);}
		| expr '+' expr														{$$ = opr('+', 2, $1, $3);}
		| expr '-' expr														{$$ = opr('-', 2, $1, $3);}
		| expr '*' expr														{$$ = opr('*', 2, $1, $3);}
		| expr '/' expr														{$$ = opr('/', 2, $1, $3);}
		| expr '<' expr														{$$ = opr('<', 2, $1, $3);}
		| expr '>' expr														{$$ = opr('>', 2, $1, $3);}
		| INC_OP expr														{$$ = opr(INC_OP_LEFT, 1, $2);}
		| DEC_OP expr														{$$ = opr(DEC_OP_LEFT, 1, $2);}
		| expr INC_OP														{$$ = opr(INC_OP_RIGHT, 1, $1);}
		| expr DEC_OP														{$$ = opr(DEC_OP_RIGHT, 1, $1);}
		| expr NE_OP expr													{$$ = opr(NE_OP, 2, $1, $3);}
		| expr EQ_OP expr													{$$ = opr(EQ_OP, 2, $1, $3);}
		| expr OR_OP expr													{$$ = opr(OR_OP, 2, $1, $3);}
		| expr AND_OP expr													{$$ = opr(AND_OP, 2, $1, $3);}
		| '!' expr															{$$ = opr('!', 1, $2);}
		| expr LE_OP expr													{$$ = opr(LE_OP, 2, $1, $3);}
		| expr GE_OP expr													{$$ = opr(GE_OP, 2, $1, $3);}
		| '(' expr ')'														{$$ = opr('(', 1, $2);}
		;
%%

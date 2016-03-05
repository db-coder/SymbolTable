
%scanner Scanner.h
%scanner-token-function d_scanner.lex()
%token VOID INT FLOAT FLOAT_CONSTANT INT_CONSTANT AND_OP OR_OP EQ_OP NE_OP GE_OP LE_OP STRING_LITERAL IF ELSE WHILE FOR RETURN STRUCT IDENTIFIER INC_OP PTR_OP
%polymorphic STRING : std::string; EXPAST : exp_astnode*; STMAST : stmt_astnode*; REFAST : ref_astnode*; INT1 : int; FLOAT1 : float; LIST : std::vector<exp_astnode*>; 

%type<STRING> unary_operator INC_OP IDENTIFIER STRING_LITERAL
%type<INT1> INT_CONSTANT
%type<FLOAT1> FLOAT_CONSTANT
%type<EXPAST> expression logical_and_expression equality_expression relational_expression additive_expression multiplicative_expression unary_expression primary_expression constant_expression logical_or_expression postfix_expression
%type<STMAST> compound_statement statement selection_statement iteration_statement statement_list assignment_statement
%type<LIST> expression_list
%type<REFAST> declarator l_expression parameter_declaration

%%

translation_unit 
        :  struct_specifier
        {
	 		// top->printTable();
	 	}
	 	| function_definition 
	 	{
	 		top->printTable();
	 	}
	 	| translation_unit function_definition 
	 	{
	 		top->printTable();
	 	}
        | translation_unit struct_specifier
        {
	 		top->printTable();
	 	}
        ;

struct_specifier 
        : { top_local = new symTab();}STRUCT IDENTIFIER '{' declaration_list '}' ';'
        { 
			top->put($3,top_local->total_width(),0,new base_type("STRUCT"),top_local);
		}
        ;

function_definition
	: {top_local = new symTab();} type_specifier {ret = type1; offset = 0; params.clear();} fun_declarator 
	{ 
		int n = top_local->table.size();
		int w = (top_local->table[n-1])->width;
		(top_local->table[n-1])->offset = -w;
		for(int i=(top_local->table).size()-2;i>=0;i--)
		{
			w+=(top_local->table[i])->width;
			(top_local->table[i])->offset = -w;
		}
		offset = 0;
	} 
	compound_statement 
	{
		top->put(name_func,top_local->total_width(),0,ret,top_local,params);
	}
	;

type_specifier                   // This is the information 
        : VOID 	                 // that gets associated with each identifier
        { 
        	type1 = old_type = new base_type("void");
    	  	width = old_width = 0;
    	}
        | INT
        { 
        	type1 = old_type = new base_type("int");
    	  	width = old_width = 4;
    	}   
		| FLOAT
		{	
			type1  = old_type = new base_type("float");
			width  = old_width = 4;
		} 
        | STRUCT IDENTIFIER 
        {	
        	type1 = old_type = new base_type("struct "+$2);
        	width = old_width = top->struct_size($2);
        }
        ;

fun_declarator
	: IDENTIFIER '(' parameter_list ')' 
	{
		name_func = $1;
	}
	| IDENTIFIER '(' ')' 
	{	
		name_func = $1;
	}
    | '*' fun_declarator  //The * is associated with the 
    {	
    	ret = new pointer_type(ret->t);
    }
	;                      //function name


parameter_list
	: parameter_declaration 
	{	
		top_local->put(name,width,offset,type1,1);
		offset+=width;
		params.push_back(type1);
	}
	| parameter_list ',' parameter_declaration 
	{
		top_local->put(name,width,offset,type1,1);
		offset+=width;
		params.push_back(type1);
	}
	;

parameter_declaration
	: type_specifier declarator 
	;

declarator
	: IDENTIFIER 
	{
		name = $1;
		if(top_local->InScope(name))
		{
			cerr<<"Error: Redeclaration of variable at line number "<<l_no<<endl;
			ABORT();
		}
	}
	| declarator '[' primary_expression']' // check separately that it is a constant
	{	
		if(val<0)
		{
			cerr<<"Error: Array index should be a positive integer at line number "<<l_no<<endl;
			ABORT();
		}
		width*=val;
		type1 = new array_type(type1->t);
	}
    | '*' declarator 
    {	
    	type1 = new pointer_type(type1->t);
    	//old_type = new pointer_type(old_type->t);
    }
    ;

primary_expression 
        : IDENTIFIER
        {	
        	$$ = new id_astnode($1);
        	for (int i = 0; i < top_local->table.size(); ++i)
        	{
        		if((top_local->table[i])->name==$1)
        		{
        			if(((top_local->table[i])->t)->name=="int")
        				val=1;
        			else
        				val=-1;
        		}
        	}
        }
        | INT_CONSTANT
        {
        	$$ = new int_astnode($1);val=$1;
        } 
        | FLOAT_CONSTANT
        {
        	$$ = new float_astnode($1);
        	val=-1;
        }
        | STRING_LITERAL
        {
        	$$ = new string_astnode($1);
        	val=-1;
        }
        | '(' expression ')'
        {
        	$$ = $2;
        } 
        ;

compound_statement
	: '{' '}' 
	{
		$$ = new empty_astnode();
		($$)->print(0);
	}
	| '{' statement_list '}' 
	{	
		$$ = new block_astnode($2);
		($$)->print(0);
	}
    | '{' declaration_list statement_list '}' 
    {	
		$$ = new block_astnode($3);
		($$)->print(0);
	}
	;

statement_list
	: statement		
	{	
		$$ = new list_astnode($1);
	}
    | statement_list statement	
    {	
    	$$ = new list_astnode($2, $1);
    }
	;

statement
        : '{' statement_list '}'  
        {  	
        	$$ = new block_astnode($2); 
        }
        | selection_statement
		{	
			$$ = $1;
		} 	
        | iteration_statement
        {	
        	$$ = $1;
        } 	
		| assignment_statement
		{	
			$$ = $1;
		}
        | RETURN expression ';'
        {	
        	$$ = new return_astnode($2);
        }	
        ;

assignment_statement
	: ';'
	{	
		$$ = new empty_astnode(); 
	} 								
	|  expression ';'
	{
		$$ = $1;
	}  
	;

expression             //assignment expressions are right associative
        :  logical_or_expression
        {	
        	$$ = $1;
        }
        |  unary_expression '=' expression
        {	
        	$$ = new ass_astnode($1,$3);
        } 
        ;

logical_or_expression            // The usual hierarchy that starts here...
	: logical_and_expression
	{		
		$$ = $1;
	}
    | logical_or_expression OR_OP logical_and_expression
    {    	
    	$$ = new binary_astnode("OR_OP",$1,$3);
    }
	;
logical_and_expression
        : equality_expression
        {        	
        	$$ = $1;
        }
        | logical_and_expression AND_OP equality_expression
        {        	
        	$$ = new binary_astnode("And",$1,$3);
        } 
	;

equality_expression
	: relational_expression
	{		
		$$ = $1;
	} 
    | equality_expression EQ_OP relational_expression
    {    	
    	$$ = new binary_astnode("EQ_OP",$1,$3);
    } 	
	| equality_expression NE_OP relational_expression
	{		
		$$ = new binary_astnode("NE_OP",$1,$3);
	}
	;
relational_expression
	: additive_expression
	{		
		$$ = $1;
	}
    | relational_expression '<' additive_expression 
    {    	
    	$$ = new binary_astnode("LT",$1,$3);
    }
	| relational_expression '>' additive_expression
	{		
		$$ = new binary_astnode("GT",$1,$3);
	} 
	| relational_expression LE_OP additive_expression
	{		
		$$ = new binary_astnode("LE_OP",$1,$3);
	} 
    | relational_expression GE_OP additive_expression
    {    	
    	$$ = new binary_astnode("GE_OP",$1,$3);
    } 
	;

additive_expression 
	: multiplicative_expression
	{		
		$$ = $1;
	}
	| additive_expression '+' multiplicative_expression
	{		
		$$ = new binary_astnode("PLUS",$1,$3);
	} 
	| additive_expression '-' multiplicative_expression
	{		
		$$ = new binary_astnode("MINUS",$1,$3);
	} 
	;

multiplicative_expression
	: unary_expression
	{		
		$$ = $1;
	}
	| multiplicative_expression '*' unary_expression
	{		
		$$ = new binary_astnode("Multiply",$1,$3);
	} 
	| multiplicative_expression '/' unary_expression
	{		
		$$ = new binary_astnode("Divide",$1,$3);
	} 
	;
unary_expression
	: postfix_expression
	{		
		$$ = $1;
	}  				
	| unary_operator postfix_expression
	{		
		$$ = new unary_astnode($1,$2);
	} 
	;

postfix_expression
	: primary_expression
	{		
		$$ = $1;
	}  				
    | IDENTIFIER '(' ')'
    {    	
    	$$ = new func_astnode($1);
    } 				
	| IDENTIFIER '(' expression_list ')'
	{		
		$$ = new func_astnode($1, $3);
	}
    | postfix_expression '[' expression ']'
    {    	
    	$$ = new arrref_astnode($1, $3);  
    }  
    | postfix_expression '.' IDENTIFIER
    {    	
    	id_astnode *x = new id_astnode($3);
    	$$ = new member_astnode($1,x);
    }
    | postfix_expression PTR_OP IDENTIFIER
	{		
		id_astnode *x = new id_astnode($3);
   		$$ = new arrow_astnode($1,x);
    } 
	| postfix_expression INC_OP 	// ... and ends here
	{		
		$$ = new unary_astnode("PP", $1);
	}			
	;

l_expression                // A separate non-terminal for l_expressions
        : IDENTIFIER
        {        	
        	$$ = new id_astnode($1);
        }
        | l_expression '[' expression ']'
        {        	
        	$$ = new arrref_astnode($1, $3);  
        }  	
        | '*' l_expression
        {        	
        	$$ = new deref_astnode($2);
        }
        | l_expression '.' IDENTIFIER
        {        	
        	id_astnode *x = new id_astnode($3);
	        $$ = new member_astnode($1,x);
	    }
        | l_expression PTR_OP IDENTIFIER
        {        	
        	id_astnode *x = new id_astnode($3);
	        $$ = new arrow_astnode($1,x);
	    }
        | '(' l_expression ')'
        {        	
        	$$ = $2;
        }	
        ;

expression_list
        : expression
        {
        	vector<exp_astnode*> v;
        	v.push_back($1);
        	$$= v;
        }
        | expression_list ',' expression
        {
        	($1).push_back($3);
        	$$ = $1;
        }
	;

unary_operator
        : '-'
        {        	
        	$$ = "-";
        }
		| '!'
		{			
			$$ = "!";
		}
        | '&'
        {        	
        	$$ = "&";
        }
        | '*' 	
        {        	
        	$$ = "*";
        }
	;

selection_statement
        : IF '(' expression ')' statement ELSE statement
        {        	
        	$$ = new if_astnode($3, $5, $7);
        } 
	;

iteration_statement
	: WHILE '(' expression ')' statement
	{		
		$$ = new while_astnode($3, $5);
	}
	| FOR '(' expression ';' expression ';' expression ')' statement  //modified this production
	{		
		$$ = new for_astnode($3,$5, $7, $9);
	}
    ;

declaration_list
        : declaration  		
        {        	
        }			
        | declaration_list declaration
        {        	
        }
	;

declaration
	: type_specifier declarator_list';' 
	{		
	}
	;

declarator_list
	: declarator 
	{		
		top_local->put(name,width,offset,type1,0);
		offset+=width;
		width = old_width;
		type1 = old_type;
	}
	| declarator_list ',' declarator 
	{		
		top_local->put(name,width,offset,type1,0);
		offset+=width;
		width = old_width;
		type1 = old_type;
	}
 	;
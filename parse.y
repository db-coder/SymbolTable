
%scanner Scanner.h
%scanner-token-function d_scanner.lex()
%token VOID INT FLOAT FLOAT_CONSTANT INT_CONSTANT AND_OP OR_OP EQ_OP NE_OP GE_OP LE_OP STRING_LITERAL IF ELSE WHILE FOR RETURN STRUCT IDENTIFIER INC_OP PTR_OP
%polymorphic STRING : std::string; EXPAST : exp_astnode*; STMAST : stmt_astnode*; REFAST : ref_astnode*; INT1 : int; FLOAT1 : float; 

%type<STRING> unary_operator INC_OP IDENTIFIER STRING_LITERAL
%type<INT1> INT_CONSTANT
%type<FLOAT1> FLOAT_CONSTANT
%type<EXPAST> expression logical_and_expression equality_expression relational_expression additive_expression multiplicative_expression unary_expression primary_expression constant_expression expression_list logical_or_expression postfix_expression
%type<STMAST> compound_statement statement selection_statement iteration_statement statement_list assignment_statement
%type<REFAST> declarator l_expression parameter_declaration

%%

translation_unit 
        :  struct_specifier
        {
        	l_no_class=l_no;
	 		// top->printTable();
	 	}
 	| function_definition 
 	{
 		l_no_class=l_no;
 		top->printTable();
 	}
 	| translation_unit function_definition 
 	{
 		l_no_class=l_no;
 		top->printTable();
 	}
        | translation_unit struct_specifier
        {
        	l_no_class=l_no;
	 		top->printTable();
	 	}
        ;

struct_specifier 
        : { top_local = new symTab();}STRUCT IDENTIFIER '{' declaration_list '}' ';'
        { 
        	l_no_class=l_no;
			top->put($3,top_local->total_width(),0,new base_type("STRUCT"),top_local);
		}
        ;

function_definition
	: {top_local = new symTab();} type_specifier {ret = type1; offset = 0;} fun_declarator 
	{ 
		l_no_class=l_no;
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
		l_no_class=l_no;
		top->put(name_func,top_local->total_width(),0,ret,top_local);
	}
	;

type_specifier                   // This is the information 
        : VOID 	                 // that gets associated with each identifier
        { 
        	l_no_class=l_no;
        	type1 = old_type = new base_type("void");
    	  	width = old_width = 0;
    	}
        | INT
        { 
        	l_no_class=l_no;
        	type1 = old_type = new base_type("int");
    	  	width = old_width = 4;
    	}   
		| FLOAT
		{
			l_no_class=l_no;
			type1  = old_type = new base_type("float");
			width  = old_width = 4;
		} 
        | STRUCT IDENTIFIER 
        {
        	l_no_class=l_no;
        	type1 = old_type = new base_type("struct "+$2);
        	width = old_width = top->struct_size($2);
        }
        ;

fun_declarator
	: IDENTIFIER '(' parameter_list ')' 
	{
		l_no_class=l_no;
		name_func = $1;
	}
	| IDENTIFIER '(' ')' 
	{
		l_no_class=l_no;
		name_func = $1;
	}
    | '*' fun_declarator  //The * is associated with the 
    {
    	l_no_class=l_no;
    	ret = new pointer_type(ret->t);
    }
	;                      //function name


parameter_list
	: parameter_declaration 
	{
		l_no_class=l_no;
		top_local->put(name,width,offset,type1,1);
		offset+=width;
	}
	| parameter_list ',' parameter_declaration 
	{
		l_no_class=l_no;
		top_local->put(name,width,offset,type1,1);
		offset+=width;
	}
	;

parameter_declaration
	: type_specifier declarator 
	{
		l_no_class=l_no;
	}
	;

declarator
	: IDENTIFIER 
	{
		l_no_class=l_no;
		name = $1;
		if(top_local->InScope(name))
		{
			cerr<<"Error: Redeclaration of variable at line number "<<l_no<<endl;
			ABORT();
		}
	}
	| declarator '[' primary_expression']' // check separately that it is a constant
	{
		l_no_class=l_no;
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
    	l_no_class=l_no;
    	type1 = new pointer_type(type1->t);
    	old_type = new pointer_type(old_type->t);
    }
    ;

primary_expression 
        : IDENTIFIER
        {
        	l_no_class=l_no;
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
        	l_no_class=l_no;
        	$$ = new int_astnode($1);val=$1;
        } 
        | FLOAT_CONSTANT
        {
        	l_no_class=l_no;
        	$$ = new float_astnode($1);val=-1
        	;}
        | STRING_LITERAL
        {
        	l_no_class=l_no;
        	$$ = new string_astnode($1);val=-1
        	;}
        | '(' expression ')'
        {
        	l_no_class=l_no;
        	$$ = $2;
        } 
        ;

compound_statement
	: '{' '}' 
	{
		l_no_class=l_no;
		$$ = new empty_astnode();
		($$)->print(0);
		delete $$;
	}
	| '{' statement_list '}' 
	{
		l_no_class=l_no;
		$$ = new block_astnode($2);
		($$)->print(0);
		delete $$;
	}
    | '{' declaration_list statement_list '}' 
    {
    	l_no_class=l_no;
		$$ = new block_astnode($3);
		($$)->print(0);
		delete $$;
	}
	;

statement_list
	: statement		
	{
		l_no_class=l_no;
		$$ = new list_astnode($1);
	}
    | statement_list statement	
    {
    	l_no_class=l_no;
    	$$ = new list_astnode($2, $1);
    }
	;

statement
        : '{' statement_list '}'  
        {
        	l_no_class=l_no;
        	$$ = new block_astnode($2); 
        }
        | selection_statement
		{
			l_no_class=l_no;
			$$ = $1;
		} 	
        | iteration_statement
        {
        	l_no_class=l_no;
        	$$ = $1;
        } 	
		| assignment_statement
		{
			l_no_class=l_no;
			$$ = $1;
		}
        | RETURN expression ';'
        {
        	l_no_class=l_no;
        	$$ = new return_astnode($2);
        }	
        ;

assignment_statement
	: ';'
	{
		l_no_class=l_no;
		$$ = new empty_astnode(); 
	} 								
	|  expression ';'
	{
		l_no_class=l_no;
		$$ = $1;
	}  
	;

expression             //assignment expressions are right associative
        :  logical_or_expression
        {
        	l_no_class=l_no;
        	$$ = $1;
        }
        |  unary_expression '=' expression
        {
        	l_no_class=l_no;
        	$$ = new ass_astnode($1,$3);
        } 
        ;

logical_or_expression            // The usual hierarchy that starts here...
	: logical_and_expression
	{
		l_no_class=l_no;
		$$ = $1;
	}
    | logical_or_expression OR_OP logical_and_expression
    {
    	l_no_class=l_no;
    	$$ = new binary_astnode("OR_OP",$1,$3);
    }
	;
logical_and_expression
        : equality_expression
        {
        	l_no_class=l_no;
        	$$ = $1;
        }
        | logical_and_expression AND_OP equality_expression
        {
        	l_no_class=l_no;
        	$$ = new binary_astnode("And",$1,$3);
        } 
	;

equality_expression
	: relational_expression
	{
		l_no_class=l_no;
		$$ = $1;
	} 
    | equality_expression EQ_OP relational_expression
    {
    	l_no_class=l_no;
    	$$ = new binary_astnode("EQ_OP",$1,$3);
    } 	
	| equality_expression NE_OP relational_expression
	{
		l_no_class=l_no;
		$$ = new binary_astnode("NE_OP",$1,$3);
	}
	;
relational_expression
	: additive_expression
	{
		l_no_class=l_no;
		$$ = $1;
	}
    | relational_expression '<' additive_expression 
    {
    	l_no_class=l_no;
    	$$ = new binary_astnode("LT",$1,$3);
    }
	| relational_expression '>' additive_expression
	{
		l_no_class=l_no;
		$$ = new binary_astnode("GT",$1,$3);
	} 
	| relational_expression LE_OP additive_expression
	{
		l_no_class=l_no;
		$$ = new binary_astnode("LE_OP",$1,$3);
	} 
    | relational_expression GE_OP additive_expression
    {
    	l_no_class=l_no;
    	$$ = new binary_astnode("GE_OP",$1,$3);
    } 
	;

additive_expression 
	: multiplicative_expression
	{
		l_no_class=l_no;
		$$ = $1;
	}
	| additive_expression '+' multiplicative_expression
	{
		l_no_class=l_no;
		$$ = new binary_astnode("PLUS",$1,$3);
	} 
	| additive_expression '-' multiplicative_expression
	{
		l_no_class=l_no;
		$$ = new binary_astnode("MINUS",$1,$3);
	} 
	;

multiplicative_expression
	: unary_expression
	{
		l_no_class=l_no;
		$$ = $1;
	}
	| multiplicative_expression '*' unary_expression
	{
		l_no_class=l_no;
		$$ = new binary_astnode("Multiply",$1,$3);
	} 
	| multiplicative_expression '/' unary_expression
	{
		l_no_class=l_no;
		$$ = new binary_astnode("Divide",$1,$3);
	} 
	;
unary_expression
	: postfix_expression
	{
		l_no_class=l_no;
		$$ = $1;
	}  				
	| unary_operator postfix_expression
	{
		l_no_class=l_no;
		$$ = new unary_astnode($1,$2);
	} 
	;

postfix_expression
	: primary_expression
	{
		l_no_class=l_no;
		$$ = $1;
	}  				
    | IDENTIFIER '(' ')'
    {
    	l_no_class=l_no;
    	$$ = new func_astnode($1);
    } 				
	| IDENTIFIER '(' expression_list ')'
	{
		l_no_class=l_no;
		$$ = new func_astnode($1, $3);
	}
    | postfix_expression '[' expression ']'
    {
    	l_no_class=l_no;
    	$$ = new arrref_astnode($1, $3);  
    }  
    | postfix_expression '.' IDENTIFIER
    {
    	l_no_class=l_no;
    	id_astnode *x = new id_astnode($3);
    	$$ = new member_astnode($1,x);
    }
    | postfix_expression PTR_OP IDENTIFIER
	{
		l_no_class=l_no;
		id_astnode *x = new id_astnode($3);
   		$$ = new arrow_astnode($1,x);
    } 
	| postfix_expression INC_OP 	// ... and ends here
	{
		l_no_class=l_no;
		$$ = new unary_astnode("PP", $1);
	}			
	;

l_expression                // A separate non-terminal for l_expressions
        : IDENTIFIER
        {
        	l_no_class=l_no;
        	$$ = new id_astnode($1);
        }
        | l_expression '[' expression ']'
        {
        	l_no_class=l_no;
        	$$ = new arrref_astnode($1, $3);  
        }  	
        | '*' l_expression
        {
        	l_no_class=l_no;
        	$$ = new deref_astnode($2);
        }
        | l_expression '.' IDENTIFIER
        {
        	l_no_class=l_no;
        	id_astnode *x = new id_astnode($3);
	        $$ = new member_astnode($1,x);
	    }
        | l_expression PTR_OP IDENTIFIER
        {
        	l_no_class=l_no;
        	id_astnode *x = new id_astnode($3);
	        $$ = new arrow_astnode($1,x);
	    }
        | '(' l_expression ')'
        {
        	l_no_class=l_no;
        	$$ = $2;
        }	
        ;

expression_list
        : expression
        {
        	l_no_class=l_no;
        	$$ = new explist_astnode($1);
        }
        | expression_list ',' expression
        {
        	l_no_class=l_no;
        	$$ = new explist_astnode($1, $3);
        }
	;

unary_operator
        : '-'
        {
        	l_no_class=l_no;
        	$$ = "-";
        }
		| '!'
		{
			l_no_class=l_no;
			$$ = "!";
		}
        | '&'
        {
        	l_no_class=l_no;
        	$$ = "&";
        }
        | '*' 	
        {
        	l_no_class=l_no;
        	$$ = "*";
        }
	;

selection_statement
        : IF '(' expression ')' statement ELSE statement
        {
        	l_no_class=l_no;
        	$$ = new if_astnode($3, $5, $7);
        } 
	;

iteration_statement
	: WHILE '(' expression ')' statement
	{
		l_no_class=l_no;
		$$ = new while_astnode($3, $5);
	}
	| FOR '(' expression ';' expression ';' expression ')' statement  //modified this production
	{
		l_no_class=l_no;
		$$ = new for_astnode($3,$5, $7, $9);
	}
    ;

declaration_list
        : declaration  		
        {
        	l_no_class=l_no;
        }			
        | declaration_list declaration
        {
        	l_no_class=l_no;
        }
	;

declaration
	: type_specifier declarator_list';' 
	{
		l_no_class=l_no;
	}
	;

declarator_list
	: declarator 
	{
		l_no_class=l_no;
		top_local->put(name,width,offset,type1,0);
		offset+=width;
		width = old_width;
		type1 = old_type;
	}
	| declarator_list ',' declarator 
	{
		l_no_class=l_no;
		top_local->put(name,width,offset,type1,0);
		offset+=width;
		width = old_width;
		type1 = old_type;
	}
 	;
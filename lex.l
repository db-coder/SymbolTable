

// There may be some flexer directives here

%%
[ \t\n]                                    //skip
void														return Parser::VOID;
int															return Parser::INT;
float														return Parser::FLOAT;
if 						                    				return Parser::IF;
else 					                    				return Parser::ELSE;
while		                    							return Parser::WHILE;
for 					                    				return Parser::FOR;
return 														return Parser::RETURN;
struct														return Parser::STRUCT;
[[:alpha:]_][[:alnum:]_]*									{Parser::d_val__ = std::string(matched()); return Parser::IDENTIFIER;}
([1-9][0-9]*)|(0[bB][01]*)|(0[0-7]*)|(0[xX][0-9a-fA-F]*)	{std::string::size_type sz; Parser::d_val__ = std::stoi(matched(),&sz); return Parser::INT_CONSTANT;}
([0-9]+)"."[[:digit:]]*([eE][+-]?)?[[:digit:]]*				{std::string::size_type sz; Parser::d_val__ = std::stof(matched(),&sz); return Parser::FLOAT_CONSTANT;}
"\""(\\(t|n|\\|\")|[^"])*"\""								{Parser::d_val__ = std::string(matched()); return Parser::STRING_LITERAL;}
"=="														return Parser::EQ_OP;
"!="														return Parser::NE_OP;
"<="														return Parser::LE_OP;
">="														return Parser::GE_OP;
"&&"														return Parser::AND_OP;
"||"														return Parser::OR_OP;
"++"														return Parser::INC_OP;
"->"														return Parser::PTR_OP;
"!"															return '!';
"="															return '=';
"-"															return '-';
"+"                                         				return '+';
"*"															return '*';
"&"															return '&';
"/"															return '/';
","                                         				return ',';
"<"															return '<';
">"															return '>';
"("                                         				return '(';
")"															return ')';
"{"                                         				return '{';
"}"                                         				return '}';
"["                                         				return '[';
"]"                                         				return ']';
";"                                         				return ';';
"."															return '.';
.                                             
                                      

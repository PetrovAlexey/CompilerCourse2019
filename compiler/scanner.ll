%option noyywrap
%option yylineno
%{
    #include "Scanner.h"
    //#include "common.h"
    #include "parser.tab.hh"
    #include <Identifier.h>
    #include <iostream>
    #include <string>
    #include <stdio.h>

    #undef  YY_DECL
    #define YY_DECL int Scanner::yylex( yy::Parser::semantic_type * const lval, yy::Parser::location_type *loc )

    #define YY_USER_ACTION loc->columns(yyleng); 

%}

%option c++
%option yyclass="Scanner"

T_ANTI       "!"
T_LESS       "<"
T_EQ         "="
T_MUL        "*"
T_MOD        "%"
T_MINUS      "-"
T_PLUS       "+"
T_RPARENTH   ")"
T_LPARENTH   "("
T_RBRACKET   "]"
T_LBRACKET   "["
T_RBRACE     "}"
T_LBRACE     "{"
T_SEMI	     ";"
T_COMMA	     ","
T_DOT	     "."
T_AND        "&&"
T_OR         "||"
T_CLASS      "class"
T_PUBLIC     "public"
T_PRIVATE    "private"
T_STATIC     "static"
T_VOID       "void"
T_MAIN       "main"
T_EXTENDS    "extends"
T_RETURN     "return"
T_IF         "if"
T_ELSE       "else"
T_WHILE      "while"
T_SOUT       "System.out.println"
T_LENGTH     "length"
T_NEW        "new"
T_THIS       "this"
T_TRUE       "true"
T_FALSE      "false"
T_STRING     "String"
T_BOOLEAN    "boolean"
T_INT        "int"
T_N          "\n"
T_T          "\t"

T_DIGIT [0-9]
T_LETTER [a-zA-Z_]
T_NUM [1-9]{T_DIGIT}*|0
T_ID {T_LETTER}({T_DIGIT}|{T_LETTER})*
T_COMMENT 	\/\/(.)*\n
T_SPACE		(" "|"\v"|"\r")+

%%

%{
    yylval = lval;
    loc->step();

%}

{T_N} 	{ Process(Tokens::T_N); loc->lines(yyleng); loc->step(); }

{T_T}	{ Process(Tokens::T_T); }

{T_LBRACKET}    { std::string symbol = "LBRACKET"; return Process(Tokens::T_LBRACKET); }
{T_RBRACKET}    { std::string symbol = "RBRACKET"; return Process(Tokens::T_RBRACKET); }
{T_OR}          { std::string symbol = "OR"; return Process(Tokens::T_OR); }
{T_DOT}         { std::string symbol = "DOT"; return Process(Tokens::T_DOT); }
{T_COMMA}       { std::string symbol = "COMMA";  return Process(Tokens::T_COMMA); }
{T_SEMI}        { std::string symbol = "SEMI";  return Process(Tokens::T_SEMI); }

{T_LBRACE}      { std::string symbol = "LBRACE";  return Process(Tokens::T_LBRACE); }
{T_RBRACE}      { std::string symbol = "RBRACE";  return Process(Tokens::T_RBRACE); }
{T_LPARENTH}  	{ std::string symbol = "LPARENTH";  return Process(Tokens::T_LPARENTH); }
{T_RPARENTH} 	{ std::string symbol = "RPARENTH";  return Process(Tokens::T_RPARENTH); }

{T_TRUE} 	{ std::string symbol = "LOGICAL_TRUE";  return Process(Tokens::T_TRUE); }
{T_FALSE} 	{ std::string symbol = "LOGICAL_FALSE";  return Process(Tokens::T_FALSE); }
{T_THIS} 	{ std::string symbol = "THIS";  return Process(Tokens::T_THIS); }
{T_NEW} 	{ std::string symbol = "NEW";  return Process(Tokens::T_NEW); }
{T_INT} 	{ std::string symbol = "INT";  return Process(Tokens::T_INT); }
{T_IF} 		{ std::string symbol = "IF";  return Process(Tokens::T_IF); }
{T_ELSE} 	{ std::string symbol = "ELSE";  return Process(Tokens::T_ELSE); }
{T_WHILE} 	{ std::string symbol = "WHILE";  return Process(Tokens::T_WHILE); }
{T_SOUT} 	{ std::string symbol = "SOUT";  return Process(Tokens::T_SOUT); }
{T_CLASS} 	{ std::string symbol = "CLASS";  return Process(Tokens::T_CLASS); }
{T_PUBLIC}  { std::string symbol = "PUBLIC";  return Process(Tokens::T_PUBLIC); }
{T_STATIC}  { std::string symbol = "STATIC";  return Process(Tokens::T_STATIC); }
{T_VOID} 	{ std::string symbol = "VOID";  return Process(Tokens::T_VOID); }
{T_MAIN} 	{ std::string symbol = "MAIN";  return Process(Tokens::T_MAIN); }
{T_STRING} 	{ std::string symbol = "STRING";  return Process(Tokens::T_STRING); }
{T_EXTENDS} { std::string symbol = "EXTENDS";  return Process(Tokens::T_EXTENDS); }
{T_PRIVATE} { std::string symbol = "PRIVATE";  return Process(Tokens::T_PRIVATE); }
{T_LENGTH}  { std::string symbol = "LENGTH";  return Process(Tokens::T_LENGTH); }
{T_BOOLEAN} { std::string symbol = "BOOL";  return Process(Tokens::T_BOOLEAN); }
{T_RETURN}  { std::string symbol = "RETURN";  return Process(Tokens::T_RETURN); }

{T_PLUS} 	{ std::string symbol = "PLUS";  return Process(Tokens::T_PLUS); }
{T_MINUS} 	{ std::string symbol = "MINUS";  return Process(Tokens::T_MINUS); }
{T_MUL} 	{ std::string symbol = "MUL";  return Process(Tokens::T_MUL); }
{T_MOD} 	{ std::string symbol = "MOD";  return Process(Tokens::T_MOD); }
{T_EQ} 		{ std::string symbol = "EQ";  return Process(Tokens::T_EQ); }
{T_AND} 	{ std::string symbol = "AND";  return Process(Tokens::T_AND); }
{T_LESS} 	{ std::string symbol = "LESS";  return Process(Tokens::T_LESS); }
{T_ANTI} 	{ std::string symbol = "ANTI";  return Process(Tokens::T_ANTI); }

{T_ID} {
    std::string symbol = "ID";
    std::string data = YYText();
    

    std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
    yylval->emplace<std::unique_ptr<const Identifier>>(std::make_unique<const Identifier>(converter.from_bytes(data)));
    return Process(Tokens::T_ID);
}
{T_NUM} {
    std::string symbol = "CONST";
    std::string data = YYText();
    

    yylval->emplace<int>(std::stoi(data));
    return Process(Tokens::T_NUM);
}

{T_COMMENT}	{ Process(Tokens::T_COMMENT); loc->lines(yyleng); loc->step(); }
{T_SPACE}   { Process(Tokens::T_SPACE); loc->step();}

. { printf("unknown"); return Process(Tokens::T_Unknown); }
%%

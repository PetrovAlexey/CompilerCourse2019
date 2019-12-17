%require "3.4"
%language "c++"
%defines
%define api.parser.class { Parser }
%define api.value.type variant
%define api.value.automove true
%define parse.assert true
%define parse.error verbose
%parse-param { std::unique_ptr<const Goal>& syntaxTreeRoot }
%parse-param { std::unique_ptr<Scanner>& scanner }
%locations

%code requires {
#include <SerializeVisitor.h>
#include <Declarations.h>
#include <Expressions.h>
#include <Goal.h>
#include <Identifier.h>
#include <MainClass.h>
#include <Statements.h>
#include <Types.h>
using namespace SyntaxTree;

#include <string>
#include <vector>
#include <codecvt>
#include <locale>

class Scanner;
}

%code {
#include "Scanner.h"
#undef yylex
#define yylex scanner->yylex
}

%token T_EOF 0
%token T_ANTI
%token T_LESS
%token T_EQ
%token T_MUL
%token T_MOD
%token T_MINUS
%token T_PLUS
%token T_RPARENTH
%token T_LPARENTH
%token T_RBRACKET
%token T_LBRACKET
%token T_RBRACE
%token T_LBRACE
%token T_SEMI
%token T_COMMA
%token T_DOT
%token T_AND
%token T_OR
%token T_CLASS
%token T_PUBLIC
%token T_PRIVATE
%token T_STATIC
%token T_VOID
%token T_MAIN
%token T_EXTENDS
%token T_RETURN
%token T_IF
%token T_ELSE
%token T_WHILE
%token T_SOUT
%token T_LENGTH
%token T_NEW
%token T_THIS
%token T_TRUE
%token T_FALSE
%token T_STRING
%token T_BOOLEAN
%token T_INT
%token <int> T_NUM
%token <std::unique_ptr<const Identifier>> T_ID
%token T_COMMENT
%token T_SPACE
%token T_N
%token T_T
%token T_Unknown

%left T_EQ
%left T_OR
%left T_AND
%left T_LESS
%left T_PLUS T_MINUS
%left T_MUL T_MOD
%right T_ANTI
%left T_LBRACKET T_DOT T_LPARENTH

%type <std::unique_ptr<const Goal>> goal
%type <std::unique_ptr<MainClass>> main_class
%type <std::unique_ptr<const ClassDeclaration>> class_declaration
%type <std::vector<std::unique_ptr<const ClassDeclaration>>> class_declarations
%type <std::unique_ptr<const MethodDeclaration>> method_declaration
%type <std::vector<std::unique_ptr<const MethodDeclaration>>> method_declarations
%type <std::vector<std::unique_ptr<const Argument>>> arguments
%type <std::unique_ptr<const VariableDeclaration>> variable_declaration
%type <std::vector<std::unique_ptr<const VariableDeclaration>>> variable_declarations
%type <std::unique_ptr<const IStatement>> statement
%type <std::vector<std::unique_ptr<const IStatement>>> statements
%type <std::unique_ptr<const IExpression>> expression
%type <std::vector<std::unique_ptr<const IExpression>>> expressions
%type <std::unique_ptr<const Type>> type

%%

goal:
    main_class class_declarations T_EOF {
        syntaxTreeRoot = std::make_unique<const Goal>($1, $2, @1.begin.line);
        $$ = nullptr;
    }
;

main_class:
    T_CLASS T_ID T_LBRACE T_PUBLIC T_STATIC T_VOID T_MAIN T_LPARENTH T_STRING T_LBRACKET T_RBRACKET T_ID T_RPARENTH T_LBRACE statement T_RBRACE T_RBRACE {
        $$ = std::make_unique<MainClass>($2, $12, $15, @1.begin.line);
    }
;

class_declarations:
    %empty {
        $$ = std::move(std::vector<std::unique_ptr<const ClassDeclaration>>());
    }
    | class_declarations class_declaration {
        auto&& v = $1;
        v.push_back($2);
        $$ = std::move(v);
    }
;

class_declaration:
    T_CLASS T_ID T_LBRACE variable_declarations method_declarations T_RBRACE {
        $$ = std::make_unique<const ClassDeclaration>($2, nullptr, $4, $5, @1.begin.line);
    }
    | T_CLASS T_ID T_EXTENDS T_ID T_LBRACE variable_declarations method_declarations T_RBRACE {
        $$ = std::make_unique<const ClassDeclaration>($2, $4, $6, $7, @1.begin.line);
    }
;

method_declarations:
    %empty {
        $$ = std::move(std::vector<std::unique_ptr<const MethodDeclaration>>());
    }
    | method_declarations method_declaration {
        auto&& v = $1;
        v.push_back($2);
        $$ = std::move(v);
    }
;

method_declaration:
    T_PUBLIC type T_ID T_LPARENTH arguments T_RPARENTH T_LBRACE variable_declarations statements T_RETURN expression T_SEMI T_RBRACE {
        $$ = std::make_unique<const MethodDeclaration>($2, $3, $11, $5, $8, $9, AM_Public, @1.begin.line);
    }
    | T_PRIVATE type T_ID T_LPARENTH arguments T_RPARENTH T_LBRACE variable_declarations statements T_RETURN expression T_SEMI T_RBRACE {
        $$ = std::make_unique<const MethodDeclaration>($2, $3, $11, $5, $8, $9, AM_Private, @1.begin.line);
    }
;

arguments:
    %empty {
        $$ = std::move(std::vector<std::unique_ptr<const Argument>>());
    }
    | type T_ID {
        $$ = std::vector<std::unique_ptr<const Argument>>();
        $$.push_back(std::make_unique<Argument>($1, $2));
    }
    | arguments T_COMMA type T_ID {
        auto&& v = $1;
        v.push_back(std::make_unique<Argument>($3, $4));
        $$ = std::move(v);
    }
;

variable_declarations:
    %empty {
        $$ = std::move(std::vector<std::unique_ptr<const VariableDeclaration>>());
    }
    | variable_declarations variable_declaration {
        auto&& v = $1;
        v.push_back($2);
        $$ = std::move(v);
    }
;

variable_declaration:
    type T_ID T_SEMI {
        $$ = std::make_unique<const VariableDeclaration>($1, $2, @1.begin.line);
    }
;

statements:
    %empty {
        $$ = std::move(std::vector<std::unique_ptr<const IStatement>>());
    }
    | statement statements {
        auto&& v = $2;
        v.insert(v.begin(), $1);
        $$ = std::move(v);
    }
;

statement:
    T_LBRACE statements T_RBRACE {
        $$ = std::make_unique<const CompoundStatement>($2, @1.begin.line);
    }
    | T_IF T_LPARENTH expression T_RPARENTH statement T_ELSE statement {
        $$ = std::make_unique<const ConditionalStatement>($3, $5, $7, @1.begin.line);
    }
    | T_WHILE T_LPARENTH expression T_RPARENTH statement {
        $$ = std::make_unique<const LoopStatement>($3, $5, @1.begin.line);
    }
    | T_SOUT T_LPARENTH expression T_RPARENTH T_SEMI {
        $$ = std::make_unique<const PrintStatement>($3, @1.begin.line);
    }
    | T_ID T_EQ expression T_SEMI {
        $$ = std::make_unique<const AssignmentStatement>($1, $3, @1.begin.line);
    }
    | T_ID T_LBRACKET expression T_RBRACKET T_EQ expression T_SEMI {
        $$ = std::make_unique<const ArrayAssignmentStatement>($1, $3, $6, @1.begin.line);
    }
;

expressions:
    %empty {
        $$ = std::move(std::vector<std::unique_ptr<const IExpression>>());
    }
    | expression {
        $$ = std::move(std::vector<std::unique_ptr<const IExpression>>());
        $$.push_back($1);
    }
    | expressions T_COMMA expression {
        auto&& v = $1;
        v.push_back($3);
        $$ = std::move(v);
    }
;

expression:
    expression T_AND expression {
        $$ = std::make_unique<const BinaryOperationExpression>(BOT_And, $1, $3, @1.begin.line);
    }
    | expression T_OR expression {
        $$ = std::make_unique<const BinaryOperationExpression>(BOT_Or, $1, $3, @1.begin.line);
    }
    | expression T_LESS expression {
        $$ = std::make_unique<const BinaryOperationExpression>(BOT_Less, $1, $3, @1.begin.line);
    }
    | expression T_PLUS expression {
        $$ = std::make_unique<const BinaryOperationExpression>(BOT_Add, $1, $3, @1.begin.line);
    }
    | expression T_MINUS expression {
        $$ = std::make_unique<const BinaryOperationExpression>(BOT_Sub, $1, $3, @1.begin.line);
    }
    | expression T_MUL expression {
        $$ = std::make_unique<const BinaryOperationExpression>(BOT_Mul, $1, $3, @1.begin.line);
    }
    | expression T_MOD expression {
        $$ = std::make_unique<const BinaryOperationExpression>(BOT_Mod, $1, $3, @1.begin.line);
    }
    | expression T_LBRACKET expression T_RBRACKET {
        $$ = std::make_unique<const SquareBracketExpression>($1, $3, @1.begin.line);
    }
    | expression T_DOT T_LENGTH {
        $$ = std::make_unique<const LengthExpression>($1, @1.begin.line);
    }
    | expression T_DOT T_ID T_LPARENTH expressions T_RPARENTH {
        $$ = std::make_unique<const MethodCallExpression>($1, $3, $5, @1.begin.line);
    }
    | T_NUM {
        $$ = std::make_unique<const IntegerLiteralExpression>($1, @1.begin.line);
    }
    | T_TRUE {
        $$ = std::make_unique<const BooleanLiteralExpression>(true, @1.begin.line);
    }
    | T_FALSE {
        $$ = std::make_unique<const BooleanLiteralExpression>(false, @1.begin.line);
    }
    | T_ID {
        $$ = std::make_unique<const IdentifierExpression>($1, @1.begin.line);
    }
    | T_THIS {
        $$ = std::make_unique<const ThisExpression>(@1.begin.line);
    }
    | T_NEW T_INT T_LBRACKET expression T_RBRACKET {
        $$ = std::make_unique<const NewArrayExpression>($4, @1.begin.line);
    }
    | T_NEW T_ID T_LPARENTH T_RPARENTH {
        $$ = std::make_unique<const NewExpression>($2, @1.begin.line);
    }
    | T_ANTI expression {
        $$ = std::make_unique<const OppositeExpression>($2, @1.begin.line);
    }
    | T_LPARENTH expression T_RPARENTH {
        $$ = std::make_unique<const ParenthesesExpression>($2, @1.begin.line);
    }
;

type:
    T_INT T_LBRACKET T_RBRACKET {
        $$ = std::make_unique<const Type>(T_IntArray, @1.begin.line);
    }
    | T_BOOLEAN {
        $$ = std::make_unique<const Type>(T_Boolean, @1.begin.line);
    }
    | T_INT {
        $$ = std::make_unique<const Type>(T_Int, @1.begin.line);
    }
    | T_ID {
        $$ = std::make_unique<const Type>($1, @1.begin.line);
    }
;

%%

void yy::Parser::error (const location_type& loc, const std::string& msg) {
    std::cout << "error " << msg << " at " << loc.begin << " - " << loc.end << std::endl;
} 


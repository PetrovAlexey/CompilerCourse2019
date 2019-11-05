#pragma once

#if !defined (yyFlexLexerOnce)
#include <FlexLexer.h>
#endif // _!defined (yyFlexLexerOnce)

#include "parser.tab.hh"
#include "location.hh"

#include <Goal.h>

using Tokens = yy::Parser::token_type;

class Scanner : public yyFlexLexer {
public:
    Tokens Process(Tokens token) {
	    std::cout << token << std::endl;
        return token;
    };

    void Space();

    using FlexLexer::yylex;
    virtual int yylex( yy::Parser::semantic_type* const lval,
 					   yy::Parser::location_type *location1 );

private:
   /* yyval ptr */
   yy::Parser::semantic_type *yylval = nullptr;
};

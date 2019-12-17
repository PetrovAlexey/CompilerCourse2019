#include "Scanner.h"
#include "parser.tab.hh"
#include <Goal.h>
#include <Graph.h>
#include <SerializeVisitor.h>
#include <BuildSymbolTableVisitor.h>
#include <TypeCheckerVisitor.h>
#include <IrTreeBuilder.h>
#include <IrtSerializeVisitor.h>

enum ESerializeTree {
    ST_SyntaxTree,
    ST_IrTree,
    ST_None
};

void serializeGraph(ESerializeTree serializeTree, std::istream& in, std::wostream& out = std::wcout) {
    /* Построение SyntaxTree */
    auto lexer = std::make_unique<Scanner>();
    lexer->switch_streams(in, std::cerr);
    std::unique_ptr<const SyntaxTree::Goal> syntaxTreeRoot;
    yy::Parser parser(syntaxTreeRoot, lexer);
    parser.parse();

    /* Сериализация SyntaxTree */
    if (serializeTree == ST_SyntaxTree) {
        SerializeVisitor visitor;
        auto graph = std::make_shared<DirectedGraph>(L"SyntaxTreeGraph");
        visitor.RoundLaunch(graph, syntaxTreeRoot.get());
        GraphSerializer::GraphSerialize(*graph, out);
    }

    /* Построение SymbolTable */
    BuildSymbolTableVisitor symbolTableBuilder;
    auto symbolTable = std::make_shared<SyntaxTree::SymbolTable>();
    symbolTableBuilder.RoundLaunch(symbolTable, syntaxTreeRoot.get());
    if (symbolTableBuilder.GetErrorsNumber() != 0) {
        symbolTableBuilder.DumpErrors();
    }

    /* Проверка типов */
    TypeCheckerVisitor typeChecker;
    typeChecker.RoundLaunch(symbolTable, syntaxTreeRoot.get());
    if (typeChecker.GetErrorsNumber() != 0) {
        typeChecker.DumpErrors();
    }

    /* Построение IrTree */
    IrTreeBuilder irTreeBuilder(symbolTable);
    irTreeBuilder.RoundLaunch(syntaxTreeRoot.get());
    const auto irTreeRoot = irTreeBuilder.GetGoal();

    /* Сериализация IrTree */
    if (serializeTree == ST_IrTree) {
        IrTree::IrtSerializeVisitor visitor;
        auto graph = std::make_shared<DirectedGraph>(L"IrTreeGraph");
        visitor.RoundLaunch(graph, irTreeRoot);
        GraphSerializer::GraphSerialize(*graph, out);
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        serializeGraph(ST_None, std::cin);
    } else {
        // Первый аргумент - дерево для сериализации, "ast" | "irt" | "none"
        ESerializeTree serializeTree = ST_None;
        if (std::string(argv[1]) == "ast") {
            serializeTree = ST_SyntaxTree;
        } else if (std::string(argv[1]) == "irt") {
            serializeTree = ST_IrTree;
        }
        if (argc < 3) {
            serializeGraph(serializeTree, std::cin);
        } else {
            // Второй аргумент - input файл
            std::ifstream in(argv[2]);
            if (argc < 4) {
                serializeGraph(serializeTree, in);
            } else {
                // Третий аргумент - output файл
                std::wofstream out(argv[3]);
                serializeGraph(serializeTree, in, out);
            }
        }
    }
}


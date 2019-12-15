#pragma once

#include <SyntaxTreeNode.h>
#include <SymbolTable.h>

#include <iostream>
#include <cassert>
#include <memory>
#include <vector>
#include <unordered_set>

#include "Visitor.h"

namespace SyntaxTree {

    class BuildSymbolTableVisitor: public IVisitor {
    public:
        BuildSymbolTableVisitor() = default;
        void RoundLaunch(std::shared_ptr<SymbolTable>& _symbolTable, const ISyntaxTreeNode* _syntaxTreeRoot);

        //--------- Не нужны для построения SymbolTable ---------------------------------------
        void VisitNode(const IdentifierExpression* identifierExpression) override { assert(false); }
        void VisitNode(const BinaryOperationExpression* binaryOperationExpression) override { assert(false); }
        void VisitNode(const SquareBracketExpression* squareBracketExpression) override { assert(false); }
        void VisitNode(const LengthExpression* lengthExpression) override { assert(false); }
        void VisitNode(const MethodCallExpression* methodCallExpression) override { assert(false); }
        void VisitNode(const BooleanLiteralExpression* booleanLiteralExpression) override { assert(false); }
        void VisitNode(const IntegerLiteralExpression* integerLiteralExpression) override { assert(false); }
        void VisitNode(const ThisExpression* thisExpression) override { assert(false); }
        void VisitNode(const NewExpression* newExpression) override { assert(false); }
        void VisitNode(const NewArrayExpression* newArrayExpression) override { assert(false); }
        void VisitNode(const OppositeExpression* oppositeExpression) override { assert(false); }
        void VisitNode(const ParenthesesExpression* parenthesesExpression) override { assert(false); }

        void VisitNode(const CompoundStatement* compoundStatement) override { assert(false); }
        void VisitNode(const ConditionalStatement* conditionalStatement) override { assert(false); }
        void VisitNode(const LoopStatement* loopStatement) override { assert(false); }
        void VisitNode(const PrintStatement* printStatement) override { assert(false); }
        void VisitNode(const AssignmentStatement* assignmentStatement) override { assert(false); }
        void VisitNode(const ArrayAssignmentStatement* arrayAssignmentStatement) override { assert(false); }

        void VisitNode(const Type* type) override { assert(false); }
        void VisitNode(const Identifier* identifier) override { assert(false); }
        //-----------------------------------------------------------------------------------------

        void VisitNode(const ClassDeclaration* classDeclaration) override;
        void VisitNode(const VariableDeclaration* variableDeclaration) override;
        void VisitNode(const MethodDeclaration* methodDeclaration) override;

        void VisitNode(const Goal* goal) override;
        void VisitNode(const MainClass* mainClass) override;

        void DumpErrors(std::wostream& os = std::wcerr) const;
        void GetErrors(std::vector<std::wstring>& _errors) const;
        int GetErrorsNumber() const { return errors.size(); }

    private:
        enum EScopeType {
            ST_Class,
            ST_Method
        };

        std::shared_ptr<SymbolTable> symbolTable{nullptr};

        EScopeType currentScope{ST_Class};
        std::unique_ptr<ClassInfo> currentClass;
        std::unique_ptr<MethodInfo> currentMethod;

        std::vector<std::wstring> errors;

        bool checkClassRedefinition(const std::wstring& className, int lineNumber);
        bool checkMethodRedefinition(const std::wstring& methodName, int lineNumber);
        bool checkMethodVariableRedefinition(const std::wstring& localVariableName, int lineNumber);
        bool checkFieldRedefinition(const std::wstring& fieldName, int lineNumber);
    };
}
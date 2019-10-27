#include "Goal.h"

namespace SyntaxTree {

    Goal::Goal(const MainClass* _mainClass, const std::vector<const ClassDeclaration*>& _classDeclarations)
    :   mainClass(std::make_unique<MainClass>(_mainClass))
    {
        for (auto _classDeclaration : _classDeclarations) {
            classDeclarations.emplace_back(_classDeclaration);
        }
    }

    const ClassDeclaration* Goal::GetClassDeclaration(int index) const {
        assert(index >= 0 && index < classDeclarations.size());
        return classDeclarations[index].get();
    }

    void Goal::GetClassDeclarations(std::vector<const ClassDeclaration*>& _classDeclarations) const {
        _classDeclarations.clear();
        for (int i = 0; i < classDeclarations.size(); ++i) {
            _classDeclarations.push_back(classDeclarations[i].get());
        }
    }
}
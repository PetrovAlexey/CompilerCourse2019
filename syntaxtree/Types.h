#pragma once

#include "Identifier.h"

#include <Visitor.h>

#include <memory>

namespace SyntaxTree {

    class IType : public ISyntaxTreeNode {
    };

    enum TType {
        T_Boolean,
        T_Int,
        T_IntArray
    };

    class SimpleType : public IType {
    public:
        explicit SimpleType(TType _type): type(_type) {}

        virtual void AcceptVisitor(IVisitor* visitor) const override { visitor->VisitNode(this); }

        TType GetType() const { return type; }
    private:
        TType type;
    };

    class IdentifierType : public IType {
    public:
        IdentifierType(std::unique_ptr<const Identifier>&& _identifier): identifier(std::move(_identifier)) {}

        virtual void AcceptVisitor(IVisitor* visitor) const override { visitor->VisitNode(this); }

        const Identifier* GetIdentifier() const { return identifier.get(); }
    private:
        std::unique_ptr<const Identifier> identifier;
    };

}





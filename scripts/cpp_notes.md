## [non-const static data member must be initialized out of line](https://stackoverflow.com/questions/18749071/why-does-a-static-data-member-need-to-be-defined-outside-of-the-class/18749251#18749251)

It's a rule of the language, known as the One Definition Rule. Within a program, each
static object (if it's used) must be defined once, and only once.

Class definitions typically go in header files, included in multiple translation units
(i.e. from multiple source files). If the static object's declaration in the header were
a definition, then you'd end up with multiple definitions, one in each unit that
includes the header, which would break the rule. So instead, it's not a definition, and
you must provide exactly one definition somewhere else.

In principle, the language could do what it does with inline functions, allowing
multiple definitions to be consolidated into a single one. But it doesn't, so we're
stuck with this rule.

[static data members](https://en.cppreference.com/w/cpp/language/static#Static_data_members)

Static data members are not associated with any object. They exist even if no objects of
the class have been defined. There is only one instance of the static data member in the
entire program with static storage duration, unless the keyword thread_local is used, in
which case there is one such object per thread with thread storage duration (since
C++11).

Static data members cannot be mutable.

Static data members of a class in namespace scope have external linkage if the class
itself has external linkage (i.e. is not a member of unnamed namespace). Local classes
(classes defined inside functions) and unnamed classes, including member classes of
unnamed classes, cannot have static data members.

A static data member may be declared inline. An inline static data member can be defined
in the class definition and may specify an initializer. It does not need an out-of-class
definition:

[constant static members](https://en.cppreference.com/w/cpp/language/static#Constant_static_members)

C++17, A static data member may be declared inline. An inline static data member can be
defined in the class definition and may specify an initializer. It does not need an
out-of-class definition:

If a static data member of integral or enumeration type is declared const (and not
volatile), it can be initialized with an initializer in which every expression is a
constant expression, right inside the class definition:

If a static data member of LiteralType is declared constexpr, it must be initialized
with an initializer in which every expression is a constant expression, right inside the
class definition;

If a const non-inline (since C++17) static data member or a constexpr
static data member (since C++11)(until C++17) is odr-used, a definition at namespace
scope is still required, but it cannot have an initializer. A definition may be provided
even though redundant (since C++17).

If a static data member is declared constexpr, it is implicitly inline and does not need
to be redeclared at namespace scope. This redeclaration without an initializer (formerly
required as shown above) is still permitted, but is deprecated.

## [Why are only static const integral types & enums allowed In-class Initialization?](https://stackoverflow.com/questions/9656941/why-cant-i-initialize-non-const-static-member-or-static-array-in-class)

The answer is hidden in Bjarne's quote read it closely, "C++ requires that every object
has a unique definition. That rule would be broken if C++ allowed in-class definition of
entities that needed to be stored in memory as objects."

Note that only static const integers can be treated as compile time constants. The
compiler knows that the integer value will not change anytime and hence it can apply its
own magic and apply optimizations, the compiler simply inlines such class members i.e,
they are not stored in memory anymore, As the need of being stored in memory is removed,
it gives such variables the exception to rule mentioned by Bjarne.

It is noteworthy to note here that even if static const integral values can have
In-Class Initialization, taking address of such variables is not allowed. One can take
the address of a static member if (and only if) it has an out-of-class definition.This
further validates the reasoning above.

enums are allowed this because values of an enumerated type can be used where ints are
expected.see citation above

functions/methods defined within a class are implicitly inline

## [static member variable in class template](https://stackoverflow.com/questions/19366615/static-member-variable-in-class-template)

For template class' static variable:

This is perfectly fine, in this case of defining it in the header the compiler will
insure there is only one instance, if we see the draft C++ standard section 3.2 One
definition rule paragraph 6 says(emphasis mine):

> There can be more than one definition of a class type (Clause 9), enumeration type
> (7.2), inline function with external linkage (7.1.2), class template (Clause 14),
> non-static function template (14.5.6), static data member of a class template
> (14.5.1.3), member function

we can then go to section 14.5.1.3 Static data members of class templates paragraph 1
says:

> A definition for a static data member may be provided in a namespace scope enclosing
> the definition of the static member’s class template.

```
template <typename T>
struct S
{
    static double something_relevant;
};

template <typename T>
double S<T>::something_relevant = 1.5;
```

in header

```
template< typename T >
class has_static {
    // inline method definition: provides the body of the function.
    static void meh() {}

    // method declaration: definition with the body must appear later
    static void fuh();

    // definition of a data member (i.e., declaration with initializer)
    // only allowed for const integral members
    static int const guh = 3;

    // declaration of data member, definition must appear later,
    // even if there is no initializer.
    static float pud;
};

// provide definitions for items not defined in class{}
// these still go in the header file

// this function is also inline, because it is a template
template< typename T >
void has_static<T>::fuh() {}

/* The only way to templatize a (non-function) object is to make it a static
   data member of a class. This declaration takes the form of a template yet
   defines a global variable, which is a bit special. */
template< typename T >
float has_static<T>::pud = 1.5f; // initializer is optional
```

## [Is static member variable initialized in a template class if the static menber is not used?](https://stackoverflow.com/questions/19341360/is-static-member-variable-initialized-in-a-template-class-if-the-static-menber-i/19341402#19341402)

no

> Unless a class template specialization has been explicitly instantiated (14.7.2) or
> explicitly specialized (14.7.3), the class template specialization is implicitly
> instantiated when the specialization is referenced in a context that requires a
> completely-defined object type or when the completeness of the class type affects the
> se- mantics of the program. The implicit instantiation of a class template
> specialization causes the implicit instantiation of the declarations, but not of the
> definitions or default arguments, of the class member func- tions, member classes,
> static data members and member templates; and it causes the implicit instantiation of
> the definitions of member anonymous unions. Unless a member of a class template or a
> member template has been explicitly instantiated or explicitly specialized, the
> specialization of the member is implicitly in- stantiated when the specialization is
> referenced in a context that requires the member definition to exist; in particular,
> the initialization (and any associated side-effects) of a static data member does not
> occur unless the static data member is itself used in a way that requires the
> definition of the static data member to exist.

The relevant section of the C++ draft standard comes under 14 Templates which is 14.7.1
Implicit instantiation paragraph 2 which says(emphasis mine):

> Unless a member of a class template or a member template has been explicitly
> instantiated or explicitly specialized, the specialization of the member is implicitly
> instantiated when the specialization is referenced in a context that requires the
> member definition to exist; in particular, the initialization (and any associated
> side-effects) of a static data member does not occur unless the static data member is
> itself used in a way that requires the definition of the static data member to exist.

We can also see paragraph 8 which says:

> The implicit instantiation of a class template does not cause any static data members
> of that class to be implicitly instantiated.

However if you add an explicit instantiation to the second case as follows you will see
2 as the results:

template<> bool A<int>::d = [](){regist<A<int>>(); return true;}();

## thrift annotation for customize equal or hash

graphene/ticket/if/TARGETS
cpp2_srcs
cpp2.declare_hash = 1, cpp2.declare_equal_to = 1

## Buck Config

.buckconfig.in
per directory config: dir/BUILD_MODE.bzl, and register in
fbsource/tools/buckconfigs/fbcode/build_mode.bcfg

processed by fbcode/tools/build/buck/gen_modes.py

generate fbsource/tools/buckconfigs/fbcode/modes/mode.bcfg

---

[CPP online compiler](https://www.onlinegdb.com/online_c++_compiler)

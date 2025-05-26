#include <memory>
#include <string>

namespace Foo {

class Class1 {
public:
    Class1(long);
public:
    virtual ~Class1();
};

// setting SWIFT_NONCOPYABLE doesn't have any effect:
// record 'Class2' is not automatically available: does not have a copy constructor or destructor; does this type have reference semantics
class Class2: Class1 {
public:
    Class2(); // cannot compile without this constructor when marking SWIFT_NONCOPYABLE
    Class2(const Class2 &) = delete;
    
    Class2(int);
    virtual ~Class2();

    class Private;
private:
    std::unique_ptr<Private> m_value;
}
// SWIFT_NONCOPYABLE

/*
Cannot compile when defined for two structs in file:
error: redefinition of 'SWIFT_NONCOPYABLE' with a different type: 'struct WrapClass2' vs 'class Class2'
 */
; 


// Does not work:
// record 'WrapClass2_1' is not automatically available: does not have a copy constructor or destructor; does this type have reference semantics?
struct WrapClass2_1 {
   WrapClass2_1(); // cannot compile without this constructor when marking SWIFT_NONCOPYABLE

   WrapClass2_1(Class2 && value);
   WrapClass2_1(int v);

private:
   Class2 m_value;
}
// SWIFT_NONCOPYABLE

/*
Cannot compile when defined for two structs in file:
error: redefinition of 'SWIFT_NONCOPYABLE' with a different type: 'struct WrapClass2' vs 'class Class2'
 */
; 


struct WrapClass2_2 {
   WrapClass2_2(); // cannot compile without this constructor when marking SWIFT_NONCOPYABLE

   WrapClass2_2(Class2 && value);
   WrapClass2_2(int v);

private:
   std::unique_ptr<Class2> m_value;
} SWIFT_NONCOPYABLE;

};


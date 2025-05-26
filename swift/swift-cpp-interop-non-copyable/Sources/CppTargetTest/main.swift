import TestLibCpp 

// Sample 1
/*
final class A { // wrap non-copyable
    let aa = Foo.Class2(123)
    init() {}
}

print(A())
*/

// Sample 2
/*
final class A { // wrap non-copyable
    let aa = Foo.WrapClass2_1(123)
    init() {}
}

print(A())
*/

// Sample 3
final class A { // wrap non-copyable
    let aa = Foo.WrapClass2_2(123)
    init() {}
}

print(A())

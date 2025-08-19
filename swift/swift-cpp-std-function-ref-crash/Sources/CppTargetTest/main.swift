import CppTarget


returnPtr(
    .init { retstruct in
        guard let retstruct else {
            preconditionFailure()
        }
        print("Ptr: \(retstruct.pointee)")
    }
)

returnReference(
    .init { retstruct in
        print("Ref: \(retstruct)")
    }
)

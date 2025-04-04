public final
class Cursor1<Key, Value>:Sequence, IteratorProtocol
{
    private
    let key:Key
    private
    let value:Value
    private
    var count:Int

    public
    init(key:Key, value:Value, count:Int)
    {
        self.key = key
        self.value = value
        self.count = count
    }

    @inline(never)
    public
    func next() -> (key:Key, value:Value)?
    {
        if  self.count == 0
        {
            return nil
        }
        else
        {
            self.count -= 1
            return (self.key, self.value)
        }
    }
}


public final
class Cursor2<Key, Value>:Sequence, IteratorProtocol
{
    private
    let key:Key
    private
    let value:Value
    private
    var count:Int

    public
    init(key:Key, value:Value, count:Int)
    {
        self.key = key
        self.value = value
        self.count = count
    }

    @inline(never)
    public
    func next() -> Pair?
    {
        if  self.count == 0
        {
            return nil
        }
        else
        {
            self.count -= 1
            return .init(key: self.key, value: self.value)
        }
    }
}

extension Cursor2
{
    public
    struct Pair
    {
        public
        let key:Key
        public
        let value:Value
    }
}


## 基础

<details>
<summary>
1、说明并比较关键词：strong, weak, assign, copy等等
</summary>

strong表示指向并拥有该对象。其修饰的对象引用计数会增加1。该对象只要引用计数不为0则不会被销毁。当然强行将其设为nil可以销毁它。

weak表示指向但不拥有该对象。其修饰的对象引用计数不会增加。无需手动设置，该对象会自行在内存中销毁。

assign主要用于修饰基本数据类型，如NSInteger和CGFloat，这些数值主要存在于栈上。

weak 一般用来修饰对象，assign一般用来修饰基本数据类型。原因是assign修饰的对象被释放后，指针的地址依然存在，造成野指针，在堆上容易造成崩溃。而栈上的内存系统会自动处理，不会造成野指针。

copy与strong类似。不同之处是strong的复制是多个指针指向同一个地址，而copy的复制每次会在内存中拷贝一份对象，指针指向不同地址。copy一般用在修饰有可变对应类型的不可变对象上，如NSString, NSArray, NSDictionary。

Objective-C 中，基本数据类型的默认关键字是atomic, readwrite, assign；普通属性的默认关键字是atomic, readwrite, strong。

1、属性readwrite，readonly，assign，retain，copy，nonatomic 各自什么作用，他们在那种情况下用?

```
    readwrite：默认的属性，可读可写，生成setter和getter方法。

    readonly：只读，只生成getter方法，也就是说不能修改变量。

    assign：用于声明基本数据类型（int、float）仅设置变量，是赋值属性。

    retain：持有属性，setter方法将传入的参数先保留,再赋值,传入的参数 引用计数retaincount 会加1
```

在堆上开辟一块空间，用指针a指向，然后将指针a赋值(assign)给指针b，等于是a和b同时指向这块堆空间，当a不使用这块堆空间的时候，是否要释放这块堆空间？答案是肯定要的，但是这件堆空间被释放后，b就成了野指针。

如何避免这样的问题？ 这就引出了引用计数器，当a指针这块堆空间的时候，引用计数器+1，当b也指向的时候，引用计数器变成了2，当a不再指向这块堆空间时，release-1，引用计数器为1，当b也不指向这块堆空间时，release-1，引用计数器为0，调用dealloc函数，空间被释放

总结：当数据类型为int，float原生类型时，可以使用assign。如果是上面那种情况（对象）就是用retain。

copy：是赋值特性,setter方法将传入对象赋值一份;需要完全一份新的变量时,直接从堆区拿。

当属性是 NSString、NSArray、NSDictionary时，既可以用strong 修饰，也可以用copy修饰。当用strong修饰的NSString 指向一个NSMutableString时，如果在不知情的情况下这个NSMutableString的别的引用修改了值，就会出现：一个不可变的字符串却被改变了的情况， 使用copy就不会出现这种情况。

 nonatomic：非原子性，可以多线程访问，效率高。

atomic：原子性，属性安全级别的表示，同一时刻只有一个线程访问，具有资源的独占性，但是效率很低。

strong：强引用，引用计数+ 1，ARC下，一个对象如果没有强引用，系统就会释放这个对象。

weak：弱引用，不会使引用计数+1.当一个指向对象的强引用都被释放时，这块空间依旧会被释放掉。

使用场景：在ARC下，如果使用XIB 或者SB 来创建控件，就使用 weak。纯代码创建控件时，用strong修饰，如果想用weak 修饰，就需要先创建控件，然后赋值给用weak修饰的对象。

查找了一些资料，发现主要原因是，controller需要拥有它自己的view（这个view是所以子控件的父view），因此viewcontroller对view就必须是强引用（strong reference）,得用strong修饰view。对于lable，它的父view是view，view需要拥有label，但是controller是不需要拥有label的。如果用strong修饰，在view销毁的情况下，label还仍然占有内存，因为controller还对它强引用；如果用wak修饰，在view销毁的时label的内存也同时被销毁，避免了僵尸指针出现。

用引用计数回答就是：因为Controller并不直接“拥有”控件，控件由它的父view“拥有”。使用weak关键字可以不增加控件引用计数，确保控件与父view有相同的生命周期。控件在被addSubview后，相当于控件引用计数+1；父view销毁后，所有的子view引用计数-1，则可以确保父view销毁时子view立即销毁。weak的控件在removeFromSuperview后也会立即销毁，而strong的控件不会，因为Controller还保有控件强引用。

总结归纳为：当控件的父view销毁时，如果你还想继续拥有这个控件，就用srtong；如果想保证控件和父view拥有相同的生命周期，就用weak。当然在大多数情况下用两个都是可以的。

使用weak的时候需要特别注意的是：先将控件添加到superview上之后再赋值给self，避免控件被过早释放。

作者：Silence_广
链接：https://www.jianshu.com/p/64866e2d5394
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
</details>

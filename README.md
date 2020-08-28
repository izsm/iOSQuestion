
## 基础

<details>
<summary>
####1、说明并比较关键词：`strong`, `weak`, `assign`, `copy`等等
</summary>

`strong`表示指向并拥有该对象。其修饰的对象引用计数会增加1。该对象只要引用计数不为0则不会被销毁。当然强行将其设为nil可以销毁它。

`weak`表示指向但不拥有该对象。其修饰的对象引用计数不会增加。无需手动设置，该对象会自行在内存中销毁。

`assign`主要用于修饰基本数据类型，如`NSInteger`和`CGFloat`，这些数值主要存在于栈上。

`weak` 一般用来修饰对象，`assign`一般用来修饰基本数据类型。原因是`assign`修饰的对象被释放后，指针的地址依然存在，造成野指针，在堆上容易造成崩溃。而栈上的内存系统会自动处理，不会造成野指针。

`copy`与`strong`类似。不同之处是`strong`的复制是多个指针指向同一个地址，而`copy`的复制每次会在内存中拷贝一份对象，指针指向不同地址。`copy`一般用在修饰有可变对应类型的不可变对象上，如`NSString`, `NSArray`, `NSDictionary`。

`Objective-C` 中，基本数据类型的默认关键字是`atomic`, `readwrite`, `assign`；普通属性的默认关键字是`atomic`, `readwrite`, `strong`。

1、属性`readwrite`，`readonly`，`assign`，`retain`，`copy`，`nonatomic` 各自什么作用，他们在那种情况下用?

```
    readwrite：默认的属性，可读可写，生成setter和getter方法。

    readonly：只读，只生成getter方法，也就是说不能修改变量。

    assign：用于声明基本数据类型（int、float）仅设置变量，是赋值属性。

    retain：持有属性，setter方法将传入的参数先保留,再赋值,传入的参数 引用计数retaincount 会加1
```

在堆上开辟一块空间，用指针a指向，然后将指针a赋值(`assign`)给指针b，等于是a和b同时指向这块堆空间，当a不使用这块堆空间的时候，是否要释放这块堆空间？答案是肯定要的，但是这件堆空间被释放后，b就成了野指针。

如何避免这样的问题？ 这就引出了引用计数器，当a指针这块堆空间的时候，引用计数器+1，当b也指向的时候，引用计数器变成了2，当a不再指向这块堆空间时，release-1，引用计数器为1，当b也不指向这块堆空间时，release-1，引用计数器为0，调用`dealloc`函数，空间被释放

总结：当数据类型为`int`，`float`原生类型时，可以使用`assign`。如果是上面那种情况（对象）就是用retain。

`copy`：是赋值特性,`setter`方法将传入对象赋值一份;需要完全一份新的变量时,直接从堆区拿。

当属性是` NSString`、`NSArray`、`NSDictionary`时，既可以用`strong` 修饰，也可以用`copy`修饰。当用`strong`修饰的`NSString` 指向一个`NSMutableString`时，如果在不知情的情况下这个`NSMutableString`的别的引用修改了值，就会出现：一个不可变的字符串却被改变了的情况， 使用`copy`就不会出现这种情况。

 `nonatomic`：非原子性，可以多线程访问，效率高。

`atomic`：原子性，属性安全级别的表示，同一时刻只有一个线程访问，具有资源的独占性，但是效率很低。

`strong`：强引用，引用计数+ 1，ARC下，一个对象如果没有强引用，系统就会释放这个对象。

`weak`：弱引用，不会使引用计数+1.当一个指向对象的强引用都被释放时，这块空间依旧会被释放掉。

使用场景：在ARC下，如果使用`XIB` 或者`SB` 来创建控件，就使用 `weak`。纯代码创建控件时，用`strong`修饰，如果想用`weak` 修饰，就需要先创建控件，然后赋值给用`weak`修饰的对象。

查找了一些资料，发现主要原因是，`controller`需要拥有它自己的`view`（这个`view`是所以子控件的父`view`），因此`viewcontroller`对`view`就必须是强引用（strong reference）,得用`strong`修饰`view`。对于`lable`，它的父`view`是`view`，`view`需要拥有`label`，但是`controller`是不需要拥有`label`的。如果用`strong`修饰，在`view`销毁的情况下，`label`还仍然占有内存，因为`controller`还对它强引用；如果用`weak`修饰，在`view`销毁的时侯`label`的内存也同时被销毁，避免了僵尸指针出现。

用引用计数回答就是：因为`Controller`并不直接“拥有”控件，控件由它的父`view`“拥有”。使用`weak`关键字可以不增加控件引用计数，确保控件与父`view`有相同的生命周期。控件在被`addSubview`后，相当于控件引用计数+1；父`view`销毁后，所有的子`view`引用计数-1，则可以确保父`view`销毁时子`view`立即销毁。`weak`的控件在`removeFromSuperview`后也会立即销毁，而`stron`g的控件不会，因为`Controller`还保有控件强引用。

总结归纳为：当控件的父`view`销毁时，如果你还想继续拥有这个控件，就用`srtong`；如果想保证控件和父`view`拥有相同的生命周期，就用`weak`。当然在大多数情况下用两个都是可以的。

使用`weak`的时候需要特别注意的是：先将控件添加到`superview`上之后再赋值给`self`，避免控件被过早释放。
</details>

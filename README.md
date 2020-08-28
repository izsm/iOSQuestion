
## 基础

<details>
<summary>
    <p><h2>1、说明并比较关键词：strong, weak, assign, copy等等</h2></p>
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

<details>
<summary>
<h2>2、atomatic和nonatomic区别和理解</h2>
</summary>

<br/><b>第一种</b><br/>

`atomic`和`nonatomic`区别用来决定编译器生成的`getter`和`setter`是否为原子操作。`atomic`提供多线程安全,是描述该变量是否支持多线程的同步访问，如果选择了`atomic` 那么就是说，系统会自动的创建`lock`锁，锁定变量。`nonatomic`禁止多线程，变量保护，提高性能。

> `atomic`：默认是有该属性的，这个属性是为了保证程序在多线程情况下，编译器会自动生成一些互斥加锁代码，避免该变量的读写不同步问题。

> `nonatomic`：如果该对象无需考虑多线程的情况，请加入这个属性，这样会让编译器少生成一些互斥加锁代码，可以提高效率。

> `atomic`的意思就是`setter/getter`这个函数，是一个原语操作。如果有多个线程同时调用`setter`的话，不会出现某一个线程执行完`setter`全部语句之前，另一个线程开始执行`setter`情况，相当于函数头尾加了锁一样，可以保证数据的完整性。`nonatomic`不保证`setter/getter`的原语行，所以你可能会取到不完整的东西。因此，在多线程的环境下原子操作是非常必要的，否则有可能会引起错误的结果。

比如`setter`函数里面改变两个成员变量，如果你用`nonatomic`的话，`getter`可能会取到只更改了其中一个变量时候的状态，这样取到的东西会有问题，就是不完整的。当然如果不需要多线程支持的话，用`nonatomic`就够了，因为不涉及到线程锁的操作，所以它执行率相对快些。

下面是载录的网上一段加了`atomic`的例子：
```
{lock}
    if (property != newValue) { 
        [property release]; 
        property = [newValue retain]; 
    }                   
{unlock}
```
可以看出来，用`atomic`会在多线程的设值取值时加锁，中间的执行层是处于被保护的一种状态，`atomic`是oc使用的一种线程保护技术，基本上来讲，就是防止在写入未完成的时候被另外一个线程读取，造成数据错误。而这种机制是耗费系统资源的，所以在iPhone这种小型设备上，如果没有使用多线程间的通讯编程，那么`nonatomic`是一个非常好的选择。

<br/><b>第二种</b><br/>

`atomic`和`nonatomic`用来决定编译器生成的`getter`和`setter`是否为原子操作。

<b>atomic</b>

设置成员变量的`@property`属性时，默认为`atomic`，提供多线程安全。

在多线程环境下，原子操作是必要的，否则有可能引起错误的结果。加了`atomic`，`setter`函数会变成下面这样：
```
{lock}
    if (property != newValue) { 
        [property release]; 
        property = [newValue retain]; 
    }                   
{unlock}
```
<b>nonatomic</b>

禁止多线程，变量保护，提高性能。

`atomic`是`Objc`使用的一种线程保护技术，基本上来讲，是防止在写未完成的时候被另外一个线程读取，造成数据错误。而这种机制是耗费系统资源的，所以在iPhone这种小型设备上，如果没有使用多线程间的通讯编程，那么`nonatomic`是一个非常好的选择。

指出访问器不是原子操作，而默认地，访问器是原子操作。这也就是说，在多线程环境下，解析的访问器提供一个对属性的安全访问，从获取器得到的返回值或者通过设置器设置的值可以一次完成，即便是别的线程也正在对其进行访问。如果你不指定 `nonatomic` ，在自己管理内存的环境中，解析的访问器保留并自动释放返回的值，如果指定了 `nonatomic` ，那么访问器只是简单地返回这个值。

</details>

<details>
<summary>
<h2>3、请说明并比较以下关键词：__weak，__block</h2>
</summary>

`__weak`与`weak`基本相同。前者用于修饰变量（variable），后者用于修饰属性（property）。`__weak` 主要用于防止`block`中的循环引用。
`__block`也用于修饰变量。它是引用修饰，所以其修饰的值是动态变化的，即可以被重新赋值的。`__block`用于修饰某些`block`内部将要修改的外部变量。
_`_weak`和`__block`的使用场景几乎与`block`息息相关。而所谓`block`，就是`Objective-C`对于闭包的实现。闭包就是没有名字的函数，或者理解为指向函数的指针。
</details>

<details>
<summary>
<h2>4、什么情况下会出现循环引用？</h2>
</summary>
</details>

<details>
<summary>
<h2>5、什么是KVO和KVC?他们的使用场景是什么？</h2>
</summary>
</details>

<details>
<summary>
<h2>6、Runtime应用</h2>
</summary>

`Runtim`简直就是做大型框架的利器。它的应用场景非常多，下面就介绍一些常见的应用场景。

>* 关联对象`(Objective-C Associated Objects)`给分类增加属性
>* 方法魔法`(Method Swizzling)`方法添加和替换和`KVO`
>* 实现消息转发(热更新)解决Bug(JSPatch)
>* 实现`NSCoding`的自动归档和自动解档
>* 实现字典和模型的自动转换`(MJExtension)`

<b>关联对象(Objective-C Associated Objects)给分类增加属性</b>

关联对象`Runtime`提供了下面几个接口：

```
// 关联对象
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
// 获取关联的对象
id objc_getAssociatedObject(id object, const void *key)
// 移除关联的对象
void objc_removeAssociatedObjects(id object)
```

参数解释:

`id object`：被关联的对象</br>
`const void *key`：关联的key，要求唯一</br>
`id value`：关联的对象</br>
`objc_AssociationPolicy policy`：内存管理的策略内存管理的策略</br>

```
typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3, 
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};
```

`OBJC_ASSOCIATION_ASSIGN`: 指定一个关联对象的弱引用。属性修饰`@property (assign)` 或 `@property (unsafe_unretained)`</br>
`OBJC_ASSOCIATION_RETAIN_NONATOMIC`: 指定一个关联对象的强引用，不能被原子化使用。属性修饰`@property (nonatomic, strong)`</br>
`OBJC_ASSOCIATION_COPY_NONATOMIC`: 指定一个关联对象的`copy`引用，不能被原子化使用。属性修饰`@property (nonatomic, copy)`</br>
`OBJC_ASSOCIATION_RETAIN`:  指定一个关联对象的强引用，能被原子化使用。属性修饰 `@property (atomic, strong)`</br>
`OBJC_ASSOCIATION_COPY`:  指定一个关联对象的`copy`引用，能被原子化使用。属性修饰`@property (atomic, copy)`</br>

下面实现一个`UIView`的`Category`添加自定义属性`defaultColor`

```
#import "ViewController.h"
#import "objc/runtime.h"

@interface UIView (DefaultColor)

@property (nonatomic, strong) UIColor *defaultColor;

@end

@implementation UIView (DefaultColor)

@dynamic defaultColor;

static char kDefaultColorKey;

- (void)setDefaultColor:(UIColor *)defaultColor {
    objc_setAssociatedObject(self, &kDefaultColorKey, defaultColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)defaultColor {
    return objc_getAssociatedObject(self, &kDefaultColorKey);
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *test = [UIView new];
    test.defaultColor = [UIColor blackColor];
    NSLog(@"%@", test.defaultColor);
}

@end
```

<b> 方法魔法(Method Swizzling)方法添加和替换和KVO实现</b>
<b>方法添加</b>
```
//class_addMethod(Class  _Nullable __unsafe_unretained cls, SEL  _Nonnull name, IMP  _Nonnull imp, const char * _Nullable types)
class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
```
>1、cls 被添加方法的类</br>
2、name 添加的方法的名称的SEL</br>
3、imp 方法的实现。该函数必须至少要有两个参数，self,_cmd</br>
4、types 类型编码

<b>方法替换</b>
```
@implementation ViewController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(test1);
        SEL swizzledSelector = @selector(test2);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)test1 {
    NSLog(@"1");
}

- (void)test2 {
    NSLog(@"2");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test1];
}
```
>在`viewDidLoad`中调用`test1`方法，查找到的对应的方法实现就是`test2`,而不是`test1`

`swizzling`应该只在`+load`中完成。 在 `Objective-C `的运行时中，每个类有两个方法都会自动调用。`+load `是在一个类被初始装载时调用，`+initialize` 是在应用第一次调用该类的类方法或实例方法前调用的。两个方法都是可选的，并且只有在方法被实现的情况下才会被调用。

`swizzlin`g应该只在`dispatch_once `中完成,由于`swizzling `改变了全局的状态，所以我们需要确保每个预防措施在运行时都是可用的。原子操作就是这样一个用于确保代码只会被执行一次的预防措施，就算是在不同的线程中也能确保代码只执行一次。Grand Central Dispatch 的 `dispatch_once`满足了所需要的需求，并且应该被当做使用`swizzling `的初始化单例方法的标准。

</details>

<details>
<summary>
<b></b>
</summary>
</details>

<details>
<summary>
<b></b>
</summary>
</details>

<details>
<summary>
<b></b>
</summary>
</details>

<details>
<summary>
<b></b>
</summary>
</details>

<details>
<summary>
<b></b>
</summary>
</details>

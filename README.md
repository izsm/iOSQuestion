
## 基础

<details>
<summary>
    <b>1、说明并比较关键词：strong, weak, assign, copy等等</b>
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
<b>2、atomatic和nonatomic区别和理解</b>
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
<b>3、请说明并比较以下关键词：__weak，__block</b>
</summary>

`__weak`与`weak`基本相同。前者用于修饰变量（variable），后者用于修饰属性（property）。`__weak` 主要用于防止`block`中的循环引用。
`__block`也用于修饰变量。它是引用修饰，所以其修饰的值是动态变化的，即可以被重新赋值的。`__block`用于修饰某些`block`内部将要修改的外部变量。
_`_weak`和`__block`的使用场景几乎与`block`息息相关。而所谓`block`，就是`Objective-C`对于闭包的实现。闭包就是没有名字的函数，或者理解为指向函数的指针。
</details>

<details>
<summary>
    <b>4、什么情况下会出现循环引用？</b>
</summary>
</details>

<details>
<summary>
    <b>5、什么是KVO和KVC?他们的使用场景是什么？</b>
</summary>
</details>

<details>
<summary>
    <b>6、Runtime应用</b>
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
    <b>7、循环引用</b>
</summary>

</br><b>循环引用的实质：多个对象相互之间有强引用，不能释放让系统回收。</b></br>
<b>如何解决循环引用？</b></br>
>1、避免产生循环引用，通常是将 `strong` 引用改为 `weak` 引用。
比如在修饰属性时用`weak`
在`block`内调用对象方法时，使用其弱引用，这里可以使用两个宏
```
#define WS(weakSelf)            __weak __typeof(&*self)weakSelf = self; // 弱引用
#define ST(strongSelf)          __strong __typeof(&*self)strongSelf = weakSelf; //使用这个要先声明weakSelf
```
还可以使用__block来修饰变量</br>
在MRC下，__block不会增加其引用计数，避免了循环引用</br>
在ARC下，__block修饰对象会被强引用，无法避免循环引用，需要手动解除。</br>

<b>循环引用场景：</b>
* 自循环引用
    - 强持有的属性同时持有该对象
* 相互循环引用
    ![Demo](images/相互引用.webp)
* 多循环引用
    ![Demo](images/循环引用.webp)

<b>1、代理(delegate)循环引用属于相互循环引用</b></br>
delegate 是iOS中开发中比较常遇到的循环引用，一般在声明delegate的时候都要使用弱引用 weak,或者assign,当然怎么选择使用assign还是weak，MRC的话只能用assign，在ARC的情况下最好使用weak，因为weak修饰的变量在释放后自动指向nil，防止野指针存在</br>

<b>2、NSTimer循环引用属于相互循环使用</b></br>
在控制器内，创建NSTimer作为其属性，由于定时器创建后也会强引用该控制器对象，那么该对象和定时器就相互循环引用了。</br>
如何解决呢？</br>
这里我们可以使用手动断开循环引用：</br>
如果是不重复定时器，在回调方法里将定时器invalidate并置为nil即可。</br>
如果是重复定时器，在合适的位置将其invalidate并置为nil即可</br>

<b>3、block循环引用</b></br>
一个简单的例子：</br>
```
@property (copy, nonatomic) dispatch_block_t myBlock;
@property (copy, nonatomic) NSString *blockString;

- (void)testBlock {
    self.myBlock = ^() {
        NSLog(@"%@",self.blockString);
    };
}
```
由于block会对block中的对象进行持有操作,就相当于持有了其中的对象，而如果此时block中的对象又持有了该block，则会造成循环引用。
解决方案就是使用__weak修饰self即可
```
__weak typeof(self) weakSelf = self;

self.myBlock = ^() {
    NSLog(@"%@",weakSelf.blockString);
};
```
并不是所有block都会造成循环引用。</br>
只有被强引用了的block才会产生循环引用</br>
而比如`dispatch_async(dispatch_get_main_queue(), ^{})`,`[UIView animateWithDuration:1 animations:^{}]`这些系统方法等
或者block并不是其属性而是临时变量,即栈block
```
[self testWithBlock:^{
    NSLog(@"%@",self);
}];

- (void)testWithBlock:(dispatch_block_t)block {
    block();
}
```
还有一种场景，在block执行开始时self对象还未被释放，而执行过程中，self被释放了，由于是用weak修饰的，那么weakSelf也被释放了，此时在block里访问weakSelf时，就可能会发生错误(向nil对象发消息并不会崩溃，但也没任何效果)。</br>
对于这种场景，应该在block中对 对象使用__strong修饰，使得在block期间对 对象持有，block执行结束后，解除其持有。
```
__weak typeof(self) weakSelf = self;

self.myBlock = ^() {
    __strong __typeof(self) strongSelf = weakSelf;
    [strongSelf test];
};
```
</details>

<details>
<summary>
    <b>8、Block原理、Block变量截获、Block的三种形式、__block</b>
</summary>

</br><b>一、什么是Block？</b></br>
* Block是将函数及其执行上下文封装起来的对象。
```
NSInteger num = 3;
NSInteger(^block)(NSInteger) = ^NSInteger(NSInteger n){
    return n * num;
};
block(2);
```
通过clang -rewrite-objc WYTest.m命令编译该.m文件，发现该block被编译成这个形式:
```
NSInteger num = 3;

NSInteger(*block)(NSInteger) = ((NSInteger (*)(NSInteger))&__WYTest__blockTest_block_impl_0((void *)__WYTest__blockTest_block_func_0, &__WYTest__blockTest_block_desc_0_DATA, num));

((NSInteger (*)(__block_impl *, NSInteger))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 2);
```
其中WYTest是文件名，blockTest是方法名，这些可以忽略。</br>
其中__WYTest__blockTest_block_impl_0结构体为
```
struct __WYTest__blockTest_block_impl_0 {
  struct __block_impl impl;
  struct __WYTest__blockTest_block_desc_0* Desc;
  NSInteger num;
  __WYTest__blockTest_block_impl_0(void *fp, struct __WYTest__blockTest_block_desc_0 *desc, NSInteger _num, int flags=0) : num(_num) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```
_block_impl结构体为
```
struct __block_impl {
  void *isa;//isa指针，所以说Block是对象
  int Flags;
  int Reserved;
  void *FuncPtr;//函数指针
};
```
block内部有isa指针，所以说其本质也是OC对象</br>
block内部则为:
```
static NSInteger __WYTest__blockTest_block_func_0(struct __WYTest__blockTest_block_impl_0 *__cself, NSInteger n) {
    NSInteger num = __cself->num; // bound by copy
    return n * num;
}
```
所以说 Block是将函数及其执行上下文封装起来的对象</br>
既然block内部封装了函数，那么它同样也有参数和返回值。</br></br>

<b>二、Block变量截获</b></br></br>
<b>1、局部变量截获 是值截获。 比如:</b>
```
NSInteger num = 3;
    
NSInteger(^block)(NSInteger) = ^NSInteger(NSInteger n){
    return n*num;
};

num = 1;

NSLog(@"%zd",block(2));
```
这里的输出是6而不是2，原因就是对局部变量num的截获是值截获。</br>
同样，在block里如果修改变量num，也是无效的，甚至编译器会报错。</br>
```
NSMutableArray * arr = [NSMutableArray arrayWithObjects:@"1",@"2", nil];
void(^block)(void) = ^{
    NSLog(@"%@",arr);//局部变量
    [arr addObject:@"4"];
};
[arr addObject:@"3"];
arr = nil;
block();
```
打印为1，2，3</br>
局部对象变量也是一样，截获的是值，而不是指针，在外部将其置为nil，对block没有影响，而该对象调用方法会影响</br>

<b>2、局部静态变量截获 是指针截获。</b>
```
tatic  NSInteger num = 3;
NSInteger(^block)(NSInteger) = ^NSInteger(NSInteger n){
    return n*num;
};
num = 1;
NSLog(@"%zd",block(2));
```
输出为2，意味着num = 1这里的修改num值是有效的，即是指针截获。</br>
同样，在block里去修改变量m，也是有效的。</br>

<b>3、全局变量，静态全局变量截获：不截获,直接取值。</b></br></br>
我们同样用clang编译看下结果。</br>
```
static NSInteger num3 = 300;
NSInteger num4 = 3000;

- (void)blockTest {
    NSInteger num = 30;
    static NSInteger num2 = 3;
    __block NSInteger num5 = 30000;
    void(^block)(void) = ^{
        NSLog(@"%zd",num);//局部变量
        NSLog(@"%zd",num2);//静态变量
        NSLog(@"%zd",num3);//全局变量
        NSLog(@"%zd",num4);//全局静态变量
        NSLog(@"%zd",num5);//__block修饰变量
    };
    block();
}
```
编译后
```
struct __WYTest__blockTest_block_impl_0 {
  struct __block_impl impl;
  struct __WYTest__blockTest_block_desc_0* Desc;
  NSInteger num;//局部变量
  NSInteger *num2;//静态变量
  __Block_byref_num5_0 *num5; // by ref//__block修饰变量
  __WYTest__blockTest_block_impl_0(void *fp, struct __WYTest__blockTest_block_desc_0 *desc, NSInteger _num, NSInteger *_num2, __Block_byref_num5_0 *_num5, int flags=0) : num(_num), num2(_num2), num5(_num5->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```
 impl.isa = &_NSConcreteStackBlock;这里注意到这一句，即说明该block是栈block）
可以看到局部变量被编译成值形式，而静态变量被编成指针形式，全局变量并未截获。而__block修饰的变量也是以指针形式截获的，并且生成了一个新的结构体对象：
```
struct __Block_byref_num5_0 {
  void *__isa;
  __Block_byref_num5_0 *__forwarding;
 int __flags;
 int __size;
 NSInteger num5;
};
```
该对象有个属性：num5，即我们用__block修饰的变量。</br>
这里__forwarding是指向自身的(栈block)。</br>
一般情况下，如果我们要对block截获的局部变量进行赋值操作需添加__block</br>
修饰符，而对全局变量，静态变量是不需要添加__block修饰符的。</br>
另外，block里访问self或成员变量都会去截获self。</br>

<b>三、Block的几种形式</b></br>
分为全局Block(_NSConcreteGlobalBlock)、栈Block(_NSConcreteStackBlock)、堆Block(_NSConcreteMallocBlock)三种形式</br>
其中栈Block存储在栈(stack)区，堆Block存储在堆(heap)区，全局Block存储在已初始化数据(.data)区</br>

<b>1、不使用外部变量的block是全局block</b></br></br>
比如：
```
NSLog(@"%@",[^{
    NSLog(@"globalBlock");
} class]);
```
输出：
```
_NSGlobalBlock__
```
<b>2、使用外部变量并且未进行copy操作的block是栈block</b></br></br>
比如:
```
NSInteger num = 10;
NSLog(@"%@",[^{
    NSLog(@"stackBlock:%zd",num);
} class]);
```
输出：
```
__NSStackBlock__
```
日常开发常用于这种情况:
```
[self testWithBlock:^{
    NSLog(@"%@",self);
}];

- (void)testWithBlock:(dispatch_block_t)block {
    block();
    NSLog(@"%@",[block class]);
}
```
<b>3、对栈block进行copy操作，就是堆block，而对全局block进行copy，仍是全局block</b></br>
* 比如堆1中的全局进行copy操作，即赋值：
```
void (^globalBlock)(void) = ^{
    NSLog(@"globalBlock");
};

NSLog(@"%@",[globalBlock class]);
```
输出：
```
_NSGlobalBlock__
```
仍是全局block

* 而对2中的栈block进行赋值操作：
```
NSInteger num = 10;

void (^mallocBlock)(void) = ^{
    NSLog(@"stackBlock:%zd",num);
};

NSLog(@"%@",[mallocBlock class]);
```
输出：
```
__NSMallocBlock__
```
对栈block copy之后，并不代表着栈block就消失了，左边的mallock是堆block，右边被copy的仍是栈block</br></br>
比如:
```
[self testWithBlock:^{
    NSLog(@"%@",self);
}];

- (void)testWithBlock:(dispatch_block_t)block {
    block();
    dispatch_block_t tempBlock = block;
    NSLog(@"%@,%@",[block class],[tempBlock class]);
}
```
输出：
```
__NSStackBlock__, __NSMallocBlock__
```
<b>即如果对栈Block进行copy，将会copy到堆区，对堆Block进行copy，将会增加引用计数，对全局Block进行copy，因为是已经初始化的，所以什么也不做。</b></br></br>
另外，__block变量在copy时，由于__forwarding的存在，栈上的__forwarding指针会指向堆上的__forwarding变量，而堆上的__forwarding指针指向其自身，所以，如果对__block的修改，实际上是在修改堆上的__block变量。</br></br>
<b>即__forwarding指针存在的意义就是，无论在任何内存位置， 都可以顺利地访问同一个__block变量。</b></br></br>
另外由于block捕获的__block修饰的变量会去持有变量，那么如果用__block修饰self，且self持有block，并且block内部使用到__block修饰的self时，就会造成多循环引用，即self持有block，block 持有__block变量，而__block变量持有self，造成内存泄漏。</br></br>
比如:
```
_block typeof(self) weakSelf = self;
    
_testBlock = ^{
    NSLog(@"%@",weakSelf);
};

_testBlock();
```
如果要解决这种循环引用，可以主动断开__block变量对self的持有，即在block内部使用完weakself后，将其置为nil，但这种方式有个问题，如果block一直不被调用，那么循环引用将一直存在。
所以，我们最好还是用__weak来修饰self
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

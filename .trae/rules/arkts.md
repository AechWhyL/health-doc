---
alwaysApply: false
---
本文档罗列了ArkTS不支持或部分支持的TypeScript特性，是编写ArkTS代码需要重点注意的事项。完整的列表以及详细的代码示例和重构建议，请参考约束说明。

## 约束说明

### 对象的属性名必须是合法的标识符

#### 规则：arkts-identifiers-as-prop-names

#### 级别：错误

#### 错误码：10605001

在ArkTS中，对象的属性名不能为数字或字符串。例外：ArkTS支持属性名为字符串字面量和枚举中的字符串值。通过属性名访问类的属性，通过数值索引访问数组元素。

TypeScript

```typescript
var x = { 'name': 'x', 2: '3' };

console.info(x['name']); // x
console.info(x[2]); // 3
```

ArkTS

```typescript
class X {
  public name: string = ''
}
let x: X = { name: 'x' };
console.info(x.name); // x

let y = ['a', 'b', 'c'];
console.info(y[2]); // c

// 在需要通过非标识符（即不同类型的key）获取数据的场景中，使用Map<Object, some_type>。
let z = new Map<Object, string>();
z.set('name', '1');
z.set(2, '2');
console.info(z.get('name'));  // 1
console.info(z.get(2)); // 2

enum Test {
  A = 'aaa',
  B = 'bbb'
}

let obj: Record<string, number> = {
  [Test.A]: 1,   // 枚举中的字符串值
  [Test.B]: 2,   // 枚举中的字符串值
  ['value']: 3   // 字符串字面量
}
```
### 不支持Symbol()API

#### 规则：arkts-no-symbol

#### 级别：错误

#### 错误码：10605002

在ArkTS中，对象布局在编译时确定，不可在运行时更改，因此不支持Symbol() API。该API在静态类型语言中通常没有实际意义。

ArkTS只支持Symbol.iterator。

### 不支持以#开头的私有字段

#### 规则：arkts-no-private-identifiers

#### 级别：错误

#### 错误码：10605003

ArkTS不支持使用#符号开头声明的私有字段。改用private关键字。

TypeScript

```typescript
class C {
  #foo: number = 42
}
```

ArkTS

```typescript
class C {
  private foo: number = 42
}
```
### 类型、命名空间的命名必须唯一

#### 规则：arkts-unique-names

#### 级别：错误

#### 错误码：10605004

类型（类、接口、枚举）和命名空间的名称必须唯一，并且不能与其他名称（如变量名、函数名）重复。

TypeScript

```typescript
let X: string
type X = number[] // 类型的别名与变量同名
```

ArkTS

```typescript
let X: string
type T = number[] // 为避免名称冲突，此处不允许使用X
```
### 使用let而非var

#### 规则：arkts-no-var

#### 级别：错误

#### 错误码：10605005

let关键字可以在块级作用域中声明变量，帮助程序员避免错误。因此，ArkTS不支持var，请使用let声明变量。

TypeScript

```typescript
function f(shouldInitialize: boolean) {
  if (shouldInitialize) {
     var x = 'b';
  }
  return x;
}

console.info(f(true));  // b
console.info(f(false)); // undefined

let upperLet = 0;
{
  var scopedVar = 0;
  let scopedLet = 0;
  upperLet = 5;
}
scopedVar = 5; // 可见
scopedLet = 5; // 编译时错误
```

ArkTS

```typescript
function f(shouldInitialize: boolean): string {
  let x: string = 'a';
  if (shouldInitialize) {
    x = 'b';
  }
  return x;
}

console.info(f(true));  // b
console.info(f(false)); // a

let upperLet = 0;
let scopedVar = 0;
{
  let scopedLet = 0;
  upperLet = 5;
}
scopedVar = 5;
scopedLet = 5; //编译时错误
```
### 使用具体的类型而非any或unknown

#### 规则：arkts-no-any-unknown

#### 级别：错误

#### 错误码：10605008

ArkTS不支持any和unknown类型。显式指定具体类型。

TypeScript

```typescript
let value1: any
value1 = true;
value1 = 42;

let value2: unknown
value2 = true;
value2 = 42;
```

ArkTS

```typescript
let value_b: boolean = true; // 或者 let value_b = true
let value_n: number = 42; // 或者 let value_n = 42
let value_o1: Object = true;
let value_o2: Object = 42;
```
### 使用class而非具有call signature的类型

#### 规则：arkts-no-call-signatures

#### 级别：错误

#### 错误码：10605014

ArkTS不支持对象类型中包含call signature。

TypeScript

```typescript
type DescribableFunction = {
  description: string
  (someArg: string): string // call signature
}

function doSomething(fn: DescribableFunction): void {
  console.info(fn.description + ' returned ' + fn(''));
}
```

ArkTS

```typescript
class DescribableFunction {
  description: string
  public invoke(someArg: string): string {
    return someArg;
  }
  constructor() {
    this.description = 'desc';
  }
}

function doSomething(fn: DescribableFunction): void {
  console.info(fn.description + ' returned ' + fn.invoke(''));
}

doSomething(new DescribableFunction());
```
### 使用class而非具有构造签名的类型

#### 规则：arkts-no-ctor-signatures-type

#### 级别：错误

#### 错误码：10605015

ArkTS不支持对象类型中的构造签名。改用类。

TypeScript

```typescript
class SomeObject {}

type SomeConstructor = {
  new (s: string): SomeObject
}

function fn(ctor: SomeConstructor) {
  return new ctor('hello');
}
```

ArkTS

```typescript
class SomeObject {
  public f: string
  constructor (s: string) {
    this.f = s;
  }
}

function fn(s: string): SomeObject {
  return new SomeObject(s);
}
```
### 仅支持一个静态块

#### 规则：arkts-no-multiple-static-blocks

#### 级别：错误

#### 错误码：10605016

ArkTS不允许类中存在多个静态块。如果存在多个静态块语句，请将其合并到一个静态块中。

TypeScript

```typescript
class C {
  static s: string

  static {
    C.s = 'aa'
  }
  static {
    C.s = C.s + 'bb'
  }
}
```

ArkTS

```typescript
class C {
  static s: string

  static {
    C.s = 'aa'
    C.s = C.s + 'bb'
  }
}
```
### 不支持index signature

#### 规则：arkts-no-indexed-signatures

#### 级别：错误

#### 错误码：10605017

ArkTS不允许index signature，改用数组。

TypeScript

```typescript
// 带index signature的接口：
interface StringArray {
  [index: number]: string
}

function getStringArray(): StringArray {
  return ['a', 'b', 'c'];
}

const myArray: StringArray = getStringArray();
const secondItem = myArray[1];
```

ArkTS

```typescript
class X {
  public f: string[] = []
}

let myArray: X = new X();
const secondItem = myArray.f[1];
```
### 使用继承而非intersection type

#### 规则：arkts-no-intersection-types

#### 级别：错误

#### 错误码：10605019

目前ArkTS不支持intersection type，可以使用继承作为替代方案。

TypeScript

```typescript
interface Identity {
  id: number
  name: string
}

interface Contact {
  email: string
  phoneNumber: string
}

type Employee = Identity & Contact
```

ArkTS

```typescript
interface Identity {
  id: number
  name: string
}

interface Contact {
  email: string
  phoneNumber: string
}

interface Employee extends Identity,  Contact {}
```
### 不支持this类型

#### 规则：arkts-no-typing-with-this

#### 级别：错误

#### 错误码：10605021

ArkTS不支持this类型，改用显式具体类型。

TypeScript

```typescript
interface ListItem {
  getHead(): this
}

class C {
  n: number = 0

  m(c: this) {
    // ...
  }
}
```

ArkTS

```typescript
interface testListItem {
  getHead(): testListItem
}

class C {
  n: number = 0

  m(c: C) {
    // ...
  }
}
```
### 不支持条件类型

#### 规则：arkts-no-conditional-types

#### 级别：错误

#### 错误码：10605022

ArkTS不支持条件类型别名，建议引入带显式约束的新类型，或使用Object进行逻辑重构。

不支持infer关键字。

TypeScript

```typescript
type X<T> = T extends number ? T: never
type Y<T> = T extends Array<infer Item> ? Item: never
```

ArkTS

```typescript
// 在类型别名中提供显式约束
type X1<T extends number> = T

// 用Object重写，类型控制较少，需要更多的类型检查以确保安全
type X2<T> = Object

// Item必须作为泛型参数使用，并能正确实例化
type YI<Item, T extends Array<Item>> = Item
```
### 不支持在constructor中声明字段

#### 规则：arkts-no-ctor-prop-decls

#### 级别：错误

#### 错误码：10605025

ArkTS禁止在构造函数中声明类字段，所有字段都必须在class作用域内显式声明。

TypeScript

```typescript
class Person {
  constructor(
    protected ssn: string,
    private firstName: string,
    private lastName: string
  ) {
    this.ssn = ssn;
    this.firstName = firstName;
    this.lastName = lastName;
  }

  getFullName(): string {
    return this.firstName + ' ' + this.lastName;
  }
}
```

ArkTS

```typescript
class Person {
  protected ssn: string
  private firstName: string
  private lastName: string

  constructor(ssn: string, firstName: string, lastName: string) {
    this.ssn = ssn;
    this.firstName = firstName;
    this.lastName = lastName;
  }

  getFullName(): string {
    return this.firstName + ' ' + this.lastName;
  }
}
```
### 接口中不支持构造签名

#### 规则：arkts-no-ctor-signatures-iface

#### 级别：错误

#### 错误码：10605027

ArkTS语法禁止在接口（interface）中定义构造签名。作为替代方案，建议使用普通函数或方法来实现相同功能。

TypeScript

```typescript
interface I {
  new (s: string): I
}

function fn(i: I) {
  return new i('hello');
}
```

ArkTS

```typescript
interface I {
  create(s: string): I
}

function fn(i: I) {
  return i.create('hello');
}
```
### 不支持索引访问类型

#### 规则：arkts-no-aliases-by-index

#### 级别：错误

#### 错误码：10605028

ArkTS不支持索引访问类型。

### 不支持通过索引访问字段

#### 规则：arkts-no-props-by-index

#### 级别：错误

#### 错误码：10605029

ArkTS不支持动态声明字段，不支持动态访问字段。只能访问已在类中声明或者继承可见的字段，访问其他字段将会造成编译时错误。

使用点操作符访问字段，例如（obj.field），不支持索引访问（obj['field']）。

ArkTS支持通过索引访问TypedArray（例如Int32Array）中的元素。

TypeScript

```typescript
class Point {
  x: string = ''
  y: string = ''
}
let p: Point = {x: '1', y: '2'};
console.info(p['x']); // 1

class Person {
  name: string = ''
  age: number = 0;
  [key: string]: string | number
}

let person: Person = {
  name: 'John',
  age: 30,
  email: '***@example.com',
  phoneNumber: '18*********',
}
```

ArkTS

```typescript
class Point {
  x: string = ''
  y: string = ''
}
let p: Point = {x: '1', y: '2'};
console.info(p.x); // 1

class Person {
  name: string
  age: number
  email: string
  phoneNumber: string

  constructor(name: string, age: number, email: string,
        phoneNumber: string) {
    this.name = name;
    this.age = age;
    this.email = email;
    this.phoneNumber = phoneNumber;
  }
}

let person = new Person('John', 30, '***@example.com', '18*********');
console.info(person['name']);     // 编译时错误
console.info(person.unknownProperty); // 编译时错误

let arr = new Int32Array(1);
arr[0];
```
### 不支持structural typing

#### 规则：arkts-no-structural-typing

#### 级别：错误

#### 错误码：10605030

ArkTS不支持structural typing，编译器无法比较两种类型的publicAPI并决定它们是否相同。使用其他机制，例如继承、接口或类型别名。

TypeScript

```typescript
interface I1 {
  f(): string
}

interface I2 { // I2等价于I1
  f(): string
}

class X {
  n: number = 0
  s: string = ''
}

class Y { // Y等价于X
  n: number = 0
  s: string = ''
}

let x = new X();
let y = new Y();

// 将X对象赋值给Y对象
y = x;

// 将Y对象赋值给X对象
x = y;

function foo(x: X) {
  console.info(x.n + x.s);
}

// 由于X和Y的API是等价的，所以X和Y是等价的
foo(new X());
foo(new Y());
```

ArkTS

```typescript
interface I1 {
  f(): string
}

type I2 = I1 // I2是I1的别名

class B {
  n: number = 0
  s: string = ''
}

// D是B的继承类，构建了子类型和父类型的关系
class D extends B {
  constructor() {
    super()
  }
}

let b = new B();
let d = new D();

console.info('Assign D to B');
b = d; // 合法赋值，因为B是D的父类

// 将b赋值给d将会引起编译时错误
// d = b

interface Z {
   n: number
   s: string
}

// 类X implements 接口Z，构建了X和Y的关系
class X implements Z {
  n: number = 0
  s: string = ''
}

// 类Y implements 接口Z，构建了X和Y的关系
class Y implements Z {
  n: number = 0
  s: string = ''
}

let x: Z = new X();
let y: Z = new Y();

console.info('Assign X to Y');
y = x // 合法赋值，它们是相同的类型

console.info('Assign Y to X');
x = y // 合法赋值，它们是相同的类型

function foo(c: Z): void {
  console.info(c.n + c.s);
}

// 类X和类Y implement 相同的接口，因此下面的两个函数调用都是合法的
foo(new X());
foo(new Y());
```
### 需要显式标注泛型函数类型实参

#### 规则：arkts-no-inferred-generic-params

#### 级别：错误

#### 错误码：10605034

如果可以从传递给泛型函数的参数中推断出具体类型，ArkTS允许省略泛型类型实参。否则，省略泛型类型实参会发生编译时错误。

禁止仅基于泛型函数返回类型推断泛型类型参数。

TypeScript

```typescript
function choose<T>(x: T, y: T): T {
  return Math.random() < 0.5 ? x: y;
}

let x = choose(10, 20);   // 推断choose<number>(...)
let y = choose('10', 20); // 编译时错误

function greet<T>(): T {
  return 'Hello' as T;
}
let z = greet() // T的类型被推断为"unknown"
```

ArkTS

```typescript
function choose<T>(x: T, y: T): T {
  return Math.random() < 0.5 ? x: y;
}

let x = choose(10, 20);   // 推断choose<number>(...)
let y = choose('10', 20); // 编译时错误

function greet<T>(): T {
  return 'Hello' as T;
}
let z = greet<string>();
```
### 需要显式标注对象字面量的类型
#### 规则：arkts-no-untyped-obj-literals

#### 级别：错误

#### 错误码：10605038

在 ArkTS 中，需要显式标注对象字面量的类型，否则将导致编译时错误。在某些场景下，编译器可以根据上下文推断出字面量的类型。

在以下上下文中不支持使用字面量初始化类和接口：

初始化具有any、Object或object类型的任何对象
初始化带有方法的类或接口
初始化包含自定义含参数的构造函数的类
初始化带readonly字段的类

#### 例子1

TypeScript

```typescript
let o1 = {n: 42, s: 'foo'};
let o2: Object = {n: 42, s: 'foo'};
let o3: object = {n: 42, s: 'foo'};

let oo: Object[] = [{n: 1, s: '1'}, {n: 2, s: '2'}];
```

ArkTS

```typescript
class C1 {
  n: number = 0
  s: string = ''
}

let o1: C1 = {n: 42, s: 'foo'};
let o2: C1 = {n: 42, s: 'foo'};
let o3: C1 = {n: 42, s: 'foo'};

let oo: C1[] = [{n: 1, s: '1'}, {n: 2, s: '2'}];
```

#### 例子2

TypeScript

```typescript
class C2 {
  s: string
  constructor(s: string) {
    this.s = 's =' + s;
  }
}
let o4: C2 = {s: 'foo'};
```

ArkTS

```typescript
class C2 {
  s: string
  constructor(s: string) {
    this.s = 's =' + s;
  }
}
let o4 = new C2('foo');
```
## 不支持映射类型
规则：arkts-no-mapped-types

级别：错误

错误码：10605083

ArkTS不支持映射类型，使用其他语法表示相同语义。

## 不支持with语句
规则：arkts-no-with

级别：错误

错误码：10605084

ArkTS不支持with语句，使用其他语法来表示相同的语义。


## 限制throw语句中表达式的类型
规则：arkts-limited-throw

级别：错误

错误码：10605087

ArkTS只支持抛出Error类或其派生类的实例。禁止抛出其他类型的数据，例如number或string。

TypeScript

throw 4;
throw '';
throw new Error();
ArkTS

throw new Error();
## 限制省略函数返回类型标注
规则：arkts-no-implicit-return-types
级别：错误
错误码：10605090
ArkTS在部分场景中支持对函数返回类型进行推断。当return语句中的表达式是对某个函数或方法进行调用，且该函数或方法的返回类型没有被显著标注时，会出现编译时错误。在这种情况下，请标注函数返回类型。
## 不支持参数解构的函数声明
规则：arkts-no-destruct-params
级别：错误
错误码：10605091
ArkTS要求实参必须直接传递给函数，且必须指定到形参。
## 不支持在函数内声明函数
规则：arkts-no-nested-funcs
级别：错误
错误码：10605092
ArkTS不支持在函数内声明函数，改用lambda函数。
## 不支持在函数和类的静态方法中使用this
规则：arkts-no-standalone-this
级别：错误
错误码：10605093
ArkTS中this只能在类的实例方法中使用，不支持在函数和类的静态方法中使用。
## 不支持生成器函数
规则：arkts-no-generators
级别：错误
错误码：10605094
目前ArkTS不支持生成器函数，可使用async或await机制处理并行任务。
## 使用instanceof和as进行类型保护
规则：arkts-no-is
级别：错误
错误码：10605096
在ArkTS中，不支持is运算符，必须使用instanceof运算符来替代。在使用instanceof之前，必须先使用as运算符将对象转换为所需类型。
## 部分支持展开运算符
规则：arkts-no-spread
级别：错误
错误码：10605099
ArkTS仅支持使用展开运算符展开数组、Array的子类和TypedArray（例如Int32Array）。仅支持使用在以下场景中：
传递给剩余参数时；
复制一个数组到数组字面量。
## 接口不能继承具有相同方法的两个接口
规则：arkts-no-extend-same-prop
级别：错误
错误码：106050102
在TypeScript中，如果一个接口继承了两个具有相同方法的接口，则必须使用联合类型声明该方法的返回值类型。在ArkTS中，由于接口不能包含两个无法区分的方法（如参数列表相同但返回类型不同），因此不能继承具有相同方法的两个接口。
## 不支持声明合并
规则：arkts-no-decl-merging
级别：错误
错误码：10605103
ArkTS不支持类和接口的声明合并。
## 接口不能继承类
规则：arkts-extends-only-class
级别：错误
错误码：10605104
在ArkTS中，接口不能继承类，只能继承其他接口。
## 不支持构造函数类型
规则：arkts-no-ctor-signatures-funcs
级别：错误
错误码：10605106
ArkTS不支持构造函数类型，改用lambda函数。
## 只能使用类型相同的编译时表达式初始化枚举成员
规则：arkts-no-enum-mixed-types
级别：错误
错误码：10605111
ArkTS不支持使用运行期间计算的表达式初始化枚举成员。枚举中所有显式初始化的成员必须具有相同类型。
## 命名空间不能被用作对象
规则：arkts-no-ns-as-obj
级别：错误
错误码：10605114
ArkTS不支持将命名空间用作对象，可以使用类或模块。
## 不支持命名空间中的非声明语句
规则：arkts-no-ns-statements
级别：错误
错误码：10605116
在ArkTS中，命名空间用于定义标识符的可见范围，仅在编译时有效。因此，命名空间中不支持非声明语句。可以将非声明语句写在函数中。
## 不支持require和import赋值表达式
规则：arkts-no-require
级别：错误
错误码：10605121
ArkTS不支持通过require导入和import赋值表达式，改用import。
## 不支持export = ...语法
规则：arkts-no-export-assignment
级别：错误
错误码：10605126
ArkTS不支持export = ...语法，改用常规的export或import。
## 不支持ambient module声明
规则：arkts-no-ambient-decls
级别：错误
错误码：10605128
由于ArkTS本身有与JavaScript交互的机制，ArkTS不支持ambient module声明。
## 不支持在模块名中使用通配符
规则：arkts-no-module-wildcards
级别：错误
错误码：10605129
在ArkTS中，导入是编译时而非运行时行为，不支持在模块名中使用通配符。
## 不支持通用模块定义(UMD)
规则：arkts-no-umd
级别：错误
错误码：10605130
ArkTS不支持通用模块定义（UMD）。因为在ArkTS中没有“脚本”的概念（相对于“模块”）。此外，在ArkTS中，导入是编译时而非运行时特性。改用export和import语法。
## 不支持new.target
规则：arkts-no-new-target
级别：错误
错误码：10605132
ArkTS没有原型的概念，因此不支持new.target。此特性不符合静态类型的原则。
## 不支持确定赋值断言
规则：arkts-no-definite-assignment
级别：警告
错误码：10605134
ArkTS不支持确定赋值断言，例如：let v!: T。改为在声明变量的同时为变量赋值。
## 不支持在原型上赋值
规则：arkts-no-prototype-assignment
级别：错误
错误码：10605136
ArkTS没有原型的概念，因此不支持在原型上赋值。此特性不符合静态类型的原则。
## 不支持globalThis
规则：arkts-no-globalthis
级别：警告
错误码：10605137
由于ArkTS不支持动态更改对象的布局，因此不支持全局作用域和globalThis。
## 不支持一些utility类型
规则：arkts-no-utility-types
级别：错误
错误码：10605138
ArkTS仅支持Partial、Required、Readonly和Record，不支持TypeScript中其他的Utility Types。
对于Partial<T>类型，泛型参数T必须为类或者接口类型。
对于Record类型的对象，通过索引访问到的值的类型是包含undefined的联合类型。
## 不支持对函数声明属性
规则：arkts-no-func-props
级别：错误
错误码：10605139
由于ArkTS不支持动态改变函数对象布局，因此，不支持对函数声明属性。
## 不支持Function.apply和Function.call
规则：arkts-no-func-apply-call
级别：错误
错误码：10605152
ArkTS不允许使用标准库函数Function.apply和Function.call，因为这些函数用于显式设置被调用函数的this参数。在ArkTS中，this的语义仅限于传统的OOP风格，函数体中禁止使用this。
## 不支持Function.bind
规则：arkts-no-func-bind
级别：警告
错误码：10605140
ArkTS禁用标准库函数Function.bind。标准库使用这些函数显式设置被调用函数的this参数。在ArkTS中，this仅限于传统OOP风格，函数体中禁用使用this。
## 不支持as const断言
规则：arkts-no-as-const
级别：错误
错误码：10605142
ArkTS不支持as const断言和字面量类型。在标准TypeScript中，as const用于标注字面量类型。
## 不支持导入断言
规则：arkts-no-import-assertions
级别：错误
错误码：10605143
ArkTS不支持导入断言。因为导入是编译时特性，运行时检查导入API是否正确没有意义。改用常规的import语法。
## 限制使用标准库
规则：arkts-limited-stdlib
级别：错误
错误码：10605144
ArkTS不允许使用TypeScript或JavaScript标准库中的某些接口。大部分接口与动态特性有关。ArkTS中禁止使用以下接口：
全局对象的属性和方法：eval
Object：__proto__、__defineGetter__、__defineSetter__、
__lookupGetter__、__lookupSetter__、assign、create、
defineProperties、defineProperty、freeze、
fromEntries、getOwnPropertyDescriptor、getOwnPropertyDescriptors、
getOwnPropertySymbols、getPrototypeOf、
hasOwnProperty、is、isExtensible、isFrozen、
isPrototypeOf、isSealed、preventExtensions、
propertyIsEnumerable、seal、setPrototypeOf
Reflect：apply、construct、defineProperty、deleteProperty、
getOwnPropertyDescriptor、getPrototypeOf、
isExtensible、preventExtensions、
setPrototypeOf
Proxy：handler.apply()、handler.construct()、
handler.defineProperty()、handler.deleteProperty()、handler.get()、
handler.getOwnPropertyDescriptor()、handler.getPrototypeOf()、
handler.has()、handler.isExtensible()、handler.ownKeys()、
handler.preventExtensions()、handler.set()、handler.setPrototypeOf()
## 强制进行严格类型检查
级别：错误
错误码：10605999
在编译阶段，会进行TypeScript严格模式的类型检查，包括：
noImplicitReturns,
strictFunctionTypes,
strictNullChecks,
strictPropertyInitialization。
在定义类时，如果无法在声明时或者构造函数中初始化某实例属性，那么可以使用确定赋值断言符!来消除strictPropertyInitialization的报错。
使用确定赋值断言符会增加代码错误的风险。开发者必须确保实例属性在使用前已赋值，以避免运行时异常。
使用确定赋值断言符会增加运行时开销，应尽量避免使用。
使用确定赋值断言符将产生warning: arkts-no-definite-assignment。
## 不允许通过注释关闭类型检查
规则：arkts-strict-typing-required
级别：错误
错误码：10605146
在ArkTS中，类型检查不是可选项。不允许通过注释关闭类型检查，不支持使用@ts-ignore和@ts-nocheck。
## 允许.ets文件import.ets/.ts/.js文件源码, 不允许.ts/.js文件import.ets文件源码
规则：arkts-no-ts-deps
级别：错误
错误码：10605147
.ets文件可以import.ets/.ts/.js文件源码，但是.ts/.js文件不允许import.ets文件源码。
class不能被用作对象
## 规则：arkts-no-classes-as-obj
级别：警告
错误码：10605149
在ArkTS中，class声明的是一个新类型，不是值。因此，不支持将class用作对象，例如将其赋值给一个对象。
## 不支持在import语句前使用其他语句
规则：arkts-no-misplaced-imports
级别：错误
错误码：10605150
在ArkTS中，除动态 import 语句外，所有 import 语句都应置于其他语句之前。

## 限制ArkUI UI语法范围
规则：arkui-ui-syntax-only
级别：错误
错误码：10905209
在ArkUI组件容器（例如Column、Row、Stack、Tabs等）的子代码块中，仅允许编写UI组件语法和支持的控制语句。常见的合法语法包括：
- 组件调用：Column() { ... }、Row() { ... }、Text() 等；
- 条件分支：if / else if / else；
- 循环渲染：ForEach等ArkUI提供的UI循环语法；
- 组件链式调用（.fontSize()、.margin()等属性设置）。

在这些UI容器内部，禁止编写普通的TypeScript语句，例如：
- 变量声明：const / let / var；
- 普通表达式求值但不渲染UI；
- 函数声明或其他与UI渲染无关的逻辑代码。

如果在UI容器内部编写了上述普通语句，会触发如下编译错误：

Only UI component syntax can be written here.

推荐做法：
- 将与UI相关的计算逻辑（如性别中文文案、年龄字符串拼接等）放在UI容器外部，先计算好结果再作为属性或Text内容传入；
- 或者在组件成员方法中预先处理好数据，在build方法或@Builder方法中只做纯渲染。

## 限制ArkUI组件实现位置
规则：arkui-builder-location
级别：错误
错误码：ArkTSCheck
ArkUI组件描述语法（如Column()、Row()、Text()等）只能出现在以下位置：
- 组件的build方法内部；
- 组件的pageTransition方法内部（自定义组件时）；
- 使用@Builder装饰的构建方法内部。

在普通的类方法或工具函数中直接编写ArkUI组件实现，会触发如下检查错误：

Implementation not allowed here. Use the component in an @Builder decorated method or in the build or pageTransition method (for custom components only). <ArkTSCheck>

推荐做法：
- 如果只是抽取一段UI片段，使用@Builder修饰的成员方法，并在build中以this.xxx()调用；
- 如果不希望使用@Builder，则将ArkUI组件实现代码直接内联到build方法或pageTransition方法内部，通过if/else等语句控制渲染分支。

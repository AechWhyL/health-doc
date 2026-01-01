## 对象的属性名必须是合法的标识符
规则：arkts-identifiers-as-prop-names
级别：错误
错误码：10605001
在ArkTS中，对象的属性名不能为数字或字符串。例外：ArkTS支持属性名为字符串字面量和枚举中的字符串值。通过属性名访问类的属性，通过数值索引访问数组元素。
## 不支持Symbol()API
规则：arkts-no-symbol
级别：错误
错误码：10605002
在ArkTS中，对象布局在编译时确定，不可在运行时更改，因此不支持Symbol() API。该API在静态类型语言中通常没有实际意义。
ArkTS只支持Symbol.iterator。
## 不支持以#开头的私有字段
规则：arkts-no-private-identifiers
级别：错误
错误码：10605003
ArkTS不支持使用#符号开头声明的私有字段。改用private关键字。
## 类型、命名空间的命名必须唯一
规则：arkts-unique-names
级别：错误
错误码：10605004
类型（类、接口、枚举）和命名空间的名称必须唯一，并且不能与其他名称（如变量名、函数名）重复。
## 使用let而非var
规则：arkts-no-var
级别：错误
错误码：10605005
let关键字可以在块级作用域中声明变量，帮助程序员避免错误。因此，ArkTS不支持var，请使用let声明变量。
## 使用具体的类型而非any或unknown
规则：arkts-no-any-unknown
级别：错误
错误码：10605008
ArkTS不支持any和unknown类型。显式指定具体类型。
## 使用class而非具有call signature的类型
规则：arkts-no-call-signatures
级别：错误
错误码：10605014
ArkTS不支持对象类型中包含call signature。
## 使用class而非具有构造签名的类型
规则：arkts-no-ctor-signatures-type
级别：错误
错误码：10605015
ArkTS不支持对象类型中的构造签名。改用类。
## 仅支持一个静态块
规则：arkts-no-multiple-static-blocks
级别：错误
错误码：10605016
ArkTS不允许类中存在多个静态块。如果存在多个静态块语句，请将其合并到一个静态块中。
## 不支持index signature
规则：arkts-no-indexed-signatures
级别：错误
错误码：10605017
ArkTS不允许index signature，改用数组。
## 使用继承而非intersection type
规则：arkts-no-intersection-types
级别：错误
错误码：10605019
目前ArkTS不支持intersection type，可以使用继承作为替代方案。
## 不支持this类型
规则：arkts-no-typing-with-this
级别：错误
错误码：10605021
ArkTS不支持this类型，改用显式具体类型。
## 不支持条件类型
规则：arkts-no-conditional-types
级别：错误
错误码：10605022
ArkTS不支持条件类型别名，建议引入带显式约束的新类型，或使用Object进行逻辑重构。
不支持infer关键字。
## 不支持在constructor中声明字段
规则：arkts-no-ctor-prop-decls
级别：错误
错误码：10605025
ArkTS禁止在构造函数中声明类字段，所有字段都必须在class作用域内显式声明。
## 接口中不支持构造签名
规则：arkts-no-ctor-signatures-iface
级别：错误
错误码：10605027
ArkTS语法禁止在接口（interface）中定义构造签名。作为替代方案，建议使用普通函数或方法来实现相同功能。
## 不支持索引访问类型
规则：arkts-no-aliases-by-index
级别：错误
错误码：10605028
ArkTS不支持索引访问类型。
## 不支持通过索引访问字段
规则：arkts-no-props-by-index
级别：错误
错误码：10605029
ArkTS不支持动态声明字段，不支持动态访问字段。只能访问已在类中声明或者继承可见的字段，访问其他字段将会造成编译时错误。
使用点操作符访问字段，例如（obj.field），不支持索引访问（obj['field']）。
ArkTS支持通过索引访问TypedArray（例如Int32Array）中的元素。
## 不支持structural typing
规则：arkts-no-structural-typing
级别：错误
错误码：10605030
ArkTS不支持structural typing，编译器无法比较两种类型的publicAPI并决定它们是否相同。使用其他机制，例如继承、接口或类型别名。
## 需要显式标注泛型函数类型实参
规则：arkts-no-inferred-generic-params
级别：错误
错误码：10605034
如果可以从传递给泛型函数的参数中推断出具体类型，ArkTS允许省略泛型类型实参。否则，省略泛型类型实参会发生编译时错误。
禁止仅基于泛型函数返回类型推断泛型类型参数。
## 需要显式标注对象字面量的类型
规则：arkts-no-untyped-obj-literals
级别：错误
错误码：10605038
在 ArkTS 中，需要显式标注对象字面量的类型，否则将导致编译时错误。在某些场景下，编译器可以根据上下文推断出字面量的类型。
在以下上下文中不支持使用字面量初始化类和接口：
初始化具有any、Object或object类型的任何对象
初始化带有方法的类或接口
初始化包含自定义含参数的构造函数的类
初始化带readonly字段的类
## 对象字面量不能用于类型声明
规则：arkts-no-obj-literals-as-types
级别：错误
错误码：10605040
ArkTS不支持使用对象字面量声明类型，建议使用类或接口声明类型。
## 数组字面量必须仅包含可推断类型的元素
规则：arkts-no-noninferrable-arr-literals
级别：错误
错误码：10605043
ArkTS将数组字面量的类型推断为所有元素的联合类型。如果其中任何一个元素的类型无法推导，则在编译时会发生错误。
## 使用箭头函数而非函数表达式
规则：arkts-no-func-expressions
级别：错误
错误码：10605046
ArkTS不支持函数表达式，使用箭头函数（=>）。
## 不支持使用类表达式
规则：arkts-no-class-literals
级别：错误
错误码：10605050
ArkTS不支持类表达式，必须显式声明一个类。
## 类不允许implements
规则：arkts-implements-only-iface
级别：错误
错误码：10605051
ArkTS中只有接口可以被implements，类不允许被implements。
## 不支持修改对象的方法
规则：arkts-no-method-reassignment
级别：错误
错误码：10605052
ArkTS不支持修改对象的方法。在静态语言中，对象布局固定，类的所有实例共享同一个方法。
若需为特定对象添加方法，可封装函数或采用继承机制。
## 类型转换仅支持as T语法
规则：arkts-as-casts
级别：错误
错误码：10605053
在ArkTS中，as关键字是类型转换的唯一语法，错误的类型转换会导致编译时错误或者运行时抛出ClassCastException异常。ArkTS不支持使用<type>语法进行类型转换。
需要将primitive类型（如number或boolean）转换为引用类型时，请使用new表达式。
## 不支持JSX表达式
规则：arkts-no-jsx
级别：错误
错误码：10605054
不支持使用JSX。
## 一元运算符+、-和~仅适用于数值类型
规则：arkts-no-polymorphic-unops
级别：错误
错误码：10605055
ArkTS对一元运算符实施严格的类型检查，仅允许操作数值类型。与TypeScript不同，ArkTS禁止隐式的字符串转换到数值，开发者必须使用显式类型的转换方法。
## 不支持delete运算符
规则：arkts-no-delete
级别：错误
错误码：10605059
在ArkTS中，对象布局于编译时确定，运行时不可更改，因此删除属性的操作无意义。
## 仅允许在表达式中使用typeof运算符
规则：arkts-no-type-query
级别：错误
错误码：10605060
ArkTS仅支持在表达式中使用typeof运算符，不允许使用typeof作为类型。
## 部分支持instanceof运算符
规则：arkts-instanceof-ref-types
级别：错误
错误码：10605065
TypeScript中，instanceof运算符的左操作数类型必须为any类型、对象类型或类型参数，否则结果为false。ArkTS中，instanceof运算符的左操作数类型必须为引用类型（如对象、数组或函数），否则会发生编译时错误。此外，左操作数必须是对象实例。
## 不支持in运算符
规则：arkts-no-in
级别：错误
错误码：10605066
在ArkTS中，对象布局在编译时已知且运行时无法修改，因此不支持in运算符。需要检查类成员是否存在时，使用instanceof代替。
## 不支持解构赋值
规则：arkts-no-destruct-assignment
级别：错误
错误码：10605069
ArkTS不支持解构赋值。可使用其他替代方法，例如，使用临时变量。
## 逗号运算符,仅用在for循环语句中
规则：arkts-no-comma-outside-loops
级别：错误
错误码：10605071
在ArkTS中，逗号运算符仅适用于for循环语句，用于明确执行顺序。
注意
这与声明变量和函数参数传递时使用的逗号分隔符不同。
## 不支持解构变量声明
规则：arkts-no-destruct-decls
级别：错误
错误码：10605074
ArkTS不支持解构变量声明。解构变量声明是一个依赖于结构兼容性的动态特性，且解构声明中的名称必须与被解构对象中的属性名称一致。
## 不支持在catch语句标注类型
规则：arkts-no-types-in-catch
级别：错误
错误码：10605079
TypeScript的catch语句中，只能标注any或unknown类型。ArkTS不支持这些类型，应省略类型标注。
## 不支持for .. in
规则：arkts-no-for-in
级别：错误
错误码：10605080
在ArkTS中，对象布局在编译时确定且运行时不可修改，因此不支持使用for .. in迭代对象属性。
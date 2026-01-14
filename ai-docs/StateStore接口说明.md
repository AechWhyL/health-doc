# StateStore接口和属性列表

## StateStore类

核心类，全局状态管理实例对象。提供store库的初始化等方法。

| 接口 | 参数 | 返回值 | 接口描述 |
| --- | --- | --- | --- |
| createStore | storeId: string, <br>state: T, <br>actions: Reducer,<br> middlewares?: Middleware[] | Store&lt;T&gt; | 创建store对象 |
| getStore | storeId: string | Store&lt;T&gt; | 获取store对象 |
| destroyStore | storeId: string | void | 销毁store对象 |
| createAction | type: string, <br>payload?: ESObject | Action | 创建Action对象 |
| createSendableAction | storeId: string<br>type: string, <br>payload?: ESObject | SendableAction | 创建sendable类型的Action对象 |
| receiveSendableAction | sendableAction: SendableAction | void | 接收sendableAction，同时在主线程触发指定的事件处理逻辑 |
| combineReducers | reducers: Record&lt;string, Reducer&gt; | Reducer | 合并数据处理函数为一个顶层的函数。注意：使用combineReducers只能合并同步的逻辑函数，不支持合并异步逻辑 |

## Store, 状态管理接口

状态管理对象，组件通过store对象进行数据获取和事件分发。

> dispatch 触发Reducer的逻辑可能是同步或者异步函数。每个dispatch执行时间互不影响，需要开发者保证数据的修改顺序。

| 方法 | 参数 | 返回值 | 接口描述 |
| --- | --- | --- | --- |
| getState |  | T | 获取数据 |
| dispatch | Action | Promise&lt;void&gt; | 分发action，指定执行对应函数逻辑，触发数据更新 |

## Action类

描述事件触发的普通对象。Action是把数据传入store的唯一途径，以action的形式被dispatch。

| 属性/方法 | 类型 | 说明 |
| --- | --- | --- |
| type | string | 开发者自定义的事件名称，与逻辑处理函数中的枚举值一致 |
| payload? | any | 逻辑处理函数所需的额外参数 |
| setPayload | (payload: any) =&gt; Action | 修改payload属性 |

## SendableAction类

sendable化的Action类；描述事件触发的对象。

支持子线程发送到主线程的事件对象。

| 属性/方法 | 类型 | 说明 |
| --- | --- | --- |
| storeId | string | 开发者自定义的store存储唯一标识，对应createStore创建store对象时的唯一标识 |
| type | string | 开发者自定义的事件名称，对应Reducer纯函数里的事件名称 |
| payload? | lang.ISendable | 携带业务逻辑所需的参数 |
| setPayload | (payload: lang.ISendable) =&gt; SendableAction | 修改payload属性 |

## Reducer接口

(state: T, action: Action) =&gt; (() =&gt; Promise) | null

type类型。处理数据业务逻辑的纯函数，支持同步和异步逻辑。

返回值为null，标识只是同步数据处理；返回值为Promise函数，表示执行的异步接口请求逻辑。

**参数：**

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| state | T | 是 | 开发者需要全局维护的数据，开发者通过state进行逻辑处理，保证数据来源的稳定性，避免在reducer里通过store.getState获取当前对象数据 |
| action | Action | 是 | 描述事件触发类型的对象 |

**返回值：**

| 类型 | 说明 |
| --- | --- |
| (()=&gt; Promise&lt;void&gt;) | null | 通常返回null。如果执行异步逻辑，则返回promise函数 |

## Middleware类

中间件抽象类，开发者继承实现中间件实例。

| 属性 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| actionType | string | 否 | 开发者自定义的事件标识，和Reducer的type对应。<br>如果actionType为空，中间件在每次dispatch都会执行；<br>如果actionType不为空，只有在dispatch触发该type类型时，该中间件才会执行； |
| beforeAction | MiddlewareFuncType | 否 | Reducer触发前的处理逻辑函数。<br>如果定义普通函数，则执行同步逻辑；如果定义Promise函数，则执行异步逻辑，要等到异步逻辑走完才会继续执行，会阻塞UI渲染，不建议在此处执行耗时异步操作。<br>注册的顺序决定了beforeAction的执行顺序，第一个注册的中间件的beforeAction会最先执行，第二个注册的中间件的beforeAction会接着执行，以此类推。 |
| afterAction | MiddlewareFuncType | 否 | Reducer触发后的处理逻辑函数。<br>afterAction的执行顺序与beforeAction相反，第一个注册中间件的afterAction会最后执行，第二个注册的afterAction会倒数第二个执行，以此类推 |

### MiddlewareFuncType

定义beforeAction和afterAction的函数类型；

返回值为 MiddlewareStatus | Action；或者异步返回 Promise&lt;MiddlewareStatus | Action &gt;

```typescript
MiddlewareFuncType&lt;T&gt; = (
  (state: T, action: Action) =&gt; MiddlewareStatus | Action
) | (
  (state: T, action: Action) =&gt; Promise&lt;MiddlewareStatus | Action &gt;
)
```

### MiddlewareStatus 枚举说明

| 枚举名 | 说明 |
| --- | --- |
| DROP | 中断Middleware链表执行 |
| NEXT | 继续Middleware链表执行 |

# 错误码

| 错误类型 | 错误码 | 错误信息 | 说明 |
| --- | --- | --- | --- |
| STORE_NOT_FOUND | 10000001 | 确认storeId的正确性和对应的store对象被初始化 | 传入StoreId进行store对象操作时，storeId传入错误，在内存中找不到对应的storeId |
| STORE_ALREADY_EXISTS | 10000002 | storeId已经存在，重复创建store对象 | 创建store对象时传入的storeId重复，创建失败并且返回已存在的store对象 |
| INVALID_ACTION_TYPE | 10000003 | action的type属性无效。确保type类型是一个有效的字符串并符合预期的格式 | action对象的type属性是必填，且必须为非空字符串 |

### Action创建
export default class TodoListActions {
  static getTodoList: Action = StateStore.createAction('getTodoList');
  static addTodoList: Action = StateStore.createAction('addTodoList');
  static deleteTodoItem: Action = StateStore.createAction('deleteTodoItem');
  static updateTaskDetail: Action = StateStore.createAction('updateTaskDetail');
  static completeTodoItem: Action = StateStore.createAction('completeTodoItem');
  // ...
};